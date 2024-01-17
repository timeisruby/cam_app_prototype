import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreenV2 extends StatefulWidget {
  const CameraScreenV2({super.key});

  @override
  State<CameraScreenV2> createState() => _CameraScreenV2State();
}

class _CameraScreenV2State extends State<CameraScreenV2> {
  late List<CameraDescription> cameras;
  late CameraController cameraController;

  int direction = 0;

  @override
  void initState() {
    startCamera(0);
    super.initState();
  }

  void startCamera(int direction) async {
    cameras = await availableCameras();

    cameraController = CameraController(
      cameras[direction],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController.value.isInitialized) {
      return Scaffold(
        body: Stack(
          children: [
            CameraPreview(cameraController),
            GestureDetector(
              child:
                  button(Icons.flip_camera_ios_outlined, Alignment.bottomLeft),
              onTap: () {
                setState(() {
                  direction = direction == 0? 1 :0;
                  startCamera(direction);
                });
              },
            ),
            GestureDetector(
              child: button(Icons.camera_alt_outlined, Alignment.bottomCenter),
              onTap: (){
                cameraController.takePicture().then((XFile? file){
                  if(mounted){
                    if(file != null){
                      print("Picture save to ${file.path}");
                    }
                  }
                });
              },
            ),
            GestureDetector(
              child: button(Icons.flip_camera_ios_outlined, Alignment.bottomRight),
            )
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget button(IconData icon, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.only(left: 20, bottom: 20),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
