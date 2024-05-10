import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mystic_todo/home.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _user != null ? const HomeScreen() : _googleSignInButton(),
    );
  }

  Widget _googleSignInButton() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Sign in", style: TextStyle(fontSize: 26),),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      backgroundColor: Colors.black12,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 350,
              child: ElevatedButton(
                onPressed: _handleGoogleSignIn,
                child: Row(children: [
                  Image.asset('assets/images/logo.png', width: 26, height: 26,),
                  const Text('    Continue with Google', style: TextStyle(fontSize: 18, color: Colors.black),)
                ],),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGoogleSignIn() async{
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await  googleUser?.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken
      );
      UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      print(userCred.user?.displayName);
    } catch (err) {
      print(err);
    }
  }
}
