import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xFFF5A623),
        accentColor: Color(0xFFF5A623),
      ),
      home: MyHomePage(title: 'Devtreff Developer Detector'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _happyCounter = 0;
  int _sleepyCounter = 0;
  File _image;

  void _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(
        FaceDetectorOptions(enableClassification: true));
    final List<Face> faces = await faceDetector.processImage(visionImage);
    int happyCounter = faces.fold(0, (value, face) {
      if (face.smilingProbability > 0.5) {
        value++;
      }
      return value;
    });

    int sleepyCounter = faces.fold(0, (value, face) {
      if (face.leftEyeOpenProbability < 0.5 ||
          face.rightEyeOpenProbability < 0.5) {
        value++;
      }
      return value;
    });


    setState(() {
      _image = image;
      _happyCounter = happyCounter;
      _sleepyCounter = sleepyCounter;
      _counter = faces.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 250,
                width: 250,
                child: _image != null ? Image.file(_image) : Container(),
              ),
              SizedBox(height: 20,),
              SizedBox(height: 10,),
              Row(
                children: <Widget>[
                  buildCircleAvatar(context, Icons.code),
                  SizedBox(width: 20),
                  Text(
                    'Developer Faces detected    $_counter',
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: <Widget>[
                  buildCircleAvatar(context, Icons.tag_faces),
                  SizedBox(width: 20),
                  Text(
                    'Happy Faces detected    $_happyCounter',
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: <Widget>[
                  buildCircleAvatar(context, Icons.airline_seat_flat),
                  SizedBox(width: 20),
                  Text(
                    'Sleepy Faces detected    $_sleepyCounter',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Increment',
        child: Icon(Icons.camera_alt, color: Colors.white,),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  CircleAvatar buildCircleAvatar(BuildContext context, IconData icon) {
    return CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(icon, color: Colors.white,),);
  }
}
