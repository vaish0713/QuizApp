import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vaishnavi/BottomNavigator.dart';
import 'package:vaishnavi/Chart.dart';
import 'package:vaishnavi/Game.dart';
import 'package:vaishnavi/Home.dart';
import 'package:vaishnavi/Login.dart';
import 'package:vaishnavi/Quiz.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes:{
        '/' :(context) => LoginPage(),
        '/home':(context) => const MyHomePage(title: 'Home Page'),
        '/quiz' :(context) => const Questions(playerName: 'Hello',),
        '/chart' :(context) => BarGraphPage(numCorrectAnswers: 0, numWrongAnswers: 0,),
        '/bottomnavigator': (context) => BottomNav(),
        '/game':(context) => const GamePage(),
      },
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

