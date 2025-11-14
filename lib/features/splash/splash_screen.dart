import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartalloc/features/authentification/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(context) => LoginScreen(),), (route) => false,);
    },);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 176, 164, 245), Colors.white],
            begin: AlignmentGeometry.topLeft,
            end: AlignmentGeometry.bottomLeft,
          ),
        ),
        child: Center(
          child: Image.asset("assets/images/logo.png", height: 150, width: 150),
        ),
      ),
    );
  }
}
