#!/usr/bin/env python3
"""Import authenticated BfArM reference deliveries into StudyU."""

from __future__ import annotations

import argparse
import csv
import hashlib
import io
import json
import os
import re
import sys
import zipfile
from dataclasses import dataclass
from datetime import date, datetime, timedelta, timezone
from email import policy
from email.message import Message
from email.parser import BytesParser
from email.utils import parseaddr
from imaplib import IMAP4_SSL
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


MAX_STAGE_ROWS = 500
DELIVERY_WINDOWS = ((1, 3), (15, 17))
TABLE_FILE_MARKERS = {
    "medicinal_products": "REFERENCE_MEDICINAL_PRODUCT",
    "pharmaceutical_products": "REFERENCE_PHARMACEUTICAL_PRODUCT",
    "substances": "REFERENCE_SUBSTANCE",
}

RMP_FIELDS = (
    "RMP_KEY",
    "RMP_PZN",
    "RMP_COUNT_SUBSTANCE",
    "RMP_MULTIPLE_PPT",
    "RMP_PFM_PUT_SHORT",
    "RMP_PFM_PUT_LONG",
    "RMP_PFM_NAME",
    "RMP_PFM_TERM_ID",
    "RMP_MPD_NAME",
)
RPP_FIELDS = (
    "RPP_KEY",
    "RMP_KEY",
    "RPP_NUMBER",
    "RPP_PFM_PUT_SHORT",
    "RPP_PFM_PUT_LONG",
    "RPP_PFM_NAME",
    "RPP_PFM_TERM_ID",
    "RPP_DESCRIPTION",
)
RSE_FIELDS = (
    "RSE_KEY",
    "RPP_KEY",
    "RSE_SUBSTANCE_NAME",
    "RSE_SUBSTANCE_STRENGTH",
    "RSE_SUBSTANCE_ID",
    "RSE_SUBSTANCE_RANK",
)


class ImporterError(Exception):
    def __init__(self, code: str, summary: str) -> None:
        super().__init__(summary)
        self.code = code
        self.summary = summary


@dataclass(frozen=True)
class Attachment:
    name: str
    content: bytes


@dataclass(frozen=True)
class MailboxMessage:
    uid: bytes
    raw: bytes


@dataclass(frozen=True)
class Delivery:
    message: MailboxMessage
    message_id: Optional[str]
    sender: str
    source_date: date
    attachments: Dict[str, bytes]
    sha256: str


@dataclass(frozen=True)
class ImportConfig:
    imap_host: str
    imap_port: int
    imap_username: str
    imap_password: str
    allowed_sender: str
    trusted_authserv_id: str
    supabase_url: str
    service_role_key: str
    production_enabled: bool
    schedule_enabled: bool
    importer_version: str = "bfarm-importer/1"


def env_bool(name: str, default: bool = False) -> bool:
    value = os.environ.get(name)
    if value is None:
        return default
    return value.strip().lower() in ("1", "true", "yes", "on")


def load_config() -> ImportConfig:
    names = (
        "BFARM_IMAP_HOST",
        "BFARM_IMAP_USERNAME",
        "BFARM_IMAP_PASSWORD",
        "BFARM_ALLOWED_SENDER",
        "BFARM_TRUSTED_AUTHSERV_ID",
        "SUPABASE_URL",
        "SUPABASE_SERVICE_ROLE_KEY",
    )
    missing = [name for name in names if not os.environ.get(name)]
    if missing:
        raise ImporterError("configuration_missing", "Required importer settings are missing.")
    try:
        port = int(os.environ.get("BFARM_IMAP_PORT", "993"))
    except ValueError as error:
        raise ImporterError("configuration_invalid", "BFARM_IMAP_PORT is invalid.") from error
    return ImportConfig(
        imap_host=os.environ["BFARM_IMAP_HOST"],
        imap_port=port,
        imap_username=os.environ["BFARM_IMAP_USERNAME"],
        imap_password=os.environ["BFARM_IMAP_PASSWORD"],
        allowed_sender=os.environ["BFARM_ALLOWED_SENDER"],
        trusted_authserv_id=os.environ["BFARM_TRUSTED_AUTHSERV_ID"],
        supabase_url=os.environ["SUPABASE_URL"].rstrip("/"),
        service_role_key=os.environ["SUPABASE_SERVICE_ROLE_KEY"],
        production_enabled=env_bool("BFARM_PRODUCTION_ENABLED"),
        schedule_enabled=env_bool("BFARM_SCHEDULE_ENABLED"),
        importer_version=os.environ.get("BFARM_IMPORTER_VERSION", "bfarm-importer/1"),
    )


