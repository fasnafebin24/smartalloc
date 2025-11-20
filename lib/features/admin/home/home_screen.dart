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
  @override
  void dispose() {
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
                        "Review",
                        Icons.rate_review_outlined,
                        const Color(0xFF00BCD4),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReviewPage(),
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

// Review Page
class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review"),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.assignment, color: Color(0xFF00BCD4)),
                title: const Text("Review Pending Projects"),
                trailing: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Opening pending projects...")),
                    );
                  },
                  child: const Text("Review"),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.feedback, color: Color(0xFF00BCD4)),
                title: const Text("Review Student Submissions"),
                trailing: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Opening submissions...")),
                    );
                  },
                  child: const Text("Review"),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.comment, color: Color(0xFF00BCD4)),
                title: const Text("Review Feedback & Comments"),
                trailing: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Opening feedback...")),
                    );
                  },
                  child: const Text("Review"),
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