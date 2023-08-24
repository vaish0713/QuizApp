import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' ;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaishnavi/Quiz.dart';

import 'BottomNavigator.dart';
import 'Storage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
final nameController = TextEditingController();
String _name = ''; // Initialize _name as an empty string
String imageUrl='';

@override
void dispose() {
  nameController.dispose();
  super.dispose();
}

void _submitForm() {
  setState(() {
    _name = nameController.text.trim();
  });
  if (_name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Please enter the name'),
    ));
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Questions(playerName: _name),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNav(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Enter your name',
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Start Quiz'),
              ),
            ),
            IconButton(onPressed: () async {
              ImagePicker imagePicker=ImagePicker();
              XFile? file =await imagePicker.pickImage(source: ImageSource.camera);
              print('${file?.path}');
              if(file==null){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please enter the name'),
                ));
              }
              String uniqueFileName=DateTime.now().millisecondsSinceEpoch.toString();
              Reference referenceRoot=FirebaseStorage.instance.ref();
              Reference referenceDirImages=referenceRoot.child('images');
              Reference referenceImageToUpload=referenceDirImages.child(uniqueFileName);
              try{
                referenceImageToUpload.putFile(File(file!.path));
                imageUrl=await referenceImageToUpload.getDownloadURL();
              }
              catch(error){

              }
              }, icon: const Icon(Icons.camera_alt)),
          ],
        ),
      ),
    );
  }
}

class MyHomePageState extends StatelessWidget {
  final String title;
  const MyHomePageState({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<PlayerScore?>(
        future: _getPlayerScore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final playerScore = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Player Name: ${playerScore.playerName}'),
                  Text('Score: ${playerScore.score}'),
                ],
              ),
            );
          } else {
            return Text('No player data found.');
          }
        },
      ),
    );
  }

  Future<PlayerScore?> _getPlayerScore() async {
    final prefs = await SharedPreferences.getInstance();
    final playerScoreJson = prefs.getString('playerScore');
    if (playerScoreJson != null) {
      final playerScoreData = jsonDecode(playerScoreJson);
      return PlayerScore.fromJson(playerScoreData);
    }
    return null;
  }
}

