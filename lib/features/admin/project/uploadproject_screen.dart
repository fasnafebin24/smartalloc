import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadProjectPage extends StatefulWidget {
  const UploadProjectPage({super.key});

  @override
  State<UploadProjectPage> createState() => _UploadProjectPageState();
}

class _UploadProjectPageState extends State<UploadProjectPage> {
  final TextEditingController projectNameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  String? abstractFileName;
  String? finalProjectFileName;
  String? selectedDomain;
  String? selectedTeacher;

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

  final List<String> teachers = [
    'Dr. John Smith',
    'Prof. Sarah Johnson',
    'Dr. Michael Brown',
    'Prof. Emily Davis',
    'Dr. David Wilson',
  ];

  @override
  void dispose() {
    projectNameCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> pickFile(bool isAbstract) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        if (isAbstract) {
          abstractFileName = result.files.single.name;
        } else {
          finalProjectFileName = result.files.single.name;
        }
      });
    }
  }

  void submitProject() {
    if (projectNameCtrl.text.isEmpty ||
        descCtrl.text.isEmpty ||
        abstractFileName == null ||
        finalProjectFileName == null ||
        selectedDomain == null ||
        selectedTeacher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and upload required PDFs!"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Project uploaded successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Project"),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF6200EA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Name
            TextField(
              controller: projectNameCtrl,
              decoration: InputDecoration(
                labelText: "Project Name",
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
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Project Description",
                prefixIcon: const Icon(Icons.description),
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

            // Abstract PDF Upload
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text("Upload Abstract PDF"),
                subtitle: Text(
                  abstractFileName ?? "No file selected",
                  style: TextStyle(
                    color: abstractFileName != null
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () => pickFile(true),
                  color: const Color(0xFFFF9800),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Final Project PDF Upload
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text("Upload Final Project PDF"),
                subtitle: Text(
                  finalProjectFileName ?? "No file selected",
                  style: TextStyle(
                    color: finalProjectFileName != null
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () => pickFile(false),
                  color: const Color(0xFFFF9800),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Teacher Selection Dropdown
            DropdownButtonFormField<String>(
              value: selectedTeacher,
              decoration: InputDecoration(
                labelText: "Select Teacher",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: teachers.map((String teacher) {
                return DropdownMenuItem<String>(
                  value: teacher,
                  child: Text(teacher),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTeacher = newValue;
                });
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: submitProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle),
                  SizedBox(width: 8),
                  Text(
                    "Submit Project",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}