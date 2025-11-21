// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';

import '../../project/teach_projectlist_screen.dart';
import '../../home/teach_home_scree.dart';
import '../../settings/teachsettings_screen.dart';
import 'teachstudentlist_screen.dart';

// Main Teacher Dashboard with Bottom Navigation
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int currentIndex = 0;
  List<Widget> screens = [];
  gotoproject() {
    currentIndex = 1;
    setState(() {});
  }
  gotosudentt() {
    currentIndex = 2;
    setState(() {});
  }

  @override
  void initState() {
    screens = [
      TeachHomeScreen(
        chnageindex: () {
          gotoproject();
        },
        student: () {
         gotosudentt();
        },
      ),
      const TeacchProjectsScreen(),
       TeachStudentsScreen(),
      const SettingsScreen(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF8C7CD4),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}


