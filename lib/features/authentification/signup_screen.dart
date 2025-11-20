// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartalloc/utils/methods/customsnackbar.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedUserType = 'student'; // Default to student
  String? _selectedDepartment; // Department selection
  String? _selectedDepartmentcode; // Department selection
  List<Map<String, String>> _departments =
      []; // List to store departments from Firebase
  bool _isLoadingDepartments = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Department')
          .get();

      setState(() {
        _departments = snapshot.docs
            .map(
              (doc) => {
                'code': doc.data()['code'] as String,
                'title': doc.data()['title'] as String,
              },
            )
            .toList();
        _isLoadingDepartments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDepartments = false;
      });
      if (mounted) {
        showCustomSnackBar(
          context,
          message: 'Failed to load departments',
          type: SnackType.error,
        );
      }
    }
  }

  void _handleSignup() async {
  if (_formKey.currentState!.validate()) {
    try {
      // First, check if user already exists in Firestore
      final userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: emailCtrl.text)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        final status = userData['status'];

        // Check status and handle accordingly
        if (status == 1) {
          // User already exists and is active
          if (mounted) {
            showCustomSnackBar(
              context,
              message: 'User already exists with this email',
              type: SnackType.error,
            );
          }
          return;
        } else if (status == 0) {
          // User account is blocked
          if (mounted) {
            showCustomSnackBar(
              context,
              message: 'This account is blocked. Contact administrator.',
              type: SnackType.error,
            );
          }
          return;
        } else if (status == -1) {
          // User was deleted, delete old data and allow recreation
         final oldUid = userData['uid'];
          final oldEmail = userData['email'];
          final oldPassword = userData['password'];
          
          try {
            // Sign in with old credentials to delete auth user
            final oldUserCredential = await FirebaseAuth.instance
                .signInWithEmailAndPassword(
                  email: oldEmail,
                  password: oldPassword,
                );
            
            // Delete the auth user
            await oldUserCredential.user?.delete();
            
            // Delete Firestore document
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(oldUid)
                .delete();
          } catch (e) {
            print('Error deleting old user: $e');
            // If deletion fails, still try to proceed with new account creation
          }
        }
      }

      // Create new user with email and password
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtrl.text,
            password: passwordCtrl.text,
          );

      // Create user document in Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(credential.user?.uid)
          .set({
            'uid': credential.user?.uid,
            'name': nameCtrl.text,
            'email': emailCtrl.text,
            'password': passwordCtrl.text, // Consider removing this for security
            'role': _selectedUserType,
            'department': _selectedDepartment,
            'departmentcode': _selectedDepartmentcode,
            'status': 1,
          });

      if (mounted) {
        showCustomSnackBar(
          context,
          message: 'Account created successfully',
          type: SnackType.success,
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Account creation failed';
        
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already registered';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Password is too weak';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email address';
        }

        showCustomSnackBar(
          context,
          message: errorMessage,
          type: SnackType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: 'An error occurred: ${e.toString()}',
          type: SnackType.error,
        );
      }
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
                          // Logo or App Icon
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 64,
                            color: Color(0xFF8C7CD4),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign up to get started',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 32),

                          // User Type Selection
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedUserType = 'student';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedUserType == 'student'
                                            ? const Color(0xFF8C7CD4)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.school,
                                            color:
                                                _selectedUserType == 'student'
                                                ? Colors.white
                                                : Colors.grey[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Student',
                                            style: TextStyle(
                                              color:
                                                  _selectedUserType == 'student'
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedUserType = 'teacher';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedUserType == 'teacher'
                                            ? const Color(0xFF8C7CD4)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color:
                                                _selectedUserType == 'teacher'
                                                ? Colors.white
                                                : Colors.grey[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Teacher',
                                            style: TextStyle(
                                              color:
                                                  _selectedUserType == 'teacher'
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Name Field
                          TextFormField(
                            controller: nameCtrl,
                            decoration: InputDecoration(
                              labelText: "Full Name",
                              prefixIcon: const Icon(Icons.person_outlined),
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
                                return "Please enter your name";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Email Field
                          TextFormField(
                            controller: emailCtrl,
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

                          // Department Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedDepartment,
                            decoration: InputDecoration(
                              labelText: "Department",
                              prefixIcon: const Icon(Icons.business_outlined),
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
                            items: _isLoadingDepartments
                                ? []
                                : _departments
                                      .map(
                                        (department) => DropdownMenuItem(
                                          value: department['title'],
                                          child: Text(
                                            department['title'] ?? '',
                                          ),
                                        ),
                                      )
                                      .toList(),
                            onChanged: _isLoadingDepartments
                                ? null
                                : (value) {
                                    var dept = _departments.firstWhere(
                                      (t) => t['title'] == value,
                                    );

                                    setState(() {
                                      _selectedDepartmentcode = dept['code'];
                                      _selectedDepartment = value;
                                    });
                                  },
                            hint: _isLoadingDepartments
                                ? const Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Loading departments...'),
                                    ],
                                  )
                                : const Text('Select department'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please select a department";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            controller: passwordCtrl,
                            obscureText: _obscurePassword,
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
                          const SizedBox(height: 20),

                          // Confirm Password Field
                          TextFormField(
                            controller: confirmPasswordCtrl,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirmPassword
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
                                return "Please confirm your password";
                              }
                              if (value != passwordCtrl.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Signup Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _handleSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8C7CD4),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                "SIGN UP",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sign In Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  " Sign In",
                                  style: TextStyle(
                                    color: Color(0xFF8C7CD4),
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
