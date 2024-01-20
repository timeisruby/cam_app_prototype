import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreenV2 extends StatefulWidget {
  const CameraScreenV2({super.key});

  @override
  State<CameraScreenV2> createState() => _CameraScreenV2State();
}

class _CameraScreenV2State extends State<CameraScreenV2>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  late AnimationController _flashmodeControlAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  late AnimationController _exposureModeControlRowAnimationController;
  bool isFlashOn = false;
  int direction = 0;
  bool isSelfieMode = false;

  @override
  void initState() {
    _flashmodeControlAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashmodeControlAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
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
      setState(() {
        isSelfieMode = cameraController.description.lensDirection ==
            CameraLensDirection.front;
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _flashmodeControlAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController.value.isInitialized) {
      return Scaffold(
        body: GestureDetector(
          onTap: () {
            if (_flashmodeControlAnimationController.status ==
                AnimationStatus.completed) {
              _flashmodeControlAnimationController.reverse();
            }
          },
          child: Column(
            children: [
              CameraPreview(cameraController),
              Row(
                children: [
                  GestureDetector(
                    child: button(
                        Icons.flip_camera_ios_outlined, Alignment.bottomLeft),
                    onTap: () {
                      setState(() {
                        direction = direction == 0 ? 1 : 0;
                        startCamera(direction);
                      });
                    },
                  ),
                  GestureDetector(
                    child: button(
                        Icons.camera_alt_outlined, Alignment.bottomCenter),
                    onTap: () {
                      cameraController.takePicture().then((XFile? file) {
                        if (mounted) {
                          if (file != null) {
                            print("Picture save to ${file.path}");
                          }
                        }
                      });
                    },
                  ),
                  if (!isSelfieMode)
                    GestureDetector(
                      child: button(Icons.flash_on, Alignment.bottomRight),
                      onTap: () {
                        _toggleFlashModeControl();
                      },
                    ),
                ],
              ),
              _flashModeControlRowWidget(),
            ],
          ),
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
            color: icon == Icons.flash_on && isFlashOn
                ? Colors.orange
                : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _flashModeControlRowWidget() {
    return SizeTransition(
      sizeFactor: _flashModeControlRowAnimation,
      child: ClipRect(
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.flash_off),
                color: cameraController.value.flashMode == FlashMode.off
                    ? Colors.orange
                    : Colors.white,
                onPressed: () => _onSetFlashModeButtonPressed(FlashMode.off),
              ),
              IconButton(
                icon: const Icon(Icons.flash_auto),
                color: cameraController.value.flashMode == FlashMode.auto
                    ? Colors.orange
                    : Colors.white,
                onPressed: () => _onSetFlashModeButtonPressed(FlashMode.auto),
              ),
              IconButton(
                icon: const Icon(Icons.flash_on),
                color: cameraController.value.flashMode == FlashMode.always
                    ? Colors.orange
                    : Colors.white,
                onPressed: () => _onSetFlashModeButtonPressed(FlashMode.always),
              ),
              IconButton(
                icon: const Icon(Icons.highlight),
                color: cameraController.value.flashMode == FlashMode.torch
                    ? Colors.orange
                    : Colors.white,
                onPressed: () => _onSetFlashModeButtonPressed(FlashMode.torch),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFlashModeControl() {
    if (_flashmodeControlAnimationController.status ==
        AnimationStatus.completed) {
      _flashmodeControlAnimationController.reverse();
    } else {
      _flashmodeControlAnimationController.forward();
    }
    // 셀프 카메라 모드이고, 플래시가 켜져있으면 자동으로 플래시 닫기
    if (isSelfieMode && isFlashOn) {
      _onSetFlashModeButtonPressed(FlashMode.off);
    }
  }

  void _onSetFlashModeButtonPressed(FlashMode mode) {
    if (cameraController.value.isInitialized) {
      setState(() {
        if (isSelfieMode) {
          if (mode != FlashMode.off) {
            cameraController.setFlashMode(FlashMode.off);
            isFlashOn = false;
          }
        } else {
          cameraController.setFlashMode(mode);
          isFlashOn = mode != FlashMode.off;
        }
      });
    }
  }
}
