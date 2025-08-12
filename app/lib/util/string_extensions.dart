extension StringExtensions on String {
  String toPascalCase() {
    return split(RegExp(r'[\s_]+'))
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        )
        .join();
  }
}
