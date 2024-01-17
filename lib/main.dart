import 'package:camera/camera.dart';
import 'package:camera_app/screen/camera.dart';
import 'package:camera_app/screen/camera_v2.dart';
import 'package:flutter/material.dart';

/*
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
*/


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "camera",
      home: CameraScreenV2(),
    );
  }
}