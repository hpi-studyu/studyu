import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_app/util/multimodal/persistent_storage_handler.dart';

class CapturePictureScreen extends StatefulWidget {
  final String userId;
  final String studyId;

  const CapturePictureScreen({super.key, required this.userId, required this.studyId});

  @override
  State<CapturePictureScreen> createState() => _CapturePictureScreenState();
}

class _CapturePictureScreenState extends State<CapturePictureScreen> with WidgetsBindingObserver {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  int _selectedCameraID = 0;
  late Future<void> _identifyCamerasFuture;
  Future<void> _initializeControllerFuture;
  bool _isReady = false;

  _CapturePictureScreenState() : _initializeControllerFuture = Completer<void>().future;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController();
    }
  }

  Future<void> _identifyCameras() async {
    try {
      _cameras = (await availableCameras())
          .where((CameraDescription aCameraDescription) =>
              aCameraDescription.lensDirection == CameraLensDirection.back ||
              aCameraDescription.lensDirection == CameraLensDirection.front)
          .toList();
    } on CameraException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.camera_error),
        ),
      );
    }
  }

  Future<void> _initializeCameraController() async {
    try {
      await _identifyCamerasFuture;
      _cameraController = CameraController(
        _cameras[_selectedCameraID],
        ResolutionPreset.max,
        enableAudio: false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.camera_access_denied),
        ),
      );
    }
    _initializeControllerFuture = _cameraController.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.camera_access_denied),
              ),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.camera_error),
              ),
            );
            break;
        }
      }
    });
  }

  void _jumpToNextCamera() async {
    setState(() {
      _isReady = false;
    });
    _cameraController.dispose();
    if (_selectedCameraID == _cameras.length - 1) {
      _selectedCameraID = 0;
    } else {
      _selectedCameraID = _selectedCameraID + 1;
    }
    _initializeCameraController();
  }

  Future<void> _capturePicture() async {
    setState(() {
      _isReady = false;
    });
    BuildContext? dialogContext;
    String dialogText = "";
    StateSetter? dialogStateSetter;
    setState(() {
      dialogText = AppLocalizations.of(context)!.take_a_photo;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                  dialogStateSetter = setState;
                  return Text(dialogText);
                }),
              ],
            ),
          ),
        );
      },
    );
    final XFile image = await _cameraController.takePicture();
    dialogStateSetter!(() {
      dialogText = AppLocalizations.of(context)!.storing_photo;
    });
    PersistentStorageHandler aPersistentStorageHandler = PersistentStorageHandler(widget.userId, widget.studyId);
    await aPersistentStorageHandler.storeImage(image, pathCallback: (String aPath) {
      Navigator.pop(dialogContext!);
      Navigator.pop(context, aPath);
    });
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
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && _cameraController.value.isInitialized) {
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
                onPressed: _isReady
                    ? () {
                        try {
                          _capturePicture();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.camera_error),
                            ),
                          );
                        }
                      }
                    : null,
                child: const Icon(Icons.camera_alt),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "jumpToNextCamera",
                onPressed: _isReady ? _jumpToNextCamera : null,
                child: const Icon(Icons.autorenew),
              ),
            )
          ],
        ));
  }
}