def is_valid_pzn(value: str) -> bool:
    return bool(re.fullmatch(r"[0-9]{8}", value)) and sum(
        int(digit) * index for index, digit in enumerate(value[:7], 1)
    ) % 11 == int(value[7])


def normalize_header(value: str) -> str:
    return value.strip().lstrip("\ufeff").upper()


def _delimiter(text: str) -> str:
    sample = text.splitlines()[0] if text.splitlines() else ""
    candidates = ("\t", ";", "|")
    return max(candidates, key=sample.count)


def _required(value: str, field: str, line: int) -> str:
    if value == "":
        raise ImporterError("bfarm_reference_integrity", "A required source field is empty.")
    return value


def _optional(value: str) -> Optional[str]:
    return value if value != "" else None


def _positive_int(value: str, field: str, line: int) -> int:
    if not re.fullmatch(r"[1-9][0-9]*", value):
        raise ImporterError("bfarm_reference_integrity", "A source number is invalid.")
    return int(value)


def _parse_rows(content: bytes, expected_fields: Sequence[str]) -> List[Dict[str, str]]:
    try:
        text = content.decode("utf-8-sig")
    except UnicodeDecodeError as error:
        raise ImporterError("bfarm_reference_integrity", "A source file is not valid UTF-8.") from error
    reader = csv.DictReader(io.StringIO(text), delimiter=_delimiter(text))
    if reader.fieldnames is None:
        raise ImporterError("bfarm_reference_integrity", "A source file has no header.")
    headers = [normalize_header(field) for field in reader.fieldnames]
    if headers != list(expected_fields):
        raise ImporterError("bfarm_reference_integrity", "A source header does not match the expected schema.")
    rows: List[Dict[str, str]] = []
    for line, raw in enumerate(reader, 2):
        if None in raw or any(value is None for value in raw.values()):
            raise ImporterError("bfarm_reference_integrity", "A source row has an invalid column count.")
        rows.append({field: raw[field].strip() for field in reader.fieldnames})
    return rows


def parse_medicinal_products(content: bytes) -> List[Dict[str, Any]]:
    result = []
    for row in _parse_rows(content, RMP_FIELDS):
        pzn = _required(row["RMP_PZN"], "RMP_PZN", 0)
        if not is_valid_pzn(pzn):
            raise ImporterError("bfarm_invalid_pzn", "A source product contains an invalid PZN.")
        multiple = _required(row["RMP_MULTIPLE_PPT"], "RMP_MULTIPLE_PPT", 0)
        if multiple not in ("0", "1"):
            raise ImporterError("bfarm_reference_integrity", "A source combination flag is invalid.")
        result.append(
            {
                "rmp_key": _required(row["RMP_KEY"], "RMP_KEY", 0),
                "rmp_pzn": pzn,
                "rmp_count_substance": _positive_int(row["RMP_COUNT_SUBSTANCE"], "RMP_COUNT_SUBSTANCE", 0),
                "rmp_multiple_ppt": multiple,
                "rmp_pfm_put_short": _required(row["RMP_PFM_PUT_SHORT"], "RMP_PFM_PUT_SHORT", 0),
                "rmp_pfm_put_long": _optional(row["RMP_PFM_PUT_LONG"]),
                "rmp_pfm_name": _required(row["RMP_PFM_NAME"], "RMP_PFM_NAME", 0),
                "rmp_pfm_term_id": _required(row["RMP_PFM_TERM_ID"], "RMP_PFM_TERM_ID", 0),
                "rmp_mpd_name": _required(row["RMP_MPD_NAME"], "RMP_MPD_NAME", 0),
            }
        )
    return result


