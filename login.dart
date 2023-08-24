import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vaishnavi/Login.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final userStream = FirebaseAuth.instance.authStateChanges();
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future <void> anLogin() async{
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch(e){
      const snackBar = SnackBar(
        content: Text('Wrong Password'),
      );
    }
  }
  void navigateToHomePage() {
    Navigator.pushReplacementNamed(context, '/home'); // Replace '/home' with your actual home route
  }

  Future <void> signOut() async{
    await FirebaseAuth.instance.signOut();
  }
  Future <void> GoolgeLogin() async{
    try{
      final googleUser= await GoogleSignIn().signIn();
      if(googleUser == null) return;
      final googleAuth=await googleUser.authentication;
      final authCredential =GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(authCredential);
      if (userCredential.user != null) {
        navigateToHomePage(); // Navigate to the home page after successful login
      }
  }
    on FirebaseException catch(e){
      const snackBar = SnackBar(
        content: Text('Enter proper credentials'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login',
          style: TextStyle(color: Colors.black),
        ),

      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                child: Text('Login'),
                onPressed: () {
                  anLogin();
                  },
              ),
              ElevatedButton(
                onPressed:(){
                  GoolgeLogin();
                },
                  child: Text('Google Login In')
              ),
            ],
          ),
        ),
      ),
    );
  }
}
