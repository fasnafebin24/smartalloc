import 'package:flutter/material.dart';

class ProfailScreen extends StatefulWidget {
  const ProfailScreen({super.key});

  @override
  State<ProfailScreen> createState() => _ProfailScreenState();
}

class _ProfailScreenState extends State<ProfailScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: const Color.fromARGB(255, 170, 169, 243),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white),
                  const Text(
                    "fasna",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.settings, color: Colors.white),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage("assets/avatar.png"), 
                  // Replace with NetworkImage if using online image
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.edit, size: 20, color: Colors.amber),
                )
              ],
            ),

            const SizedBox(height: 30),

            // User Info
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "USERNAME",
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "@fxznahh",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "FULLNAME",
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "fasna febin.pp",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "EMAIL ADDRESS",
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "contact@elvisobi.com",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );

  }
}