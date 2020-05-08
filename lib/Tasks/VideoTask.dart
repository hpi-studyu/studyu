import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'DashboardTask.dart';

class VideoTask extends DashboardTask {
  final String _asset;

  VideoTask(title, description, this._asset) : super(title, description);

  @override
  State<VideoTask> createState() => _VideoTaskState();
}

class _VideoTaskState extends State<VideoTask> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.asset(widget._asset);
    _initializeVideoPlayerFuture = _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video task'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            FlatButton(
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).secondaryHeaderColor,
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Finished'),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              // If the video is paused, play it.
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}