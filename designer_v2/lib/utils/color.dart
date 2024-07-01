import 'package:flutter/rendering.dart';
import 'package:studyu_designer_v2/utils/typings.dart';

/// JSON-encodable version of [Color]
class SerializableColor extends Color {
  SerializableColor(super.value);

  JsonMap toJson() => {
        "value": super.value,
      };
  SerializableColor fromJson(JsonMap json) => SerializableColor(
        int.parse(json["value"].toString()),
      );
}
