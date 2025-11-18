import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartalloc/features/admin/home/home_screen.dart';
import 'package:smartalloc/features/authentification/login_screen.dart';
import 'package:smartalloc/features/home/home%20_screen.dart';
import 'package:smartalloc/features/teacher/bottomnav/bottom_nav_screen.dart';
import 'package:smartalloc/utils/methods/customsnackbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 3), () async{
       SharedPreferences prefs = await SharedPreferences.getInstance();
 String? uid= await prefs.getString('uid', );
  String? role=await prefs.getString('role', );
  if (uid!=null && role!=null) {
     if (role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        } 
        else if (role == 'teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => TeacherDashboard()),
          );
        } 
        else if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminHomeScreen()),
          );
        } 
        else {
          showCustomSnackBar(context,
              message: "Unknown role!", type: SnackType.error);
        }
    
  }else{
       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(context) => LoginScreen(),), (route) => false,);
  }
   
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
