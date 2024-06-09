import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class IClipboardService {
  Future<String> copy(String text);
}

/// Simple wrapper around Flutter's [Clipboard]
class ClipboardService implements IClipboardService {
  @override
  Future<String> copy(String text) {
    return Clipboard.setData(ClipboardData(text: text)).then((value) => text);
  }
}

final clipboardServiceProvider =
    Provider<IClipboardService>((ref) => ClipboardService());
