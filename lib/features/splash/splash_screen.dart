// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartalloc/features/admin/home/home_screen.dart';
import 'package:smartalloc/features/authentification/login_screen.dart';
import 'package:smartalloc/features/home/home%20_screen.dart';
import 'package:smartalloc/features/teacher/bottomnav/dashboard/teach_bottom_nav_screen.dart';
import 'package:smartalloc/utils/methods/customsnackbar.dart';
import 'package:smartalloc/utils/variables/globalvariables.dart';

import '../authentification/model/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 0), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString('uid');
      String? role = prefs.getString('role');
      String? department = prefs.getString('department');

      if (uid != null && role != null) {
        guserid = uid;
        gdepartment = department;
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(uid)
            .get();
        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['status'] == 1) {
            userdetails = UserModel.fromJson(data);
            setState(() {});
            if (role == 'student') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
            } else if (role == 'teacher') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => TeacherDashboard()),
              );
            } else if (role == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AdminHomeScreen()),
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
              showCustomSnackBar(
                context,
                message: "Unknown role!",
                type: SnackType.error,
              );
            }
          }
        } else {
          showCustomSnackBar(
            context,
            message: "Unknown role!",
            type: SnackType.error,
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        }
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    });
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
            colors: [const Color(0xFFB0A4F5), Colors.white],
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
