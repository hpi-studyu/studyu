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
    String query = _searchController.text.toLowerCase();
    widget.onQueryChanged(query);
  }

  void setText(String text) {
    setState(() {
      _searchController.text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: widget.hintText ?? "Search",
      controller: _searchController,
      leading: const Icon(Icons.search),
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
