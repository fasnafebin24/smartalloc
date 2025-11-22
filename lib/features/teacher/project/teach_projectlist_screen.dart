// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'model/project_model.dart';
import 'teach_projectdetail_screen.dart';

class TeacchProjectsScreen extends StatefulWidget {
  const TeacchProjectsScreen({super.key});

  @override
  State<TeacchProjectsScreen> createState() => _TeacchProjectsScreenState();
}

class _TeacchProjectsScreenState extends State<TeacchProjectsScreen> {
  String selectedFilter = "pending";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getProjectsStream() {
    Query query = FirebaseFirestore.instance
        .collection('Projects')
        .where('status', isEqualTo: selectedFilter);

    if (_searchQuery.isNotEmpty) {
      query = query.where(
        'namefilter',
        arrayContains: _searchController.text.toLowerCase(),
      );
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8C7CD4), Color(0xFFE8E4F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Projects',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search projects...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Filter Chips
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _filterChip("Pending"),
                  _filterChip("Approved"),
                  _filterChip("Rejected"),
                  _filterChip("Trash"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Projects List
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getProjectsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8C7CD4),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading projects',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_off,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No projects found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Get all projects without additional filtering
                    final projects = snapshot.data!.docs;
                    List<Map<String, dynamic>> projectList = projects
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                        log(projectList.toString());
                    List<ProjectModel> projectModels = projects
                        .map(
                          (doc) => ProjectModel.fromJson(
                            doc.data() as Map<String, dynamic>,
                          ),
                        )
                        .toList();
                    

                    if (projectModels.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No matching projects',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: projectModels.length,
                      itemBuilder: (context, index) {
                        return _projectCard(
                          projectModels[index].projectName ??
                              'Untitled Project',
                          projectModels[index].department ?? 'N/A',
                          projectModels[index].status ?? 'pending',
                          projectModels[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final bool isSelected = selectedFilter == label.toLowerCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF8C7CD4),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w600,
        ),
        elevation: isSelected ? 4 : 1,
        onSelected: (value) {
          setState(() {
            selectedFilter = label.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _projectCard(
    String title,
    String department,
    String status,
    ProjectModel projectData,
  ) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'trash':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {

            Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectDetailsScreen(project: projectData)));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8C7CD4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.folder,
                    color: Color(0xFF8C7CD4),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        department,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1.5),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
