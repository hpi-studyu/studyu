import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

/// Parses an SVG string to find all path elements with an ID and returns them
/// as a map of ID to a `Path` object.
Map<String, Path> parseSvgForPaths(String svgString) {
  final Map<String, Path> paths = {};
  final document = XmlDocument.parse(svgString);

  // Find all <path> elements in the SVG.
  final pathElements = document.findAllElements('path');

  for (final element in pathElements) {
    final id = element.getAttribute('id');
    final d = element.getAttribute('d');

    // If a path has both an id and path data, parse it and add to the map.
    if (id != null && d != null) {
      // The `parseSvgPathData` function is a handy utility from the flutter_svg
      // package that converts an SVG path data string into a Flutter `Path`.
      paths[id] = parseSvgPathData(d);
    }
  }
  return paths;
}
