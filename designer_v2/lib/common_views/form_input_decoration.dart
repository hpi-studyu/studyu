import 'package:flutter/material.dart';

/// Factory to construct an [InputDecoration] with an empty helper text
///
/// This prevents the height of the widget it is applied to from changing,
/// otherwise [TextField] will grow in height when displaying an error text.
class NullHelperDecoration extends InputDecoration {
  const NullHelperDecoration() : super(helperText: "");
}
