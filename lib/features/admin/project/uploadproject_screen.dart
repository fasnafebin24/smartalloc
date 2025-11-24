// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartalloc/utils/contants/colors.dart';
import 'package:smartalloc/utils/helper/helper_cloudinary.dart';
import 'package:smartalloc/utils/methods/customsnackbar.dart';

import 'package:uuid/uuid.dart';

class UploadProjectPage extends StatefulWidget {
  const UploadProjectPage({super.key});

  @override
  State<UploadProjectPage> createState() => _UploadProjectPageState();
}

class _UploadProjectPageState extends State<UploadProjectPage> {
  final TextEditingController projectNameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController startYearCtrl = TextEditingController();
  final TextEditingController endYearCtrl = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  String? abstractFileName;
  String? abstractFilePath;
  String? finalProjectFileName;
  String? finalProjectFilePath;
  
  // Changed to List for multiple selection
  List<String> selectedDomains = [];
  
  String? selectedTeacherId;
  String? selectedTeacherName;
  String? selectedTeacherEmail;
  String? _selectedDepartment;
  String? _selectedDepartmentCode;
  List<Map<String, dynamic>> _departments = [];
  bool _isLoadingDepartments = true;

  // Changed to fetch from Firestore
  List<String> domains = [];
  bool _isLoadingDomains = true;

