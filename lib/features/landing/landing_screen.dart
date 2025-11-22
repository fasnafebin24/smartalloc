import 'package:flutter/material.dart';
import 'package:smartalloc/features/home/home%20_screen.dart';

import '../profail_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
   int _selectedIndex = 0;
   List pages=[
    HomeScreen(),
    ProfileEditScreen()
   ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
body:pages.elementAt(_selectedIndex) ,
      // Custom Bottom Navigation Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavButton(
                icon: Icons.home,
                label: "Home",
                isSelected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _buildNavButton(
                icon: Icons.person,
                label: "Profile",
                isSelected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Nav Button
  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color.fromARGB(255, 55, 0, 255), Color(0xFFFFC107)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}