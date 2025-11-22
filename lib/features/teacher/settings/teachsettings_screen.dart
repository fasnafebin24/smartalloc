// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartalloc/features/profail_screen.dart';

import '../../../utils/extension/upperfstring_ext.dart';
import '../../../utils/variables/globalvariables.dart';
import '../../authentification/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Profile Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
  radius: 35,
  backgroundColor: const Color(0xFF8C7CD4),
  child: ClipOval(
    child: CachedNetworkImage(
      imageUrl: userdetails?.avatarUrl??'',
      fit: BoxFit.cover,
      width: 70,
      height: 70,
      placeholder: (context, url) => const Icon(Icons.person, size: 35, color: Colors.white),
      errorWidget: (context, url, error) => const Icon(Icons.person, size: 35, color: Colors.white),
    ),
  ),
),
                  const SizedBox(width: 16),
                   Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userdetails?.name?.upperFirst??'Unknown',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          userdetails?.email??'Unknown',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: ()async {
                     var usetdata =await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen(),));
                     if (usetdata!=null) {
                      userdetails = usetdata;
                      setState(() {
                        
                      });
                      
                       
                     }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings Options
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _settingTile(Icons.notifications, 'Notifications', () {}),
                    _settingTile(Icons.security, 'Privacy & Security', () {}),
                    _settingTile(Icons.help, 'Help & Support', () {}),
                    _settingTile(Icons.info, 'About', () {}),
                    const SizedBox(height: 20),
                    _settingTile(Icons.logout, 'Logout', ()async {
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
                    }, isLogout: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : const Color(0xFF8C7CD4),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isLogout ? Colors.red : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}