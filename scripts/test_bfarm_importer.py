#!/usr/bin/env python3

from unittest import mock
import email
import hashlib
import io
import json
import unittest
import zipfile
from datetime import date

import bfarm_importer as importer


RMP_HEADER = "\t".join(importer.RMP_FIELDS)
RPP_HEADER = "\t".join(importer.RPP_FIELDS)
RSE_HEADER = "\t".join(importer.RSE_FIELDS)


class FakeApi:
    def __init__(self):
        self.calls = []
        self.release_id = "release-1"
        self.active = False

    def rpc(self, name, params):
        self.calls.append((name, params))
        if name == "begin_bfarm_import":
            return self.release_id
        if name == "get_bfarm_import_status":
            return {
                "status": "active" if self.active else "staging",
                "active_release_id": self.release_id if self.active else None,
            }
        if name == "activate_bfarm_import":
            self.active = True
            return {"status": "active"}
        return None


def attachment(name, body):
    return importer.Attachment(name, body.encode("utf-8"))


def message_bytes():
    message = email.message.EmailMessage()
    message["From"] = "referenzdaten@bfarm.de"
    message["To"] = "bfarm@studyu.health"
    message["Message-ID"] = "<delivery-1@example.test>"
    message["Authentication-Results"] = (
        "trusted.example; dmarc=pass header.d=bfarm.de"
    )
    message.set_content("Reference delivery")
    rmp = "\n".join(
        [
            RMP_HEADER,
            "rmp-1\t03752864\t1\t0\tTablet\t\tTablette\tT1\tIbuprofen Test",
        ]
    )
    rpp = "\n".join(
        [
            RPP_HEADER,
            "rpp-1\trmp-1\t1\tTablet\t\tTablette\tT1\t",
        ]
    )
    rse = "\n".join(
        [
            RSE_HEADER,
            "rse-1\trpp-1\tIbuprofen\t400 mg\t\t1",
        ]
    )
    archive = io.BytesIO()
    with zipfile.ZipFile(archive, "w") as zipped:
        zipped.writestr("20260915-REFERENCE_MEDICINAL_PRODUCT.dsv", rmp)
        zipped.writestr("20260915-REFERENCE_PHARMACEUTICAL_PRODUCT.dsv", rpp)
        zipped.writestr("20260915-REFERENCE_SUBSTANCE.dsv", rse)
    message.add_attachment(
        archive.getvalue(), maintype="application", subtype="zip", filename="delivery.zip"
    )
    return message.as_bytes()


class ImporterTest(unittest.TestCase):
    def test_pzn_validation(self):
        self.assertTrue(importer.is_valid_pzn("03752864"))
        self.assertFalse(importer.is_valid_pzn("03752865"))
        self.assertFalse(importer.is_valid_pzn("3752864"))

    def test_parse_delivery_authenticates_sender_and_archive(self):
        config = importer.ImportConfig(
            "imap.example", 993, "user", "x", "referenzdaten@bfarm.de",
            "trusted.example", "https://supabase.example", "x", True, True
        )
        delivery = importer.parse_delivery(
            importer.MailboxMessage(b"1", message_bytes()), config
        )
        self.assertEqual(delivery.source_date, date(2026, 9, 15))
        self.assertEqual(set(delivery.attachments), set(importer.TABLE_FILE_MARKERS))
        self.assertEqual(delivery.message_id, "<delivery-1@example.test>")

    def test_untrusted_message_is_blocked(self):
        message = email.message_from_bytes(message_bytes())
        message.replace_header("Authentication-Results", "other.example; dmarc=pass header.d=bfarm.de")
        config = importer.ImportConfig(
            "imap.example", 993, "user", "x", "referenzdaten@bfarm.de",
            "trusted.example", "https://supabase.example", "x", True, True
        )
        with self.assertRaisesRegex(importer.ImporterError, "Trusted MTA"):
            importer.authenticate_message(message, config.allowed_sender, config.trusted_authserv_id)

    def test_import_stages_chunks_and_acknowledges_after_readback(self):
        config = importer.ImportConfig(
            "imap.example", 993, "user", "x", "referenzdaten@bfarm.de",
            "trusted.example", "https://supabase.example", "x", True, True
        )
        delivery = importer.parse_delivery(
            importer.MailboxMessage(b"1", message_bytes()), config
        )
        api = FakeApi()
        acknowledged = []
        result = importer.import_delivery(
            delivery, config, api, acknowledge=acknowledged.append
        )
        self.assertEqual(result["status"], "active")
        self.assertEqual(acknowledged, [delivery.message])
        names = [name for name, _ in api.calls]
        self.assertEqual(
            names,
            [
                "begin_bfarm_import",
                "get_bfarm_import_status",
                "stage_bfarm_medicinal_products",
                "stage_bfarm_pharmaceutical_products",
                "stage_bfarm_substances",
                "activate_bfarm_import",
                "get_bfarm_import_status",
            ],
        )
        expected_hash = hashlib.sha256(
            b"medicinal_products\0" + delivery.attachments["medicinal_products"]
            + b"pharmaceutical_products\0" + delivery.attachments["pharmaceutical_products"]
            + b"substances\0" + delivery.attachments["substances"]
        ).hexdigest()
        self.assertEqual(delivery.sha256, expected_hash)

    def test_json_report_does_not_include_sensitive_details(self):
        output = io.StringIO()
        with mock.patch("sys.stdout", output):
            importer.report(
                "failed",
                "blocking_invalid_delivery",
                "The delivery sender is not allowed.",
            )
        payload = json.loads(output.getvalue())
        self.assertEqual(payload["code"], "blocking_invalid_delivery")
        self.assertNotIn("password", output.getvalue().lower())


if __name__ == "__main__":
    unittest.main()
