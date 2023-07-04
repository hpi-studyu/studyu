import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/misc.dart';
import 'package:studyu_core/core.dart';
import 'package:encrypted_media_capturing/take_picture_screen.dart';

class ImageCapturingTaskWidget extends StatefulWidget {
  final ImageCapturingTask? task;
  final CompletionPeriod? completionPeriod;

  const ImageCapturingTaskWidget({this.task, this.completionPeriod, Key? key}) : super(key: key);

  @override
  State<ImageCapturingTaskWidget> createState() => _ImageCapturingTaskWidgetState();
}

class _ImageCapturingTaskWidgetState extends State<ImageCapturingTaskWidget> {
  DateTime? loginClickTime;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('maybe put sth dynamic here???'),),
        body: const TakePictureScreen(),
    );
  }
}
