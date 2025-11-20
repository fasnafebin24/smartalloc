// 1. Dashboard Screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartalloc/utils/variables/globalvariables.dart';

class TeachHomeScreen extends StatelessWidget {
   TeachHomeScreen({super.key,this.chnageindex});
  VoidCallback? chnageindex;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,    
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teacher Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage your projects',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF8C7CD4)),
                  ),
                ],
              ),
            ),  

            // Dashboard Cards
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    // crossAxisCount: 2,
                    // crossAxisSpacing: 16,
                    // mainAxisSpacing: 16,
                    // childAspectRatio: .76,
                    children: [
                      StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('Projects').where('teacherId',isEqualTo:  guserid).snapshots(),
                        builder: (context, asyncSnapshot) {
                          return _dashboardCard(
                            'Total Projects',
                            (asyncSnapshot.data?.docs.length ?? 0).toString(),
                            Icons.folder,
                            Colors.orange,
                          );
                        }
                      ),
                      SizedBox(height: 16,),
                       StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('Projects').where('teacherId',isEqualTo:  guserid).where('status',isEqualTo: 'pending').snapshots(),
                        builder: (context, asyncSnapshot) {
                          return _dashboardCard(
                            'Pending Projects',
                            (asyncSnapshot.data?.docs.length ?? 0).toString(),
                            Icons.folder,
                            Colors.orange,
                          );
                        }
                      ),
                      SizedBox(height: 16,),
                      _dashboardCard(
                        'Students',
                        '156',
                        Icons.people,
                        Colors.blue,
                      ),
                     
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
   Widget _dashboardCard(String title, String count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                const SizedBox(height: 12),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}