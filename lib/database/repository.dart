import 'dao.dart';
import 'models/question.dart';

class QuestionRepository {
  final QuestionDao questionDao = QuestionDao();

  Future getQuestions({int id}) => questionDao.getQuestions(id: id);

  Future insertQuestion(Question question) => questionDao.createQuestion(question);
}