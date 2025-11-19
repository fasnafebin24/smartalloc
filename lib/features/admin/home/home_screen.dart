import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartalloc/features/admin/manage/managestudent_screen.dart';
import 'package:smartalloc/features/admin/manage/manageteacher_screen.dart';
import 'package:smartalloc/features/authentification/login_screen.dart';

import '../project/uploadproject_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8C7CD4), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Admin Dashboard",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Manage your system",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Search Bar
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: "Search projects, users...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF8C7CD4)),
                    suffixIcon: const Icon(Icons.filter_list, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Admin Action Cards Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      adminActionCard(
                        "Manage students",
                        Icons.people_outline,
                        const Color(0xFF4CAF50),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ManageUsersPage(),
                            ),
                          );
                        },
                      ),
                      adminActionCard(
                        "Manage Teachers",
                        Icons.school_outlined,
                        const Color(0xFF2196F3),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ManageTeacherPage(),
                            ),
                          );
                        },
                      ),
                      adminActionCard(
                        "Upload Project",
                        Icons.cloud_upload_outlined,
                        const Color(0xFFFF9800),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UploadProjectPage(),
                            ),
                          );
                        },
                      ),
                      adminActionCard(
                        "Upload Abstract",
                        Icons.description_outlined,
                        const Color(0xFF9C27B0),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UploadAbstractPage(),
                            ),
                          );
                        },
                      ),
                      adminActionCard(
                        "Edit Project",
                        Icons.edit_outlined,
                        const Color(0xFFE91E63),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProjectPage(),
                            ),
                          );
                        },
                      ),
                      adminActionCard(
                        "Make Report",
                        Icons.assessment_outlined,
                        const Color(0xFF00BCD4),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MakeReportPage(),
                            ),
                          );
                        },
                      ),
                      adminActionCard(
                        "View Projects",
                        Icons.visibility_outlined,
                        const Color(0xFF673AB7),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ViewProjectsPage(),
                            ),
                          );
                        },
                      ),
                      adminActionCard(
                        "Update Project",
                        Icons.update_outlined,
                        const Color(0xFFFF5722),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UpdateProjectPage(),
                            ),
                          );
                        },
                      ),
                      adminActionCard(
                        "Approve Projects",
                        Icons.check_circle_outline,
                        const Color(0xFF4CAF50),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ApproveProjectsPage(),
                            ),
                          );
                        },
                      ),
                       adminActionCard(
                        "Logout",
                        Icons.logout,
                        const Color.fromARGB(255, 212, 5, 5),
                        ()async {
                            SharedPreferences prefs = await  SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(context) => LoginScreen(),), (route) => false,);
                // Add your logout logic here
                // For example: navigate to login screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Logged out successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
                         
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget adminActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// Upload Abstract Page
class UploadAbstractPage extends StatefulWidget {
  const UploadAbstractPage({super.key});

  @override
  State<UploadAbstractPage> createState() => _UploadAbstractPageState();
}

class _UploadAbstractPageState extends State<UploadAbstractPage> {
  final TextEditingController abstractCtrl = TextEditingController();

  @override
  void dispose() {
    abstractCtrl.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Abstract"),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: abstractCtrl,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: "Project Abstract",
                hintText: "Enter the abstract content here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (abstractCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter abstract content!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Abstract uploaded successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Submit Abstract"),
            ),
          ],
        ),
      ),
    );
  }
}

// Edit Project Page
class EditProjectPage extends StatelessWidget {
  const EditProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Project"),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 7,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.folder, color: Color(0xFFE91E63)),
              title: Text("Project ${index + 1}"),
              subtitle: const Text("Tap to edit details"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Opening Project ${index + 1} for editing")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Make Report Page
class MakeReportPage extends StatelessWidget {
  const MakeReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make Report"),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.description, color: Color(0xFF00BCD4)),
                title: const Text("Generate Monthly Report"),
                trailing: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Generating monthly report...")),
                    );
                  },
                  child: const Text("Generate"),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart, color: Color(0xFF00BCD4)),
                title: const Text("Project Statistics Report"),
                trailing: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Generating statistics report...")),
                    );
                  },
                  child: const Text("Generate"),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.people, color: Color(0xFF00BCD4)),
                title: const Text("User Activity Report"),
                trailing: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Generating activity report...")),
                    );
                  },
                  child: const Text("Generate"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// View Projects Page
class ViewProjectsPage extends StatelessWidget {
  const ViewProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Projects"),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 7,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.folder_open, color: Color(0xFF673AB7)),
              title: Text("Project ${index + 1}"),
              subtitle: const Text("4.5 ⭐ • 12 reviews"),
              trailing: const Icon(Icons.visibility),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Viewing Project ${index + 1}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Update Project Page
class UpdateProjectPage extends StatelessWidget {
  const UpdateProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Project"),
        backgroundColor: const Color.fromARGB(255, 119, 78, 65),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 7,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.update, color: Color(0xFFFF5722)),
              title: Text("Project ${index + 1}"),
              subtitle: const Text("Last updated: 2 days ago"),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Updating Project ${index + 1}")),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// Approve Projects Page
class ApproveProjectsPage extends StatelessWidget {
  const ApproveProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Approve Projects"),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.pending_actions, color: Colors.orange),
              title: Text("Project ${index + 1}"),
              subtitle: const Text("Pending approval"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Project ${index + 1} approved!")),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Project ${index + 1} rejected!")),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}