// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartalloc/features/authentification/login_screen.dart';
import 'package:smartalloc/features/teacher/project/teach_projectdetail_screen.dart';
import 'package:smartalloc/utils/variables/globalvariables.dart';
import '../teacher/project/model/project_model.dart';
import 'std_favorites_screen.dart';

class StdHomeScreen extends StatefulWidget {
  const StdHomeScreen({super.key});

  @override
  State<StdHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<StdHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProjectModel> _projects = [];
  List<ProjectModel> _filteredProjects = [];
  Set<String> _favoriteProjectIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _fetchProjects();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteProjectIds = (prefs.getStringList('favorite_projects') ?? []).toSet();
    });
  }

  Future<void> _toggleFavorite(String projectId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteProjectIds.contains(projectId)) {
        _favoriteProjectIds.remove(projectId);
      } else {
        _favoriteProjectIds.add(projectId);
      }
    });
    await prefs.setStringList('favorite_projects', _favoriteProjectIds.toList());
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _favoriteProjectIds.contains(projectId)
              ? 'Added to favorites'
              : 'Removed from favorites',
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredProjects = _projects;
      } else {
        String query = _searchController.text.toLowerCase();
        _filteredProjects = _projects.where((project) {
          return project.namefilter?.any((name) => name.contains(query)) ??
              false;
        }).toList();
      }
    });
  }

  Future<void> _fetchProjects() async {
    try {
      setState(() => _isLoading = true);

      Query query;
      if (userdetails?.departmentcode == 'CS' ||
          userdetails?.departmentcode == 'BCA') {
        query = FirebaseFirestore.instance
            .collection('Projects')
            .where('status', isEqualTo: 'approved')
            .where('departmentcode', whereIn: ['CS', 'BCA']);
      } else {
        query = FirebaseFirestore.instance
            .collection('Projects')
            .where('status', isEqualTo: 'approved')
            .where('departmentcode', isEqualTo: userdetails?.departmentcode);
      }

      QuerySnapshot querySnapshot = await query.get();

      _projects = querySnapshot.docs
          .map(
            (doc) => ProjectModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      _filteredProjects = _projects;

      setState(() => _isLoading = false);
    } catch (e) {
     
      if (mounted) {
         setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching projects: $e'),
            backgroundColor: Colors.red,
          ),
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
              const SizedBox(height: 50),
              // Top Bar with Favorites and Logout
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Favorites Button
                
                  // Logout Button
                  ElevatedButton.icon(
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
                ],
              ),
              const SizedBox(height: 20),
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search projects...",
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : const Icon(Icons.filter_list, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
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
              const SizedBox(height: 16),
              // Projects Grid
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      )
                    : _filteredProjects.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isEmpty
                                      ? 'No approved projects found'
                                      : 'No projects match your search',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchProjects,
                            color: Colors.orange,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.83,
                              ),
                              itemCount: _filteredProjects.length,
                              itemBuilder: (context, index) {
                                return _projectCard(_filteredProjects[index]);
                              },
                            ),
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
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Logged out successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _projectCard(ProjectModel project) {
    final isFavorite = _favoriteProjectIds.contains(project.id);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsScreen(project: project),
          ),
        );
      },
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo/Thumbnail
                  if (project.logoUrl != null && project.logoUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        project.logoUrl!,
                        height: 80,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 80,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.folder_open,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Project Name
                  Text(
                    project.projectName ?? 'Untitled Project',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Department/Domain Badge
                  if (project.department != null || project.domain != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        project.domain ?? project.department ?? '',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 4),
                  // View Details Button
                  Row(
                    children: [
                      if (project.batch != null)
                        Expanded(
                          child: Text(
                            'Batch: ${project.batch}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.orange,
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Favorite Button
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleFavorite(project.id ?? ''),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}