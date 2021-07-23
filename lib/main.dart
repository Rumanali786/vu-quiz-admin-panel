import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UploadClass(),
    );
  }
}

class UploadClass extends StatefulWidget {
  const UploadClass({Key? key}) : super(key: key);

  @override
  _UploadClassState createState() => _UploadClassState();
}

class _UploadClassState extends State<UploadClass> {
  TextEditingController bookName = TextEditingController();
  TextEditingController ownerName = TextEditingController();
  TextEditingController paperTerm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TextField(
              controller: bookName,
              decoration: InputDecoration(hintText: "Book Name"),
            ),
            TextField(
              controller: ownerName,
              decoration: InputDecoration(hintText: "Owner NAme"),
            ),
            TextField(
              controller: paperTerm,
              decoration: InputDecoration(hintText: "Final or mid term?"),
            ),
            ElevatedButton(
                onPressed: () {
                  getPdfAndUpload();
                },
                child: Text("Upload Data")),
          ],
        ),
      ),
    );
  }

  late firebase_storage.UploadTask uploadTask;

  Future getPdfAndUpload() async {
    var rng = new Random();
    String randomName = "";
    for (var i = 0; i < 20; i++) {
      print(rng.nextInt(100));
      randomName += rng.nextInt(100).toString();
    }
    FilePickerResult? file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    String fileName = '${randomName}.pdf';
    print(fileName);
    PlatformFile result = file!.files.first;
    print(result.bytes);
    // savePdf(result.bytes!, fileName);
    firebase_storage.Reference ref =
        FirebaseStorage.instance.ref().child(fileName);
    uploadTask = ref.putData(result.bytes!);
    uploadTask.whenComplete(() => {
          ref.getDownloadURL().then((value) => {
                print(value),
                documentFileUpload(value),
              })
        });
  }

  void documentFileUpload(String str) {
    var data = {
      "PDF": str,
    };
    FirebaseFirestore.instance
        .collection(bookName.text)
        .doc()
        .collection(ownerName.text)
        .doc()
        .collection(paperTerm.text)
        .doc()
        .set(data);
  }
}
