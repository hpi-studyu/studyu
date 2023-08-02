import 'dart:async';

import 'package:camera/camera.dart';
import 'package:studyu_core/core.dart';
import 'package:flutter/material.dart';

class CapturePictureScreen extends StatefulWidget {
  const CapturePictureScreen({super.key});

  @override
  CapturePictureScreenState createState() => CapturePictureScreenState();
}

class CapturePictureScreenState extends State<CapturePictureScreen> {
  late List<CameraDescription> _cameras;
  int _selectedCameraID = 0;
  late CameraController _cameraController;
  late Future<void> _identifyCamerasFuture;
  Future<void> _initializeControllerFuture;

  final PersistentStorageHandler _persistentStorageHandler;

  CapturePictureScreenState()
      : _persistentStorageHandler = PersistentStorageHandler(),
        _initializeControllerFuture = Completer<void>().future;

  Future<void> _identifyCameras() async {
    _cameras = (await availableCameras())
        .where((CameraDescription aCameraDescription) =>
            aCameraDescription.lensDirection == CameraLensDirection.back ||
            aCameraDescription.lensDirection == CameraLensDirection.front)
        .toList();
  }

  Future<void> _initializeCameraController() async {
    await _identifyCamerasFuture;
    setState(() {
      _cameraController = CameraController(
          _cameras[_selectedCameraID], ResolutionPreset.medium,
          imageFormatGroup: ImageFormatGroup.bgra8888);
      _initializeControllerFuture = _cameraController.initialize();
    });
  }

  void _jumpToNextCamera() async {
    _cameraController.dispose();
    if (_selectedCameraID == _cameras.length - 1) {
      _selectedCameraID = 0;
    } else {
      _selectedCameraID = _selectedCameraID + 1;
    }
    _initializeCameraController();
  }

  Future<void> _capturePicture() async {
    // Ensure that the camera is initialized.
    await _initializeControllerFuture;
    final XFile image = await _cameraController.takePicture();
    await _persistentStorageHandler.storeImage(image);
  }

  @override
  void initState() {
    super.initState();
    _identifyCamerasFuture = _identifyCameras();
    _initializeCameraController();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Take a picture')),
        // You must wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner until the
        // controller has finished initializing.
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return Column(children: [
                CameraPreview(_cameraController),
                Text(_cameras[_selectedCameraID].lensDirection.name)
              ]);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: Wrap(
          direction: Axis.horizontal,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "switchToLibrary",
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => throw UnimplementedError(),
                    ),
                  );
                },
                child: const Icon(Icons.ac_unit),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "captureImage",
                onPressed: _capturePicture,
                child: const Icon(Icons.camera_alt),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "jumpToNextCamera",
                onPressed: _jumpToNextCamera,
                child: const Icon(Icons.autorenew),
              ),
            )
          ],
        ));
  }
}
