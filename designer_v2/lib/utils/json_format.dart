import 'dart:convert';

String prettyJson(dynamic json, {int indent = 2}) {
  final spaces = ' ' * indent;
  final encoder = JsonEncoder.withIndent(spaces);
  return encoder.convert(json);
}

void printPrettyJson(dynamic json, {int indent = 2}) {
  print(prettyJson(json, indent: indent));
}
