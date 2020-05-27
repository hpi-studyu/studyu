import '../models/models.dart';
import '../models/questionnaire/eligibility.dart';

const filename = 'assets/studies/scratch.xml';

class StudyDao {
  /*xml.XmlDocument _document;

  Future<xml.XmlDocument> get _doc async {
    if (_document == null) {
      final fileContents = await rootBundle.loadString(filename);
      _document = xml.parse(fileContents);
    }
    return _document;
  }*/

  Future<List<Study>> getAllStudies() async {
    var response = await Study().getAll();
    if (response.success) {
      return response.results.map((study) => study is Study ? study : null).toList();
    }
    return [];
  }

  Future<Eligibility> getEligibility(Study study) async {
    //TODO add to study
    var response = await Eligibility().getObject(null);
    if (response.success && response.results.isNotEmpty) {
      return response.results.first is Eligibility ? response.results.first : null;
    }
    return null;
  }

  Future<StudyDetails> getStudyDetails(Study study) async {
    //TODO replace mock
    var interventions = [Intervention('Medication'), Intervention('Exercise'), Intervention('Weed')];
    var studyDetails = StudyDetails();
    studyDetails.interventions = interventions;
    return studyDetails;
  }

  /*Future<List<Study>> getAllStudies() async {
    var studyElements = await _doc.then((xmlTree) => xmlTree.rootElement.findAllElements('study').map((studyElement) {
          return Study(studyElement.attributes.firstWhere((element) => element.name.local == 'id', orElse: () => null)?.value,
              studyElement.attributes.firstWhere((element) => element.name.local == 'title', orElse: () => null)?.value,
              studyElement.attributes.firstWhere((element) => element.name.local == 'description', orElse: () => null)?.value);
        }).toList());
    return studyElements;
  }*/
}
