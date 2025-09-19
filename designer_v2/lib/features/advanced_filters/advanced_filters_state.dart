import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI-only flag to know if the Advanced Filters panel is open.
/// (The actual filter query state will come in the next task.)
final advancedFiltersOpenProvider = StateProvider<bool>((_) => false);
