import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartalloc/features/splash/splash_screen.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smartalloc',
      debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF8674EC),
            titleTextStyle: TextStyle(
              fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
            ),
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          )
        ),
      home: SplashScreen(),
    );
  }
}

