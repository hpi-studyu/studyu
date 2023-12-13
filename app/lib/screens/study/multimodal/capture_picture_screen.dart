import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../util/multimodal/persistent_storage_handler.dart';

class CapturePictureScreen extends StatefulWidget {
  final String userId;
  final String studyId;

  const CapturePictureScreen({super.key, required this.userId, required this.studyId});

  @override
  CapturePictureScreenState createState() => CapturePictureScreenState();
}

class CapturePictureScreenState extends State<CapturePictureScreen> {
  late List<CameraDescription> _cameras;
  int _selectedCameraID = 0;
  late CameraController _cameraController;
  late Future<void> _identifyCamerasFuture;
  Future<void> _initializeControllerFuture;

  CapturePictureScreenState() : _initializeControllerFuture = Completer<void>().future;

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
          _cameras[_selectedCameraID],
          ResolutionPreset.medium,
          imageFormatGroup: ImageFormatGroup.bgra8888,
          enableAudio: false,
      );
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
    PersistentStorageHandler aPersistentStorageHandler = PersistentStorageHandler(widget.userId, widget.studyId);
    await aPersistentStorageHandler.storeImage(image, pathCallback: (String aPath) => Navigator.pop(context, aPath));
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
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.take_a_photo)),
        // You must wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner until the
        // controller has finished initializing.
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return CameraPreview(_cameraController);
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