def parse_pharmaceutical_products(content: bytes) -> List[Dict[str, Any]]:
    result = []
    for row in _parse_rows(content, RPP_FIELDS):
        result.append(
            {
                "rpp_key": _required(row["RPP_KEY"], "RPP_KEY", 0),
                "rmp_key": _required(row["RMP_KEY"], "RMP_KEY", 0),
                "rpp_number": _positive_int(row["RPP_NUMBER"], "RPP_NUMBER", 0),
                "rpp_pfm_put_short": _required(row["RPP_PFM_PUT_SHORT"], "RPP_PFM_PUT_SHORT", 0),
                "rpp_pfm_put_long": _optional(row["RPP_PFM_PUT_LONG"]),
                "rpp_pfm_name": _required(row["RPP_PFM_NAME"], "RPP_PFM_NAME", 0),
                "rpp_pfm_term_id": _required(row["RPP_PFM_TERM_ID"], "RPP_PFM_TERM_ID", 0),
                "rpp_description": _optional(row["RPP_DESCRIPTION"]),
            }
        )
    return result


def parse_substances(content: bytes) -> List[Dict[str, Any]]:
    result = []
    for row in _parse_rows(content, RSE_FIELDS):
        result.append(
            {
                "rse_key": _required(row["RSE_KEY"], "RSE_KEY", 0),
                "rpp_key": _required(row["RPP_KEY"], "RPP_KEY", 0),
                "rse_substance_name": _required(row["RSE_SUBSTANCE_NAME"], "RSE_SUBSTANCE_NAME", 0),
                "rse_substance_strength": _optional(row["RSE_SUBSTANCE_STRENGTH"]),
                "rse_substance_id": _optional(row["RSE_SUBSTANCE_ID"]),
                "rse_substance_rank": _positive_int(row["RSE_SUBSTANCE_RANK"], "RSE_SUBSTANCE_RANK", 0),
            }
        )
    return result


def validate_relationships(
    medicinal: Sequence[Dict[str, Any]],
    pharmaceutical: Sequence[Dict[str, Any]],
    substances: Sequence[Dict[str, Any]],
) -> None:
    medicinal_keys = {row["rmp_key"] for row in medicinal}
    pharmaceutical_keys = {row["rpp_key"] for row in pharmaceutical}
    if len(medicinal_keys) != len(medicinal) or len(pharmaceutical_keys) != len(pharmaceutical):
        raise ImporterError("bfarm_reference_integrity", "A source key is duplicated.")
    if any(row["rmp_key"] not in medicinal_keys for row in pharmaceutical):
        raise ImporterError("bfarm_reference_integrity", "A component references an unknown product.")
    if any(row["rpp_key"] not in pharmaceutical_keys for row in substances):
        raise ImporterError("bfarm_reference_integrity", "A substance references an unknown component.")
    if len({row["rse_key"] for row in substances}) != len(substances):
        raise ImporterError("bfarm_reference_integrity", "A substance key is duplicated.")
    components_by_product: Dict[str, int] = {}
    for row in pharmaceutical:
        components_by_product[row["rmp_key"]] = components_by_product.get(row["rmp_key"], 0) + 1
    for row in medicinal:
        expected_multiple = components_by_product.get(row["rmp_key"], 0) > 1
        if (row["rmp_multiple_ppt"] == "1") != expected_multiple:
            raise ImporterError("bfarm_reference_integrity", "A product combination flag does not match its components.")
    if any(count == 0 for count in components_by_product.values()):
        raise ImporterError("bfarm_reference_integrity", "A product has no component.")
    if any(row["rpp_key"] not in {item["rpp_key"] for item in substances} for row in pharmaceutical):
        raise ImporterError("bfarm_reference_integrity", "A component has no substance.")


def classify_attachment(name: str) -> Optional[str]:
    upper = name.upper()
    for table, marker in TABLE_FILE_MARKERS.items():
        if marker in upper:
            return table
    return None


