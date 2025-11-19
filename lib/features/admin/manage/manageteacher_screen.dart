import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageTeacherPage extends StatefulWidget {
  const ManageTeacherPage({super.key});

  @override
  State<ManageTeacherPage> createState() => _ManageTeacherPageState();
}

class _ManageTeacherPageState extends State<ManageTeacherPage> {
  String selectedFilter = "active"; // default filter

  Stream<QuerySnapshot> getteacher() {
    final collection = FirebaseFirestore.instance.collection("Users");

    if (selectedFilter == "all") {
      return collection.where("role", isEqualTo: "teacher").snapshots();
    } else if (selectedFilter == "active") {
      return collection
          .where("role", isEqualTo: "teacher")
          .where("status", isEqualTo: 1)
          .snapshots();
    } else if (selectedFilter == "blocked") {
      return collection
          .where("role", isEqualTo: "teacher")
          .where("status", isEqualTo: 0)
          .snapshots();
    } else if (selectedFilter == "deleted") {
      return collection
          .where("role", isEqualTo: "teacher")
          .where("status", isEqualTo: -1)
          .snapshots();
    }

    return collection.snapshots();
  }

  // ---------- BLOCK/UNBLOCK TEACHER METHOD ----------
  Future<void> toggleBlockTeacher(String uid, int currentStatus) async {
    try {
      int newStatus = currentStatus == 1 ? 0 : 1; // Toggle between active (1) and blocked (0)
      
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .update({"status": newStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == 0 ? "Teacher blocked" : "Teacher unblocked"),
            backgroundColor: newStatus == 0 ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------- DELETE TEACHER METHOD ----------
  Future<void> deleteTeacher(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .update({"status": -1});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Teacher deleted"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------- UNDELETE TEACHER METHOD ----------
  Future<void> undeleteTeacher(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .update({"status": 1}); // Restore to active status

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Teacher restored"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Teacher"),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // ---------- FILTER BUTTONS ----------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                filterButton("active", "Active"),
                filterButton("blocked", "Blocked"),
                filterButton("deleted", "Deleted"),
                filterButton("all", "All"),
              ],
            ),
          ),

          const Divider(height: 20),

          // ---------- teacher LIST ----------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getteacher(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No teacher found."),
                  );
                }

                final teachers = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    var teacher = teachers[index].data() as Map<String, dynamic>;
                    int status = teacher["status"] ?? 1;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          child: Text(teacher["name"][0].toUpperCase()),
                        ),
                        title: Text(teacher["name"]),
                        subtitle: Text(teacher["email"]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Block/Unblock Button (only show if not deleted)
                            if (status != -1)
                              IconButton(
                                icon: Icon(
                                  status == 1 ? Icons.block : Icons.check_circle,
                                  color: status == 1 ? Colors.orange : Colors.green,
                                ),
                                onPressed: () {
                                  toggleBlockTeacher(teacher["uid"], status);
                                },
                                tooltip: status == 1 ? "Block" : "Unblock",
                              ),

                            // Delete/Undelete Button
                            if (status == -1)
                              // Undelete button for deleted teachers
                              IconButton(
                                icon: const Icon(Icons.restore, color: Colors.blue),
                                onPressed: () {
                                  undeleteTeacher(teacher["uid"]);
                                },
                                tooltip: "Restore",
                              )
                            else
                              // Delete button for active/blocked teachers
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteTeacher(teacher["uid"]);
                                },
                                tooltip: "Delete",
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------- FILTER BUTTON WIDGET -----------
  Widget filterButton(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedFilter == value,
        selectedColor: Colors.green,
        onSelected: (_) {
          setState(() {
            selectedFilter = value;
          });
        },
      ),
    );
  }
}