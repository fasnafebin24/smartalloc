// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewProjectsPage extends StatefulWidget {
  const ViewProjectsPage({super.key});

  @override
  State<ViewProjectsPage> createState() => _ViewProjectsPageState();
}

class _ViewProjectsPageState extends State<ViewProjectsPage> {
  String selectedFilter = "Pending";


  @override
  Widget build(BuildContext context) {
   

    return Scaffold(
      appBar: AppBar(
        title: const Text("View Projects"),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // ---------------- FILTER CHIPS ----------------
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                filterChip("Pending"),
                filterChip("Approved"),
                filterChip("Rejected"),
                filterChip("Trash"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ---------------- PROJECT LIST ----------------
          Expanded(
            child:StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Projects').where('status',isEqualTo: selectedFilter.toLowerCase()).snapshots(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(child: CircularProgressIndicator()));
                }
                if (asyncSnapshot.hasError || (asyncSnapshot.data!=null && asyncSnapshot.data!.docs.isEmpty)) {
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(child:Text('No Projects',style: TextStyle(fontWeight: FontWeight.w500),)));
                }
                return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: asyncSnapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          final project =asyncSnapshot.data?.docs[index];
                
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 14),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                
                              // Icon
                              leading: const Icon(Icons.folder_open,
                                  size: 32, color: Color(0xFF673AB7)),
                
                              // Title + Department + Rating
                              title: Text(
                                project?["projectName"]??'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Department
                                    Text(
                                      "Department:BCA",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 6),
                
                                    // Rating + review count
                                    Row(
                                      children: [
                                        Text("3 ⭐",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 8),
                                        Text("12 reviews",
                                            style:
                                                const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                
                              // Status badge
                              trailing: statusBadge(project?["status"]),
                
                              onTap: () {
                               
                              },
                            ),
                          );
                        },
                      );
              }
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- FILTER CHIP ----------------
  Widget filterChip(String label) {
    final bool isSelected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF673AB7),
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (value) {
          setState(() => selectedFilter = label);
        },
      ),
    );
  }

  // ---------------- STATUS BADGE ----------------
  Widget statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case "approved":
        color = Colors.green;
        break;
      case "rejected":
        color = Colors.red;
        break;
      case "trash":
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
