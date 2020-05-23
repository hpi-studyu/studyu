import 'condition.dart';
import 'intervention.dart';
import 'question.dart';

class Study {
  final String id;
  final String title;
  final String description;

  List<Question> eligibility = [];
  List<Condition> conditions = [];
  List<Intervention> interventions = [];

  Study(this.id, this.title, this.description);

  @override
  String toString() {
    return 'Study(id = $id, title = $title, description = $description)';
  }
}
