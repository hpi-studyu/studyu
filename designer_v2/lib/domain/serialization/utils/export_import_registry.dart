class ExportImportRegistry {
  final Map<String, String> questionIdToHandle = {};
  final Map<String, String> choiceIdToHandle = {};
  final Map<String, String> questionHandleToId = {};
  final Map<String, String> choiceHandleToId = {};

  void registerQuestionExport(String originalId, String handle) {
    questionIdToHandle[originalId] = handle;
  }

  void registerChoiceExport(String originalId, String handle) {
    choiceIdToHandle[originalId] = handle;
  }

  void registerQuestionImport(String handle, String newId) {
    questionHandleToId[handle] = newId;
  }

  void registerChoiceImport(String handle, String newId) {
    choiceHandleToId[handle] = newId;
  }
}
