import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MLKit Face Detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  var image;
  late Future<File> imageFile;
  late ImagePicker imagePicker;
  String result = "";
  late List<Face> faces;
  late FaceDetector faceDetector;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    final options = FaceDetectorOptions(
      enableClassification: true,
      minFaceSize: 0.1,
      performanceMode: FaceDetectorMode.fast);
    faceDetector = GoogleMlKit.vision.faceDetector(options);
  }

  faceDetection() async {
    final inputImage = InputImage.fromFile(_image!);
    faces = await faceDetector.processImage(inputImage);
    image = await _image?.readAsBytes();
    image = await decodeImageFromList(image);

    setState(() {
      faces;
      result;
    });
  }

  pickImage(bool fromGallery) async {
    XFile? pickedFile = await imagePicker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera);
    File image = File(pickedFile!.path);
    setState(() {
      _image = image;
      if (_image != null) {
        faceDetection();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    faceDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(widget.title),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null
                ? Container(
                  height: 350,
                  width: 350,
                  child: FittedBox(
                    child: SizedBox(
                      height: image.height.toDouble(),
                      width: image.width.toDouble(),
                      child: CustomPaint(
                        painter: FacePainter(faces: faces, imageFile: image),
                      ),
                    ),
                  )
            )
            : Container(
              height: 350,
              width: 350,
              child: FittedBox(
                child: SizedBox(
                  height: 350,
                  width: 350,
                  child: Icon(
                    Icons.image,
                    size: 350,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                pickImage(true);
              },
              onLongPress: () {
                pickImage(false);
              },
              child: Text("Choose"),
            ),
          ],
        ),
      )
    );
  }
}

class FacePainter extends CustomPainter {
  List<Face> faces;
  var imageFile;
  FacePainter({required this.faces, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    if (faces != null) {
      for (Face face in faces) {
        paintFaces(face, canvas, size);
      }
    }
  }

  void paintFaces(Face face, Canvas canvas, Size size) {
    final paint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;

    canvas.drawRect(face.boundingBox, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
