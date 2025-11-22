// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:smartalloc/utils/contants/colors.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String? expandedSection;

  void toggleSection(String section) {
    setState(() {
      expandedSection = expandedSection == section ? null : section;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF4F46E5),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'Smart Alloc',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Last Updated: November 22, 2025',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'At Smart Alloc, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our app.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Expandable Sections
            _buildSection(
              'info-collect',
              Icons.description_outlined,
              'Information We Collect',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We collect the following information to provide and improve our services:',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                    'Account Information:',
                    'Email address and authentication credentials when you register or log in',
                  ),
                  _buildBulletPoint(
                    'Profile Data:',
                    'Your role (student or teacher), name, and associated institution details',
                  ),
                  _buildBulletPoint(
                    'Project Content:',
                    'Projects you submit, view, or interact with from current and previous batches',
                  ),
                  _buildBulletPoint(
                    'Review Data:',
                    'Reviews and feedback you provide on projects',
                  ),
                  _buildBulletPoint(
                    'Usage Information:',
                    'App interactions, access times, and feature usage patterns',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _buildSection(
              'how-use',
              Icons.people_outline,
              'How We Use Your Information',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your information is used for the following purposes:',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  _buildSimpleBullet('To authenticate and manage your account access'),
                  _buildSimpleBullet('To display relevant projects from previous batches'),
                  _buildSimpleBullet('To enable project reviews and collaboration between students and teachers'),
                  _buildSimpleBullet('To improve app functionality and user experience'),
                  _buildSimpleBullet('To maintain app security and prevent unauthorized access'),
                  _buildSimpleBullet('To communicate important updates about the service'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _buildSection(
              'data-security',
              Icons.lock_outline,
              'Data Security',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We take your data security seriously:',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  _buildSimpleBullet('All data transmissions are encrypted using industry-standard protocols'),
                  _buildSimpleBullet('Passwords are securely hashed and never stored in plain text'),
                  _buildSimpleBullet('Access to your data is restricted to authorized personnel only'),
                  _buildSimpleBullet('We implement regular security audits and updates'),
                  _buildSimpleBullet('User sessions are protected with secure authentication tokens'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _buildSection(
              'data-sharing',
              Icons.visibility_outlined,
              'Information Sharing',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your privacy is important to us:',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                    'Within the App:',
                    'Projects and reviews are visible to other students and teachers within your institution as part of the app\'s core functionality',
                  ),
                  _buildBulletPoint(
                    'Third Parties:',
                    'We do not sell or share your personal information with third parties for marketing purposes',
                  ),
                  _buildBulletPoint(
                    'Service Providers:',
                    'We may share data with trusted service providers who help us operate the app (e.g., hosting services), bound by confidentiality agreements',
                  ),
                  _buildBulletPoint(
                    'Legal Requirements:',
                    'We may disclose information if required by law or to protect our rights and safety',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _buildSection(
              'your-rights',
              Icons.verified_user_outlined,
              'Your Rights',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'You have the following rights regarding your data:',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint('Access:', 'Request a copy of your personal data'),
                  _buildBulletPoint('Correction:', 'Update or correct inaccurate information'),
                  _buildBulletPoint('Deletion:', 'Request deletion of your account and associated data'),
                  _buildBulletPoint('Data Portability:', 'Receive your data in a portable format'),
                  _buildBulletPoint('Opt-out:', 'Unsubscribe from non-essential communications'),
                  const SizedBox(height: 12),
                  const Text(
                    'To exercise these rights, please contact us using the information below.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _buildSection(
              'retention',
              Icons.folder_outlined,
              'Data Retention',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We retain your information as follows:',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  _buildSimpleBullet('Account data is retained while your account is active'),
                  _buildSimpleBullet('Project submissions and reviews are retained for historical reference and educational purposes'),
                  _buildSimpleBullet('After account deletion, personal identifiers are removed, but anonymized project data may be retained'),
                  _buildSimpleBullet('We comply with applicable legal requirements for data retention'),
                ],
              ),
            ),
               const SizedBox(height: 16),

            // Footer Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDEEBFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF93C5FD)),
              ),
              child: const Text(
                'We may update this Privacy Policy from time to time. We will notify you of any significant changes through the app or via email. Continued use of Smart Alloc after changes constitutes acceptance of the updated policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String id, IconData icon, String title, Widget content) {
    final isExpanded = expandedSection == id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => toggleSection(id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFF4F46E5), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF3F4F6)),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                  child: content,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.5),
                children: [
                  TextSpan(
                    text: '$title ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}