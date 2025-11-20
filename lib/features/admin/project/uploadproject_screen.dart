import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartalloc/utils/helper/helper_cloudinary.dart';
import 'package:smartalloc/utils/methods/customsnackbar.dart';
import 'dart:io';

import 'package:uuid/uuid.dart';

class UploadProjectPage extends StatefulWidget {
  const UploadProjectPage({super.key});

  @override
  State<UploadProjectPage> createState() => _UploadProjectPageState();
}

class _UploadProjectPageState extends State<UploadProjectPage> {
  final TextEditingController projectNameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? abstractFileName;
  String? abstractFilePath;
  String? finalProjectFileName;
  String? finalProjectFilePath;
  String? selectedDomain;
  String? selectedTeacherId;
  String? selectedTeacherName;
  String? selectedTeacherEmail;

  final List<String> domains = [
    'Flutter',
    'Dart',
    'React',
    'React Native',
    'Node.js',
    'Python',
    'Java',
    'Other'
  ];

  List<Map<String, dynamic>> teachers = [];
  bool isLoadingTeachers = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  // Fetch teachers from Firebase
  Future<void> fetchTeachers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Users')
          .where('role', isEqualTo: 'teacher')
          .where('status', isEqualTo: 1)
          .get();

      List<Map<String, dynamic>> fetchedTeachers = [];
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        fetchedTeachers.add({
          'id': doc.id,
          'name': data['name'] ?? 'Unknown Teacher',
          'department': data['department'] ?? '',
          'email': data['email'] ?? '',
        });
      }

      setState(() {
        teachers = fetchedTeachers;
        isLoadingTeachers = false;
      });

      if (teachers.isEmpty) {
        _showSnackBar("No teachers found in the database", Colors.orange);
      }
    } catch (e) {
      setState(() {
        isLoadingTeachers = false;
      });
      _showSnackBar("Error loading teachers: ${e.toString()}", Colors.red);
    }
  }

  @override
  void dispose() {
    projectNameCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  // Pick PDF file
  Future<void> pickFile(bool isAbstract) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        
        setState(() {
          if (isAbstract) {
            abstractFileName = file.name;
            abstractFilePath = file.path;
          } else {
            finalProjectFileName = file.name;
            finalProjectFilePath = file.path;
          }
        });

        _showSnackBar(
          "${file.name} selected successfully!", 
          Colors.green
        );
      }
    } catch (e) {
      _showSnackBar("Error picking file: ${e.toString()}", Colors.red);
    }
  }

  // Validate form
  bool validateForm() {
    if (projectNameCtrl.text.trim().isEmpty) {
      _showSnackBar("Please enter project name", Colors.red);
      return false;
    }

    if (descCtrl.text.trim().isEmpty) {
      _showSnackBar("Please enter project description", Colors.red);
      return false;
    }

    if (selectedDomain == null) {
      _showSnackBar("Please select a domain", Colors.red);
      return false;
    }

    if (abstractFileName == null) {
      _showSnackBar("Please upload abstract PDF", Colors.red);
      return false;
    }

    if (finalProjectFileName == null) {
      _showSnackBar("Please upload final project PDF", Colors.red);
      return false;
    }

    if (selectedTeacherId == null) {
      _showSnackBar("Please select a teacher", Colors.red);
      return false;
    }

    return true;
  }

  // Submit project to Firebase
  Future<void> submitProject() async {
    if (!validateForm()) return;
    var uuid=Uuid();
    var id  =uuid.v4();

    setState(() {
      isSubmitting = true;
    });
var abstracturl= await CloudneryUploader().uploadFile(XFile(abstractFilePath!));
var finalprojecturl= await CloudneryUploader().uploadFile(XFile(finalProjectFilePath!));
    try {
      // Create project document in Firestore
      Map<String, dynamic> projectData = {
        'id':id,
        'projectName': projectNameCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'domain': selectedDomain,
        'teacherId': selectedTeacherId,
        'teacherName': selectedTeacherName,
        'teacherEmail': selectedTeacherEmail,
        'abstractfileurl': abstracturl,
        'finalProjectFileurl': finalprojecturl,
        'uploadAt': FieldValue.serverTimestamp(),
        'status': 'pending', 
      };

      // Add to Firestore
        _firestore
          .collection('Projects').doc(id)
          .set(projectData).then((value) {
           
      _showSnackBar(
        "Project uploaded successfully! ", 
        Colors.green
      );// Wait a moment to show success message
     

      // Navigate back
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
          },).onError((error, stackTrace) {
              setState(() {
        isSubmitting = false;
      });
      showCustomSnackBar(context, message: "failed", type: SnackType.error);

          },);

     

      
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      _showSnackBar(
        "Error uploading project: ${e.toString()}", 
        Colors.red
      );
    }
  }

  // Show snackbar helper
  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Project"),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF6200EA),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF6200EA)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Fill in all the details to upload your project",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Project Name
                TextField(
                  controller: projectNameCtrl,
                  decoration: InputDecoration(
                    labelText: "Project Name",
                    hintText: "Enter your project name",
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Project Description",
                    hintText: "Describe your project in detail",
                    prefixIcon: const Icon(Icons.description),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),

                // Domain Dropdown
                DropdownButtonFormField<String>(
                  value: selectedDomain,
                  decoration: InputDecoration(
                    labelText: "Select Domain",
                    prefixIcon: const Icon(Icons.code),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: domains.map((String domain) {
                    return DropdownMenuItem<String>(
                      value: domain,
                      child: Text(domain),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDomain = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Teacher Selection Dropdown
                DropdownButtonFormField<String>(
                  value: selectedTeacherId,
                  decoration: InputDecoration(
                    labelText: "Select Guide Teacher",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: isLoadingTeachers
                      ? []
                      : teachers.map((teacher) {
                          return DropdownMenuItem<String>(
                            value: teacher['id'],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${teacher['name']} - ${teacher['department']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                               
                              ],
                            ),
                          );
                        }).toList(),
                  onChanged: isLoadingTeachers
                      ? null
                      : (String? newValue) {
                          setState(() {
                            selectedTeacherId = newValue;
                            var teacher = teachers.firstWhere(
                              (t) => t['id'] == newValue,
                            );
                            selectedTeacherName = teacher['name'];
                            selectedTeacherEmail = teacher['email'];
                          });
                        },
                  hint: isLoadingTeachers
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
                            Text("Loading teachers..."),
                          ],
                        )
                      : Text(
                          teachers.isEmpty
                              ? "No teachers available"
                              : "Choose a teacher",
                        ),
                ),
                const SizedBox(height: 24),

                // PDFs Section Header
                const Text(
                  "Upload Required Documents",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6200EA),
                  ),
                ),
                const SizedBox(height: 12),

                // Abstract PDF Upload
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 32,
                    ),
                    title: const Text(
                      "Abstract PDF",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      abstractFileName ?? "No file selected",
                      style: TextStyle(
                        color: abstractFileName != null
                            ? Colors.green
                            : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    trailing: ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text("Upload"),
                      onPressed: () => pickFile(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Final Project PDF Upload
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 32,
                    ),
                    title: const Text(
                      "Final Project PDF",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      finalProjectFileName ?? "No file selected",
                      style: TextStyle(
                        color: finalProjectFileName != null
                            ? Colors.green
                            : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    trailing: ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text("Upload"),
                      onPressed: () => pickFile(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : submitProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    child: isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Uploading...",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle),
                              SizedBox(width: 8),
                              Text(
                                "Submit Project",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}