  List<Map<String, dynamic>> teachers = [];
  bool isLoadingTeachers = true;
  bool isSubmitting = false;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    fetchTeachers();
    _loadDepartments();
    _loadDomains(); // Load domains from Firestore
  }

  // Fetch domains from Firestore
  Future<void> _loadDomains() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Domains')
          .get();

      setState(() {
        domains = snapshot.docs
            .map((doc) => doc.data()['value'] as String)
            .toList();
        _isLoadingDomains = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDomains = false;
      });
      if (mounted) {
        showCustomSnackBar(
          context,
          message: 'Failed to load domains',
          type: SnackType.error,
        );
      }
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

  Future<void> fetchTeachers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Users')
          .where('role', isEqualTo: 'teacher')
          .where('status', isEqualTo: 1)
          .where('departmentcode', isEqualTo: _selectedDepartmentCode)
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
    startYearCtrl.dispose();
    endYearCtrl.dispose();
    super.dispose();
  }

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

        _showSnackBar("${file.name} selected successfully!", Colors.green);
      }
    } catch (e) {
      _showSnackBar("Error picking file: ${e.toString()}", Colors.red);
    }
  }

  bool validateForm() {
    if (projectNameCtrl.text.trim().isEmpty) {
      _showSnackBar("Please enter project name", Colors.red);
      return false;
    }

    if (descCtrl.text.trim().isEmpty) {
      _showSnackBar("Please enter project description", Colors.red);
      return false;
    }
    if (startYearCtrl.text.trim().isEmpty) {
      _showSnackBar("Please enter Start Year", Colors.red);
      return false;
    }
    if (endYearCtrl.text.trim().isEmpty) {
      _showSnackBar("Please enter Passout Year", Colors.red);
      return false;
    }

    // Updated validation for multiple domains
    if (selectedDomains.isEmpty) {
      _showSnackBar("Please select at least one domain", Colors.red);
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
    if (_selectedDepartment == null) {
      _showSnackBar("Please select a Department", Colors.red);
      return false;
    }
    if (_selectedImage == null) {
      _showSnackBar("Please select Project Thumbnail", Colors.red);
      return false;
    }

    return true;
  }

  Future<void> submitProject() async {
    if (!validateForm()) return;
    var uuid = Uuid();
    var id = uuid.v4();

    setState(() {
      isSubmitting = true;
    });
    var abstracturl = await CloudneryUploader().uploadFile(
      XFile(abstractFilePath!),
    );
    var finalprojecturl = await CloudneryUploader().uploadFile(
      XFile(finalProjectFilePath!),
    );
    var thumbanilUrl = await CloudneryUploader().uploadFile(
      _selectedImage!,
    );
    try {
      // Join selected domains with comma
      String domainsString = selectedDomains.join(', ');
      
      Map<String, dynamic> projectData = {
        'id': id,
        'projectName': projectNameCtrl.text,
        'namefilter': [
          for (int i = 1; i <= projectNameCtrl.text.trim().length; i++)
            projectNameCtrl.text.trim().substring(0, i),
        ],
        'description': descCtrl.text.trim(),
        'domain': domainsString, // Store as joined string
        'teacherId': selectedTeacherId,
        'teacherName': selectedTeacherName,
        'teacherEmail': selectedTeacherEmail,
        'abstractfileurl': abstracturl,
        'finalProjectFileurl': finalprojecturl,
        'uploadAt': FieldValue.serverTimestamp(),
        'batch': '${startYearCtrl.text}-${endYearCtrl.text}',
        'startyear': startYearCtrl.text,
        'endyear': endYearCtrl.text,
        'department': _selectedDepartment,
        'departmentcode': _selectedDepartmentCode,
        'logoUrl': thumbanilUrl,
        'status': 'pending',
      };

      _firestore
          .collection('Projects')
          .doc(id)
          .set(projectData)
          .then((value) {
            _showSnackBar(
              "Project uploaded successfully! ",
              Colors.green,
            );

            if (mounted) {
              Navigator.pop(context, true);
            }
          })
          .onError((error, stackTrace) {
            setState(() {
              isSubmitting = false;
            });
            showCustomSnackBar(
              context,
              message: "failed",
              type: SnackType.error,
            );
          });
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      _showSnackBar("Error uploading project: ${e.toString()}", Colors.red);
    }
  }

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

  // Show multi-select dialog with domains from Firestore
  Future<void> _showDomainSelectionDialog() async {
    if (_isLoadingDomains) {
      _showSnackBar("Domains are still loading, please wait...", Colors.orange);
      return;
    }

    if (domains.isEmpty) {
      _showSnackBar("No domains available. Please add domains first.", Colors.orange);
      return;
    }

    List<String> tempSelected = List.from(selectedDomains);
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Domains'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: domains.map((domain) {
                    return CheckboxListTile(
                      title: Text(domain),
                      value: tempSelected.contains(domain),
                      onChanged: (bool? checked) {
                        setDialogState(() {
                          if (checked == true) {
                            tempSelected.add(domain);
                          } else {
                            tempSelected.remove(domain);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedDomains = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: const Text('Done',style: TextStyle(color: AppColors.whiteColor),),
                ),
              ],
            );
          },
        );
      },
    );
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

                // Multi-select Domain Field - Now loading from Firestore
                InkWell(
                  onTap: _isLoadingDomains ? null : _showDomainSelectionDialog,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Select Domains",
                      prefixIcon: _isLoadingDomains
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : const Icon(Icons.code),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    child: _isLoadingDomains
                        ? const Text(
                            'Loading domains...',
                            style: TextStyle(color: Colors.grey),
                          )
                        : selectedDomains.isEmpty
                            ? Text(
                                domains.isEmpty
                                    ? 'No domains available'
                                    : 'Tap to select domains',
                                style: const TextStyle(color: Colors.grey),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: selectedDomains.map((domain) {
                                  return Chip(
                                    label: Text(domain),
                                    deleteIcon: const Icon(Icons.close, size: 18),
                                    onDeleted: () {
                                      setState(() {
                                        selectedDomains.remove(domain);
                                      });
                                    },
                                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                                    labelStyle: const TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 13,
                                    ),
                                  );
                                }).toList(),
                              ),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _selectedDepartment,
                  decoration: InputDecoration(
                    labelText: "Department",
                    prefixIcon: const Icon(Icons.business_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: _isLoadingDepartments
                      ? []
                      : _departments
                            .map(
                              (department) => DropdownMenuItem<String>(
                                value: department['title'],
                                child: Text(department['title']),
                              ),
                            )
                            .toList(),
                  onChanged: _isLoadingDepartments
                      ? null
                      : (value) {
                          var deprt = _departments.firstWhere(
                            (t) => t['title'] == value,
                          );
                          setState(() {
                            _selectedDepartment = value;
                            _selectedDepartmentCode = deprt['code'];
                          });
                          fetchTeachers();
                        },
                  hint: _isLoadingDepartments
                      ? const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Loading departments...'),
                          ],
                        )
                      : const Text('Select department'),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: selectedTeacherId,
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
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startYearCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Start Year",
                          hintText: "ex : 2019",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: endYearCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Passout Year",
                          hintText: "ex : 2022",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Thumbnail Image Upload
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
                      Icons.image,
                      color: Colors.blue,
                      size: 32,
                    ),
                    title: const Text(
                      "Project Thumbnail",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      _selectedImage != null ? "Image selected" : "No image selected",
                      style: TextStyle(
                        color: _selectedImage != null
                            ? Colors.green
                            : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    trailing: ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library, size: 18),
                      label: const Text("Upload"),
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  "Upload Required Documents",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6200EA),
                  ),
                ),
                const SizedBox(height: 12),

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
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

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
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

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