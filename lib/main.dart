import 'package:camera/camera.dart';
import 'package:camera_app/screen/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(MaterialApp(
    title: "Camera_app",
    home: TakePictureScreen(
      camera: firstCamera,
    ),
  ));
}