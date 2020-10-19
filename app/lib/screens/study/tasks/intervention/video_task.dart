import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/util/localization.dart';
import 'package:video_player/video_player.dart';

class VideoTask extends StatefulWidget {
  final String _asset;

  const VideoTask(this._asset);

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
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Chewie(
            controller: _chewieController,
          ),
        ),
        RaisedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(Nof1Localizations.of(context).translate('finished')),
        )
      ],
    ));
  }
}
