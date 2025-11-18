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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Teacher"),
        backgroundColor: const Color(0xFF4CAF50),
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
                            // Edit
                           

                            // Delete
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection("Users")
                                    .doc(teacher["uid"])
                                    .update({"status": -1});
                              },
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
