import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// late List<CameraDescription> cameras;

class CameraViewScreen extends StatefulWidget {
  const CameraViewScreen({super.key, required this.title});

  final String title;

  @override
  State<CameraViewScreen> createState() => _CameraViewScreenState();
}

class _CameraViewScreenState extends State<CameraViewScreen> {
  late List<CameraDescription> cameras;

  late CameraController _cameraController;

  String? cameraName;
  String? cameraDirection;
  String? cameraLens;
  int? cameraOrientation;
  bool? isControllerActive;

  Future<void> _incrementCounter() async {
    cameras = await availableCameras();
    log(name: "Camera Length", "${cameras.length}");
    final selectCamera = cameras.elementAt(1);
    cameraName = selectCamera.name;
    cameraDirection = selectCamera.lensDirection.toString();
    cameraOrientation = selectCamera.sensorOrientation;
    cameraLens = selectCamera.lensType.toString();
    log(name: "Cameras description", """
    Camera Name: $cameraName
    Camera Direction: $cameraDirection
    Camera Orientation: $cameraOrientation
    Camera Lens type: $cameraLens
    """);

    snackMessage(
      message:
          """
    Camera Name: $cameraName
    Camera Direction: $cameraDirection
    Camera Orientation: $cameraOrientation
    Camera Lens type: $cameraLens
    """,
    );

    _cameraController = CameraController(selectCamera, ResolutionPreset.max);
    _cameraController
        .initialize()
        .then((value) {
          if (!mounted) return;

          setState(() {});
        })
        .catchError((Object e) {
          log("Camera Controller error", error: e.toString());
          isControllerActive = false;
        });
    isControllerActive = true;

    setState(() {});
  }

  Future<void> _permissionHandel() async {
    final isCameraPermissionGranted = await Permission.camera.isGranted;
    if (!isCameraPermissionGranted) {
      log(name: "permission", "Click");
      await Permission.camera.request();
    } else {
      snackMessage(message: "Camera permission granted ✅");
    }
  }

  void snackMessage({required String message}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              videoCameraActionsButtons(),
              Container(
                margin: .all(16),

                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(20),
                //   border: Border.all(width: 4),
                // ),
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.all(Radius.circular(16)),

                  child: isControllerActive ?? false
                      ? CameraPreview(_cameraController)
                      : const CircularProgressIndicator(),
                ),
              ),
              cameraActionButtons(),
              Text("""
    Camera Name: ${cameraName ?? "No Camera"}
    Camera Direction: ${cameraDirection ?? "No Direction"}
    Camera Orientation: ${cameraOrientation ?? "No Orientation"}
    Camera Lens type: ${cameraLens ?? "No Lens"}
    """, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
      floatingActionButton: SafeArea(
        child: Column(
          spacing: 20,
          mainAxisAlignment: .end,
          crossAxisAlignment: .end,
          children: [
            FloatingActionButton.extended(
              onPressed: () async {
                await _permissionHandel();
              },
              tooltip: 'Permission request',
              icon: const Icon(Icons.perm_camera_mic),
              label: Text("Camera Permission"),
            ),
            FloatingActionButton.extended(
              onPressed: _incrementCounter,
              tooltip: 'Camera button',
              icon: const Icon(Icons.camera_alt),
              label: Text("Start Camera"),
            ),
          ],
        ),
      ),
    );
  }

  Widget videoCameraActionsButtons() {
    return Wrap(
      spacing: 16,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _cameraController.prepareForVideoRecording();
            // _cameraController.resumePreview();
          },
          label: Text("Prepare camera"),
          icon: Icon(Icons.run_circle_outlined),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _cameraController.startVideoRecording(
              onAvailable: (image) {
                log(name: "When video available", "${image.width}");
                snackMessage(message: "When video available");
              },
              enablePersistentRecording: true,
            );
            // _cameraController.resumePreview();
          },
          label: Text("Start recording"),
          icon: Icon(Icons.emergency_recording),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _cameraController.pauseVideoRecording();
            // _cameraController.resumePreview();
          },
          label: Text("Pause recording"),
          icon: Icon(Icons.run_circle_outlined),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _cameraController.pauseVideoRecording();
            // _cameraController.resumePreview();
          },
          label: Text("Resume recording"),
          icon: Icon(Icons.play_circle),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _cameraController.stopVideoRecording();
            // _cameraController.resumePreview();
          },
          label: Text("Stop recording"),
          icon: Icon(Icons.play_circle),
        ),
      ],
    );
  }

  Widget cameraActionButtons() {
    return Wrap(
      spacing: 16,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _cameraController.pausePreview();
            // _cameraController.resumePreview();
          },
          label: Text("Pause camera"),
          icon: Icon(Icons.pause_circle_filled),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // _cameraController.pausePreview();
            _cameraController.resumePreview();
          },
          label: Text("Pause camera"),
          icon: Icon(Icons.play_circle),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            // _cameraController.pausePreview();

            try {
              final image = await _cameraController.takePicture();
              final imageName = image.name;
              log(name: "Take image file", imageName);
              snackMessage(message: "Image taken $imageName");
              if (!context.mounted) return;

              // If the picture was taken, display it on a new screen.
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => DisplayPictureScreen(
                    // Pass the automatically generated path to
                    // the DisplayPictureScreen widget.
                    imagePath: image.path,
                  ),
                ),
              );
            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          },
          label: Text("Take camera"),
          icon: Icon(Icons.camera),
        ),
      ],
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
