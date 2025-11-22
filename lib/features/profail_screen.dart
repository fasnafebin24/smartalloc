// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartalloc/features/settings/report_screen.dart';
import 'package:smartalloc/utils/contants/colors.dart';
import 'dart:io';
import '../utils/helper/helper_cloudinary.dart';
import '../utils/variables/globalvariables.dart';
import 'authentification/model/user_model.dart';
// Import your Cloudinary upload function
// import '../services/cloudinary_service.dart'; // Adjust path as needed

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _role;
  String? _department;
  String? _avatarUrl;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _nameController.text = userdetails?.name ?? "";
        _emailController.text = userdetails?.email ?? '';
        _role = userdetails?.role ?? '';
        _department = userdetails?.department;
        _avatarUrl = userdetails?.avatarUrl; 
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = XFile(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        String? newAvatarUrl = _avatarUrl;

        // Upload new image if selected
        if (_selectedImage != null) {
          setState(() => _isUploadingImage = true);
          newAvatarUrl = await CloudneryUploader().uploadFile(_selectedImage!);
          setState(() => _isUploadingImage = false);

          if (newAvatarUrl == null) {
            throw Exception('Failed to upload image');
          }
        }

        // Generate namefilter array
        List<String> nameFilter = [];
        for (int i = 1; i <= _nameController.text.length; i++) {
          nameFilter.add(_nameController.text.substring(0, i));
        }

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userdetails?.uid)
            .update({
          'name': _nameController.text,
          'namefilter': nameFilter,
          'avatarUrl': newAvatarUrl ?? '',
        });

        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(userdetails?.uid)
            .get();
        
        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['status'] == 1) {
            userdetails = UserModel.fromJson(data);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          if (userdetails?.role=='teacher') {
            Navigator.pop(context, userdetails);
          }
          
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
            _isUploadingImage = false;
          });
        }
      }
    }
  }

  Widget _buildAvatar() {
    if (_selectedImage != null) {
      // Show selected image from gallery
      return CircleAvatar(
        radius: 60,
        backgroundImage: _selectedImage != null
      ? FileImage(File(_selectedImage!.path))
      : null,
      );
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      // Show existing avatar from URL
      return CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(_avatarUrl!),
        backgroundColor: Colors.white,
        child: _isUploadingImage
            ? const CircularProgressIndicator(color: Colors.white)
            : null,
      );
    } else {
      // Show default avatar with initial
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        child: Text(
          _nameController.text.isNotEmpty
              ? _nameController.text[0].toUpperCase()
              : '?',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 170, 169, 243),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'),backgroundColor:  Color.fromARGB(255, 170, 169, 243),actions: [
        TextButton(onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ReportSubmissionScreen(),));
        }, child: Text('Report App',style: TextStyle(color: AppColors.whiteColor,fontWeight: FontWeight.w500),))
      ],),
      backgroundColor: const Color.fromARGB(255, 170, 169, 243),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Column(
              children: [
      
                // Avatar with Edit
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _buildAvatar(),
                    GestureDetector(
                      onTap: _isSaving ? null : _pickImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: _isUploadingImage
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
      
                const SizedBox(height: 30),
      
                // Form Fields
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name Field
                            const Text(
                              "NAME",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              enabled: !_isSaving,
                              decoration: InputDecoration(
                                hintText: "Enter your name",
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
      
                            const SizedBox(height: 20),
      
                            // Email Field
                            const Text(
                              "EMAIL ADDRESS",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              enabled: false,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: "Enter email address",
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
      
                            const SizedBox(height: 20),
      
                            // Read-only fields
                            const Text(
                              "ROLE",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _role ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
      
                            const SizedBox(height: 20),
      
                            const Text(
                              "DEPARTMENT",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _department ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
      
                            const SizedBox(height: 30),
      
                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    170,
                                    169,
                                    243,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Save Changes",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
      
                            const SizedBox(height: 16),
      
                            // Cancel Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 170, 169, 243),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 170, 169, 243),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}