def expand_attachments(message: Message) -> List[Attachment]:
    expanded: List[Attachment] = []
    for part in message.walk():
        if part.is_multipart():
            continue
        name = part.get_filename()
        payload = part.get_payload(decode=True)
        if not name or payload is None:
            continue
        if name.lower().endswith(".zip"):
            try:
                with zipfile.ZipFile(io.BytesIO(payload)) as archive:
                    for member in archive.infolist():
                        if not member.is_dir():
                            expanded.append(Attachment(member.filename, archive.read(member)))
            except (OSError, zipfile.BadZipFile) as error:
                raise ImporterError("bfarm_reference_integrity", "A delivery archive is invalid.") from error
        else:
            expanded.append(Attachment(name, payload))
    return expanded


def authenticate_message(message: Message, allowed_sender: str, authserv_id: str) -> str:
    sender = parseaddr(message.get("From", ""))[1].strip().lower()
    if sender != allowed_sender.strip().lower():
        raise ImporterError("blocking_invalid_delivery", "The delivery sender is not allowed.")
    trusted = False
    for header in message.get_all("Authentication-Results", []):
        first = header.split(";", 1)[0].strip().split()[0] if header.strip() else ""
        if first != authserv_id:
            continue
        if not re.search(r"(?:^|;)\s*dmarc=pass(?:\s|;|$)", header, re.IGNORECASE):
            continue
        if not re.search(r"(?:^|[;\s])header\.d=bfarm\.de(?:\s|;|$)", header, re.IGNORECASE):
            continue
        trusted = True
        break
    if not trusted:
        raise ImporterError("blocking_invalid_delivery", "Trusted MTA authentication did not pass.")
    return sender


def source_date_from_name(name: str) -> Optional[date]:
    match = re.search(r"(?<![0-9])(20[0-9]{6})(?![0-9])", name)
    if not match:
        return None
    try:
        return datetime.strptime(match.group(1), "%Y%m%d").date()
    except ValueError:
        return None


def parse_delivery(message: MailboxMessage, config: ImportConfig) -> Delivery:
    parsed = BytesParser(policy=policy.default).parsebytes(message.raw)
    sender = authenticate_message(parsed, config.allowed_sender, config.trusted_authserv_id)
    attachments = expand_attachments(parsed)
    by_table: Dict[str, bytes] = {}
    source_dates = set()
    for attachment in attachments:
        table = classify_attachment(attachment.name)
        if table is None:
            continue
        if table in by_table:
            raise ImporterError("bfarm_reference_integrity", "A delivery contains duplicate source tables.")
        source_date = source_date_from_name(attachment.name)
        if source_date is None:
            raise ImporterError("bfarm_reference_integrity", "A source filename has no valid date.")
        source_dates.add(source_date)
        by_table[table] = attachment.content
    if set(by_table) != set(TABLE_FILE_MARKERS):
        raise ImporterError("bfarm_reference_integrity", "A delivery does not contain all source tables.")
    if len(source_dates) != 1:
        raise ImporterError("bfarm_reference_integrity", "Source table dates do not match.")
    digest = hashlib.sha256()
    for table in sorted(by_table):
        digest.update(table.encode("ascii"))
        digest.update(b"\0")
        digest.update(by_table[table])
    return Delivery(
        message=message,
        message_id=parsed.get("Message-ID"),
        sender=sender,
        source_date=source_dates.pop(),
        attachments=by_table,
        sha256=digest.hexdigest(),
    )


def delivery_window(day: date) -> Tuple[date, date]:
    if day.day <= 3:
        return day.replace(day=1), day.replace(day=3)
    if day.day <= 17:
        return day.replace(day=15), day.replace(day=17)
    next_month = (day.replace(day=28) + timedelta(days=4)).replace(day=1)
    return next_month, next_month.replace(day=3)

def choose_delivery(messages: Sequence[MailboxMessage], config: ImportConfig, today: date) -> Delivery:
    start, end = delivery_window(today)
    candidates: List[Delivery] = []
    for mailbox_message in messages:
        parsed = BytesParser(policy=policy.default).parsebytes(mailbox_message.raw)
        sender = parseaddr(parsed.get("From", ""))[1].strip().lower()
        if sender != config.allowed_sender.strip().lower():
            continue
        delivery = parse_delivery(mailbox_message, config)
        if start <= delivery.source_date <= end:
            candidates.append(delivery)
    if candidates:
        candidates.sort(key=lambda item: (item.source_date, item.message_id or ""))
        return candidates[0]
    code = "no_delivery" if today.day in (1, 2, 3, 15, 16, 17) else "delivery_overdue"
    raise ImporterError(code, "No valid delivery is available in the current delivery window.")


