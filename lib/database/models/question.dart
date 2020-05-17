class Question {
  int id;
  String question;
  String option1;
  String option2;

  Question({this.id, this.question="", this.option1="", this.option2});

  factory Question.fromDatabaseMap(Map<String, dynamic> data) {
    return Question(
        id: data["id"],
        question: data["question"],
        option1: data["option1"],
        option2: data["option2"]
    );
  }

  Map<String, dynamic> toDatabaseMap() => {
    "id": id.toString(),
    "question": question,
    "option1": option1,
    "option2": option2
  };
}