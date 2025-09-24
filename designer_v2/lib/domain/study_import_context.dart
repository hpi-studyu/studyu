import 'package:studyu_core/core.dart';

/// Context object for tracking relationships during study import.
/// 
/// This class maintains mappings between natural language identifiers
/// and internal StudyU objects during the import process from LLM schemas.
class StudyImportContext {
  /// Maps question prompts to their corresponding Question objects.
  final Map<String, Question> questionsByPrompt = {};
  
  /// Maps form titles to their corresponding observation task IDs.
  final Map<String, String> observationIdByFormTitle = {};

  /// Registers a question with its prompt for later reference resolution.
  /// 
  /// This allows the import process to resolve natural language references
  /// to questions back to their internal representations.
  void registerQuestion(String prompt, Question question) {
    questionsByPrompt[prompt] = question;
  }

  /// Registers an observation form with its title and internal ID.
  /// 
  /// This mapping is used to resolve form references during the import
  /// of eligibility criteria and conditional logic.
  void registerObservationForm(String title, String observationId) {
    observationIdByFormTitle[title] = observationId;
  }

  /// Finds a Question object by its prompt text.
  /// 
  /// Returns null if no question is found with the given prompt.
  Question? findQuestionByPrompt(String prompt) {
    return questionsByPrompt[prompt];
  }

  /// Finds an observation task ID by its form title.
  /// 
  /// Returns null if no observation is found with the given title.
  String? findObservationIdByFormTitle(String title) {
    return observationIdByFormTitle[title];
  }
}