class Mailbox:
    def __init__(self, config: ImportConfig) -> None:
        self.config = config
        self.connection: Optional[IMAP4_SSL] = None

    def __enter__(self) -> "Mailbox":
        self.connection = IMAP4_SSL(self.config.imap_host, self.config.imap_port)
        self.connection.login(self.config.imap_username, self.config.imap_password)
        status, _ = self.connection.select("INBOX", readonly=False)
        if status != "OK":
            raise ImporterError("mailbox_error", "The mailbox could not be opened.")
        return self

    def __exit__(self, *_: object) -> None:
        if self.connection is not None:
            try:
                self.connection.close()
            finally:
                self.connection.logout()

    def messages(self) -> List[MailboxMessage]:
        if self.connection is None:
            raise ImporterError("mailbox_error", "The mailbox is not connected.")
        status, data = self.connection.uid("search", None, "ALL")
        if status != "OK" or not data or not data[0]:
            return []
        result = []
        for uid in data[0].split():
            status, fetched = self.connection.uid("fetch", uid, "(BODY.PEEK[])")
            if status != "OK":
                continue
            raw = b"".join(item[1] for item in fetched if isinstance(item, tuple))
            result.append(MailboxMessage(uid, raw))
        return result

    def acknowledge(self, message: MailboxMessage) -> None:
        if self.connection is None:
            raise ImporterError("mailbox_error", "The mailbox is not connected.")
        status, _ = self.connection.uid("store", message.uid, "+FLAGS", "(\\Seen)")
        if status != "OK":
            raise ImporterError("mailbox_acknowledgement_failed", "The delivery could not be acknowledged.")


