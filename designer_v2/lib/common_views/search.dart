import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final Function(String) onQueryChanged;
  final SearchController? searchController;
  final String? hintText;
  final String? initialText;

  const Search({
    super.key,
    required this.onQueryChanged,
    this.searchController,
    this.hintText,
    this.initialText,
  });

  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    widget.searchController?.setText = setText;
    _searchController = TextEditingController(text: widget.initialText);
    _searchController.addListener(_onSearchPressed);
  }

  @override
  void didUpdateWidget(Search oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _onSearchPressed() {
    final String query = _searchController.text.toLowerCase();
    widget.onQueryChanged(query);
  }

  void setText(String text) {
    setState(() {
      _searchController.text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SearchBar(
      hintText: widget.hintText ?? "Search",
      controller: _searchController,
      leading: const Padding(
        padding: EdgeInsetsDirectional.only(start: 4),
        child: Icon(Icons.search_rounded, size: 20),
      ),
      elevation: const WidgetStatePropertyAll<double>(0),
      constraints: const BoxConstraints(minHeight: 35, maxHeight: 35),
      side: WidgetStatePropertyAll<BorderSide>(
        BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle?>(theme.textTheme.bodyMedium),
      hintStyle: WidgetStatePropertyAll<TextStyle?>(
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      shadowColor: WidgetStateProperty.resolveWith((states) {
        return Colors.transparent;
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.removeListener(_onSearchPressed);
    _searchController.dispose();
  }
}

class SearchController {
  late void Function(String text) setText;
}
