import 'dart:async';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'first_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => FirstScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body:Center(
            child: Image.asset(
              'assets/main-logo-project.png', // Replace 'assets/logo.png' with your image path
              width: 200,
              height: 200,
            ),
          ),

    );
  }
}