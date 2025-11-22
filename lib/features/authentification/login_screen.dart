// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartalloc/features/admin/home/home_screen.dart';
import 'package:smartalloc/features/authentification/model/user_model.dart';
import 'package:smartalloc/features/home/home%20_screen.dart';
import 'package:smartalloc/features/authentification/signup_screen.dart';
import 'package:smartalloc/features/landing/landing_screen.dart';
import 'package:smartalloc/features/teacher/bottomnav/dashboard/teach_bottom_nav_screen.dart';
import 'package:smartalloc/utils/methods/customsnackbar.dart';
import 'package:smartalloc/utils/variables/globalvariables.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; // Loading state

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> saveUserData(String uid, String role, String department) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid.trim());
    await prefs.setString('role', role.trim());
    await prefs.setString('department', department.trim());
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final value = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text.trim(),
        );

        final uid = value.user?.uid;

        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(uid)
            .get();

        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['status'] == 1) {
            String role = data['role'];
            String department = data['departmentcode']??'';
            guserid = uid;
            gdepartment = department;
            userdetails = UserModel.fromJson(data);

            // Save uid & role locally
            await saveUserData(uid!, role, department);

            setState(() {
              _isLoading = false;
            });

            // Navigate based on role
            if (role == 'student') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LandingScreen()),
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
              showCustomSnackBar(
                context,
                message: "Unknown role!",
                type: SnackType.error,
              );
            }
          } else {
            if (data['status'] == -1) {
              showCustomSnackBar(
                context,
                message: 'Account deleted',
                type: SnackType.error,
              );
            } else if (data['status'] == 0) {
              showCustomSnackBar(
                context,
                message: 'Account blocked by admin',
                type: SnackType.error,
              );
            }else{
              value.user?.delete();
               showCustomSnackBar(
            context,
            message: 'User not found so Create new User with same email and password'.toUpperCase(),
            type: SnackType.error,
          );
            }
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          showCustomSnackBar(
            context,
            message: 'User not found',
            type: SnackType.error,
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage;

        // Handle specific Firebase Auth errors
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email';
            break;
          case 'wrong-password':
            errorMessage = 'Invalid credentials. Please check your password';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many attempts. Please try again later';
            break;
          case 'invalid-credential':
            errorMessage =
                'Invalid credentials. Please check your email and password';
            break;
          default:
            errorMessage = 'Login failed. Please check your credentials';
        }

        showCustomSnackBar(
          context,
          message: errorMessage,
          type: SnackType.error,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        showCustomSnackBar(
          context,
          message: 'An error occurred. Please try again',
          type: SnackType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8C7CD4), Color(0xFFE8E4F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo or App Name
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 64,
                            color: Color(0xFF8C7CD4),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign in to continue',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          TextFormField(
                            controller: emailCtrl,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8C7CD4),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              }
                              if (!value.contains('@')) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            controller: passwordCtrl,
                            obscureText: _obscurePassword,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8C7CD4),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              }
                              if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Login Button with Loading Indicator
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8C7CD4),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                disabledBackgroundColor: const Color(
                                  0xFF8C7CD4,
                                ).withOpacity(0.6),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      "LOGIN",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SignupScreen(),
                                          ),
                                        );
                                      },
                                child: Text(
                                  " Sign Up",
                                  style: TextStyle(
                                    color: _isLoading
                                        ? Colors.grey
                                        : const Color(0xFF8C7CD4),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