class SupabaseApi:
    def __init__(self, url: str, service_role_key: str) -> None:
        self.url = url.rstrip("/")
        self.service_role_key = service_role_key

    def rpc(self, name: str, params: Dict[str, Any]) -> Any:
        request = Request(
            f"{self.url}/rest/v1/rpc/{name}",
            data=json.dumps(params).encode("utf-8"),
            headers={
                "apikey": self.service_role_key,
                "Authorization": f"Bearer {self.service_role_key}",
                "Content-Type": "application/json",
            },
            method="POST",
        )
        try:
            with urlopen(request, timeout=60) as response:
                payload = response.read()
        except (HTTPError, URLError, TimeoutError) as error:
            raise ImporterError("supabase_error", "The Supabase request failed.") from error
        if not payload:
            return None
        try:
            return json.loads(payload.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as error:
            raise ImporterError("supabase_error", "The Supabase response is invalid.") from error


def chunks(rows: Sequence[Dict[str, Any]], size: int = MAX_STAGE_ROWS) -> Iterable[List[Dict[str, Any]]]:
    for index in range(0, len(rows), size):
        yield list(rows[index : index + size])


def load_delivery_rows(delivery: Delivery) -> Dict[str, List[Dict[str, Any]]]:
    medicinal = parse_medicinal_products(delivery.attachments["medicinal_products"])
    pharmaceutical = parse_pharmaceutical_products(delivery.attachments["pharmaceutical_products"])
    substances = parse_substances(delivery.attachments["substances"])
    validate_relationships(medicinal, pharmaceutical, substances)
    return {
        "medicinal_products": medicinal,
        "pharmaceutical_products": pharmaceutical,
        "substances": substances,
    }


def import_delivery(
    delivery: Delivery,
    config: ImportConfig,
    api: SupabaseApi,
    allow_large_drop: bool = False,
    allow_same_date_correction: bool = False,
    corrects_release_id: Optional[str] = None,
    expected_attachment_sha256: Optional[str] = None,
    acknowledge: Optional[Any] = None,
) -> Dict[str, Any]:
    if expected_attachment_sha256 and expected_attachment_sha256 != delivery.sha256:
        raise ImporterError("bfarm_sha256_mismatch", "The delivery hash does not match the expected hash.")
    rows = load_delivery_rows(delivery)
    expected_counts = {name: len(values) for name, values in rows.items()}
    release_id: Optional[str] = None
    try:
        release_id = api.rpc(
            "begin_bfarm_import",
            {
                "p_source_date": delivery.source_date.isoformat(),
                "p_message_id": delivery.message_id,
                "p_sender": delivery.sender,
                "p_attachment_sha256": delivery.sha256,
                "p_expected_counts": expected_counts,
                "p_importer_version": config.importer_version,
                "p_corrects_release_id": corrects_release_id,
            },
        )
        status = api.rpc("get_bfarm_import_status", {"p_release_id": release_id})
        if isinstance(status, dict) and status.get("status") == "active" and status.get("active_release_id") == release_id:
            if acknowledge is not None:
                acknowledge(delivery.message)
            return {"status": "active", "release_id": release_id, "source_date": delivery.source_date.isoformat()}
        for table, values in rows.items():
            rpc_name = {
                "medicinal_products": "stage_bfarm_medicinal_products",
                "pharmaceutical_products": "stage_bfarm_pharmaceutical_products",
                "substances": "stage_bfarm_substances",
            }[table]
            for batch in chunks(values):
                api.rpc(rpc_name, {"p_release_id": release_id, "p_rows": batch})
        api.rpc(
            "activate_bfarm_import",
            {
                "p_release_id": release_id,
                "p_allow_large_drop": allow_large_drop,
                "p_allow_same_date_correction": allow_same_date_correction,
            },
        )
        final_status = api.rpc("get_bfarm_import_status", {"p_release_id": release_id})
        if not isinstance(final_status, dict) or final_status.get("status") != "active" or final_status.get("active_release_id") != release_id:
            raise ImporterError("activation_readback_failed", "The active release read-back did not confirm activation.")
        if acknowledge is not None:
            acknowledge(delivery.message)
        return {"status": "active", "release_id": release_id, "source_date": delivery.source_date.isoformat()}
    except ImporterError as error:
        if release_id:
            try:
                api.rpc("mark_bfarm_import_failed", {"p_release_id": release_id, "p_code": error.code, "p_summary": error.summary})
            except ImporterError:
                pass
        raise


def report(status: str, code: Optional[str] = None, summary: Optional[str] = None) -> None:
    value: Dict[str, str] = {"status": status}
    if code:
        value["code"] = code
    if summary:
        value["summary"] = summary
    print(json.dumps(value, sort_keys=True))


def run(config: ImportConfig, args: argparse.Namespace, today: Optional[date] = None) -> int:
    if not config.production_enabled:
        report("disabled", "production_disabled", "Production import is disabled.")
        return 0
    if not args.manual and not config.schedule_enabled:
        report("disabled", "schedule_disabled", "Scheduled import is disabled.")
        return 0
    current_day = today or date.today()
    try:
        with Mailbox(config) as mailbox:
            delivery = choose_delivery(mailbox.messages(), config, current_day)
            result = import_delivery(
                delivery,
                config,
                SupabaseApi(config.supabase_url, config.service_role_key),
                allow_large_drop=args.allow_large_drop if args.manual else False,
                allow_same_date_correction=args.allow_same_date_correction if args.manual else False,
                corrects_release_id=args.corrects_release_id if args.manual else None,
                expected_attachment_sha256=args.expected_attachment_sha256,
                acknowledge=mailbox.acknowledge,
            )
        report(result["status"])
        return 0
    except ImporterError as error:
        report("failed", error.code, error.summary)
        return 1 if error.code not in ("no_delivery",) else 0


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manual", action="store_true")
    parser.add_argument("--allow-large-drop", action="store_true")
    parser.add_argument("--allow-same-date-correction", action="store_true")
    parser.add_argument("--corrects-release-id")
    parser.add_argument("--expected-attachment-sha256")
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    try:
        return run(load_config(), parse_args(argv))
    except ImporterError as error:
        report("failed", error.code, error.summary)
        return 1


if __name__ == "__main__":
    sys.exit(main())
