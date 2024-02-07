import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_app/util/multimodal/temporary_storage_handler.dart';

class CapturePictureScreen extends StatefulWidget {
  final String userId;
  final String studyId;

  const CapturePictureScreen({super.key, required this.userId, required this.studyId});

  @override
  State<CapturePictureScreen> createState() => _CapturePictureScreenState();
}

class _CapturePictureScreenState extends State<CapturePictureScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _jumpToNextCameraTaps = 0;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _initializeCameraController();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      await cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      await _initializeCameraController();
    }
  }

  Future<void> _initializeCameraController() async {
    try {
      final oldCameraController = _cameraController;
      final cameras = _cameras ?? await _getAvailableCameras();
      _cameras = cameras;
      if (cameras.isEmpty) {
        throw CameraException("NoCameraAvailable", "No cameras are available");
      }
      if (oldCameraController != null) {
        await oldCameraController.dispose();
      }
      final cameraIndex = _jumpToNextCameraTaps % cameras.length;
      final newCameraController = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await newCameraController.initialize();
      setState(() {
        _cameraController = newCameraController;
      });
    } catch (e) {
      if (!mounted) return;
      String errorText = AppLocalizations.of(context)!.camera_error;
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          case 'CameraAccessDeniedWithoutPrompt':
          case 'CameraAccessRestricted':
            errorText = AppLocalizations.of(context)!.camera_access_denied;
            break;
          case 'NoCameraAvailable':
            errorText = AppLocalizations.of(context)!.no_camera_available;
            break;
        }
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorText),
        ),
      );
    }
  }

  Future<List<CameraDescription>> _getAvailableCameras() async {
    return (await availableCameras())
        .where((CameraDescription aCameraDescription) =>
            aCameraDescription.lensDirection == CameraLensDirection.back ||
            aCameraDescription.lensDirection == CameraLensDirection.front)
        .toList();
  }

  Future<void> _jumpToNextCamera() async {
    _jumpToNextCameraTaps++;
    await _initializeCameraController();
  }

  Future<void> _tryCapturePicture() async {
    final cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized || cameraController.value.isTakingPicture) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    XFile image;
    try {
      image = await cameraController.takePicture();
    } on Exception catch (e) {
      debugPrint("Failed to take picture: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.camera_error),
        ),
      );
      setState(() {
        _isTakingPicture = false;
      });
      return;
    }

    // Move the image to the staging directory
    final imageFile = File(image.path);
    final storage = TemporaryStorageHandler(widget.studyId, widget.userId);
    final stagingImagePath = await storage.getStagingImageFilePath();
    await imageFile.rename(stagingImagePath);

    if (!mounted) return;
    Navigator.pop(context, stagingImagePath);
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = _cameraController;
    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.take_a_photo)),
        body: cameraController == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  CameraPreview(cameraController),
                  _isTakingPicture
                      ? Container(
                          color: Colors.black.withOpacity(0.5),
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).dialogBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(AppLocalizations.of(context)!.take_a_photo),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
        floatingActionButton: Wrap(
          direction: Axis.horizontal,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "captureImage",
                onPressed: cameraController != null && !_isTakingPicture
                    ? () async {
                        await _tryCapturePicture();
                      }
                    : null,
                child: const Icon(Icons.camera_alt),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "jumpToNextCamera",
                onPressed: cameraController != null && !_isTakingPicture ? () async => await _jumpToNextCamera() : null,
                child: const Icon(Icons.autorenew),
              ),
            )
          ],
        ));
  }
}
