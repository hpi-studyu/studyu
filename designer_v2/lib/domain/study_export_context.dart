import 'package:studyu_core/core.dart';

/// Context object for tracking relationships during study export.
/// 
/// This class maintains mappings between observation IDs, form keys, and
/// questions to enable natural language references in the exported schema.
class StudyExportContext {
  /// Maps observation task IDs to their corresponding form titles.
  final Map<String, String> formKeyByObservationId = {};
  
  /// Maps form titles to their questions, indexed by question prompts.
  final Map<String, Map<String, Question>> questionsByFormKey = {};

  /// Registers a question for a specific form.
  /// 
  /// This allows the context to track which questions belong to which forms
  /// for later reference resolution.
  void registerQuestion(String formKey, String questionKey, Question question) {
    final form = questionsByFormKey.putIfAbsent(formKey, () => {});
    form[questionKey] = question;
  }

  /// Exports a data reference using natural language identifiers.
  /// 
  /// Converts internal ID-based references to form/question pairs that
  /// can be understood by LLMs.
  /// 
  /// Returns null if the reference cannot be resolved.
  Map<String, String>? exportDataReference(DataReference<num>? reference) {
    if (reference == null) return null;
    
    final formTitle = formKeyByObservationId[reference.task];
    if (formTitle == null) return null;
    final questions = questionsByFormKey[formTitle];
    if (questions == null) return null;
    for (final entry in questions.entries) {
      if (entry.value.id == reference.property) {
        return {'form': formTitle, 'question': entry.key};
      }
    }
    return null;
  }
}
