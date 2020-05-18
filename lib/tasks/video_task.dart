import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../util/localization.dart';
import 'dashboard_task.dart';

class VideoTask extends DashboardTask {
  final String _asset;

  VideoTask(title, description, this._asset) : super(title, description);

  @override
  State<VideoTask> createState() => _VideoTaskState();
}

class _VideoTaskState extends State<VideoTask> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.asset(widget._asset);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoInitialize: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate("video_task")),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Chewie(
                controller: _chewieController,
              ),
            ),
            FlatButton(
              color: theme.primaryColor,
              textColor: theme.secondaryHeaderColor,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(Nof1Localizations.of(context).translate("finished")),
            )
          ],
        ),
      ),
    );
  }
}
