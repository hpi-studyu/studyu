import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart' as xml;
import '../models/study.dart';

const filename = 'assets/studies/scratch.xml';

class StudyDao {
  xml.XmlDocument _document;

  Future<xml.XmlDocument> get _doc async {
    if (_document == null) {
      final fileContents = await rootBundle.loadString(filename);
      _document = xml.parse(fileContents);
    }
    return _document;
  }

  Future<List<Study>> getAllStudies() async {
    var studyElements = await _doc.then((xmlTree) => xmlTree.rootElement.findAllElements('study').map((studyElement) {
          return Study(studyElement.attributes.firstWhere((element) => element.name.local == 'id', orElse: () => null)?.value,
              studyElement.attributes.firstWhere((element) => element.name.local == 'title', orElse: () => null)?.value,
              studyElement.attributes.firstWhere((element) => element.name.local == 'description', orElse: () => null)?.value);
        }).toList());
    return studyElements;
  }
}
