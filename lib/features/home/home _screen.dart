// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartalloc/features/authentification/login_screen.dart';

// Add these dependencies to pubspec.yaml:
// flutter_pdfview: ^1.3.2
// path_provider: ^2.1.1
// file_picker: ^6.1.1

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController namectrl = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 140, 124, 212), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 50),
              // Logout Button
              Align(
                alignment: Alignment.topRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search here",
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  suffixIcon: const Icon(Icons.filter_list, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    projectCard("Project 1", true, 4.8),
                    projectCard("Project 2", false, 4.9),
                    projectCard("Project 3", true, 4.7),
                    projectCard("Project 4", false, 4.6),
                    projectCard("Project 5", true, 4.5),
                    projectCard("Project 6", true, 4.7),
                    projectCard("Project 7", false, 5.4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: ()async {
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget projectCard(String title, bool isFav, double rating) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailPage(
              title: title,
              rating: rating,
              isFavorite: isFav,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.orange,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  Text(rating.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const Spacer(),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Project Detail Page
class ProjectDetailPage extends StatefulWidget {
  final String title;
  final double rating;
  final bool isFavorite;

  const ProjectDetailPage({
    super.key,
    required this.title,
    required this.rating,
    required this.isFavorite,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 140, 124, 212), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      widget.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              // Rating Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 24),
                    const SizedBox(width: 4),
                    Text(
                      widget.rating.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: "Abstract"),
                    Tab(text: "Description"),
                    Tab(text: "Reports"),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAbstractTab(),
                      _buildDescriptionTab(),
                      _buildReportsTab(),
                    ],
                  ),
                ),
              ),

              // Review Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showReviewDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Write a Review",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAbstractTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Abstract",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "This project focuses on developing innovative solutions to modern challenges. "
            "Through comprehensive research and analysis, we have identified key areas "
            "of improvement and implemented cutting-edge technologies to address them.\n\n"
            "Our approach combines theoretical frameworks with practical applications, "
            "ensuring both academic rigor and real-world relevance.",
            style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detailed Description",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "Project Overview:\n\n"
            "This comprehensive project encompasses multiple phases of development, "
            "research, and implementation. Our team has worked extensively to ensure "
            "that all aspects of the project meet the highest standards of quality.\n\n"
            "Key Features:\n"
            "• Advanced methodology and approach\n"
            "• Comprehensive data analysis\n"
            "• Innovative problem-solving techniques\n"
            "• Sustainable and scalable solutions\n\n"
            "Implementation Process:\n\n"
            "The project follows a structured methodology that includes initial research, "
            "prototype development, testing phases, and final deployment. Each stage "
            "is carefully monitored to ensure optimal results.",
            style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Final Reports",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPdfOption("Project Report.pdf", "1.2 MB"),
          _buildPdfOption("Technical Documentation.pdf", "850 KB"),
          _buildPdfOption("Analysis Results.pdf", "2.1 MB"),
          _buildPdfOption("Final Presentation.pdf", "3.5 MB"),
        ],
      ),
    );
  }

  Widget _buildPdfOption(String fileName, String fileSize) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 35),
        title: Text(
          fileName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(fileSize, style: TextStyle(color: Colors.grey[600])),
        trailing: IconButton(
          icon: const Icon(Icons.visibility, color: Colors.orange),
          onPressed: () {
            // Open PDF Viewer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerPage(fileName: fileName),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    double rating = 0;
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Write a Review"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Rate this project:"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Write your review here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (rating > 0 && reviewController.text.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Review submitted successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please provide rating and review!"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Submit", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// PDF Viewer Page
class PdfViewerPage extends StatelessWidget {
  final String fileName;

  const PdfViewerPage({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        backgroundColor: const Color.fromARGB(255, 140, 124, 212),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              fileName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "To implement actual PDF viewing, add the 'flutter_pdfview' package "
                "and use PDFView widget with a local or network PDF file path.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}