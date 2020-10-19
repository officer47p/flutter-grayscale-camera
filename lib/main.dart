import 'dart:io';

import "package:flutter/material.dart";
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

List<CameraDescription> cameras;
CameraDescription firstCamera;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  firstCamera = cameras.first;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  // final camera;
  // HomePage(CameraDescription this.camera);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraDescription camera = firstCamera;
  CameraController _controller;
  bool _cameraIsReady = false;
  // img.Image image;
  String _imagePath;
  // Future<void> _initializeControllerFuture;

  @override
  void initState() {
    initCameraController();
    super.initState();
  }

  Future<void> initCameraController() async {
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    await _controller.initialize();
    setState(() {
      _cameraIsReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Graycam"),
      ),
      body: Column(
        children: <Widget>[
          if (_cameraIsReady == false)
            Center(child: Text("Camera is being loaded or is not available")),
          _imagePath != null
              ? Image.file(File(_imagePath))
              : Text("Image Unavailable"),
          // Expanded(
          //   child: _cameraIsReady
          //       ? CameraPreview(_controller)
          //       : Text("Camera is being loaded or is not available"),
          // ),
          Center(child: Text("This is the story.")),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: _cameraIsReady
            ? () async {
                try {
                  final path = join(
                    (await getApplicationDocumentsDirectory()).path,
                    "${DateTime.now()}.jpg",
                  );
                  await _controller.takePicture(path);
                  print("took picture and saved it");

                  setState(() {
                    img.Image image =
                        img.decodeJpg(File(path).readAsBytesSync());
                    print("Read image from file and made a img.Image object");
                    // print(image.getBytes());
                    image = img.grayscale(image);
                    print("Grayscaled");
                    image = img.copyRotate(image, 90);
                    final toBeSavedImage = img.encodePng(image);
                    print("Converted image to bytes");
                    File(path).writeAsBytesSync(toBeSavedImage);
                    _imagePath = path;
                  });

                  print("Captured");
                } catch (e) {
                  print("From fab: ${e}");
                }
              }
            : () {},
      ),
    );
  }
}
