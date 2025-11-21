// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartalloc/features/teacher/project/model/project_model.dart';
import 'package:smartalloc/utils/contants/colors.dart';
import 'package:smartalloc/utils/methods/customsnackbar.dart';
import 'package:smartalloc/utils/variables/globalvariables.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../pdf/pdfview_screen.dart';

// Project Details Screen
class ProjectDetailsScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final TextEditingController _reviewController = TextEditingController();
  late String _projectStatus;
  int _rating = 0;

  bool _isSubmittingReview = false;
  @override
  void initState() {
    super.initState();
    _projectStatus = widget.project.status ?? 'prending';
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // Download PDF function
  Future<void> _downloadPdf(String url, String fileName) async {
    final Uri pdfUri = Uri.parse(url);
    if (await canLaunchUrl(pdfUri)) {
      await launchUrl(pdfUri, mode: LaunchMode.externalApplication);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading $fileName...'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not download PDF'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // View PDF in app
  void _viewPdf(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(pdfUrl: url, title: title),
      ),
    );
  }

  // Approve project
  void _approveProject() {
    setState(() {
      _projectStatus = 'approved';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project Approved Successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Reject project
  void _rejectProject() {
    setState(() {
      _projectStatus = 'rejected';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project Rejected'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      showCustomSnackBar(
        context,
        message: 'Please enter a review',
        type: SnackType.error,
      );
      return;
    }

    if (_rating == 0) {
      showCustomSnackBar(
        context,
        message: 'Please select a rating',
        type: SnackType.error,
      );
      return;
    }

    // Show loading state
    setState(() {
      _isSubmittingReview = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(guserid)
          .get();

      if (!userDoc.exists) {
        showCustomSnackBar(
          context,
          message: 'Teacher not found!',
          type: SnackType.error,
        );
        setState(() {
          _isSubmittingReview = false;
        });
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      // Check if review already exists
      final existingReview = await FirebaseFirestore.instance
          .collection('Projects')
          .doc(widget.project.id)
          .collection('Review')
          .doc(guserid)
          .get();

      if (existingReview.exists) {
        showCustomSnackBar(
          context,
          message: 'You have already submitted a review for this project!',
          type: SnackType.error,
        );
        setState(() {
          _isSubmittingReview = false;
        });
        return;
      }

      // Add review with user details
      await FirebaseFirestore.instance
          .collection('Projects')
          .doc(widget.project.id)
          .collection('Review')
          .doc(guserid)
          .set({
            'comment': _reviewController.text,
            'rating': _rating,
            'outoff': 5,
            'status': 1,
            'teacherName': userData['name'] ?? 'Unknown',
            'teacherEmail': userData['email'] ?? '',
            'reviewedAt': FieldValue.serverTimestamp(),
            'teachId': guserid,
          });

      showCustomSnackBar(
        context,
        message: 'Review submitted successfully!',
        type: SnackType.success,
      );

      setState(() {
        _reviewController.clear();
        _rating = 0;
        _isSubmittingReview = false;
      });
      FocusScope.of(context).unfocus();
    } catch (error) {
      if (kDebugMode) {
        print('Review submission error: $error');
      }
      showCustomSnackBar(
        context,
        message: 'Review Submission Failed!',
        type: SnackType.error,
      );
      setState(() {
        _isSubmittingReview = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Project Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.project.projectName ?? 'Untitled Project',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      _buildStatusChip(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.person,
                    'Student',
                    widget.project.teacherName ?? 'N/A',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.badge,
                    'Roll No',
                    widget.project.teacherId ?? 'N/A',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Submitted',
                    widget.project.uploadAt ?? 'N/A',
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Overview Card
                  _buildCard(
                    title: 'Project Overview',
                    icon: Icons.description,
                    child: Text(
                      widget.project.description ?? 'No description provided.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Project Details Card
                  _buildCard(
                    title: 'Project Details',
                    icon: Icons.info_outline,
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Department',
                          widget.project.department ?? '',
                          Colors.purple,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Batch',
                          widget.project.batch ?? '',
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Domain',
                          widget.project.domain ?? '',
                          Colors.teal,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Documents Card
                  _buildCard(
                    title: 'Project Documents',
                    icon: Icons.folder_open,
                    child: Column(
                      children: [
                        _buildPdfTile(
                          'Abstract PDF',
                          'Project abstract and summary',
                          widget.project.abstractfileurl ?? '',
                          Icons.article,
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildPdfTile(
                          'Final Project PDF',
                          'Complete project report',
                          widget.project.finalProjectFileurl ?? '',
                          Icons.description,
                          Colors.green,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Review Section
                  if (widget.project.status == 'approved')
                    _buildCard(
                      title: 'Submit Review',
                      icon: Icons.rate_review,
                      child: Column(
                        children: [
                          // Star Rating Selection
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rating',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _rating = index + 1;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Icon(
                                        index < _rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: index < _rating
                                            ? Colors.amber
                                            : Colors.grey,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              if (_rating > 0)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '$_rating out of 5 stars',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Comment Field
                          TextField(
                            controller: _reviewController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Share your experience and feedback...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmittingReview
                                  ? null
                                  : _submitReview,
                              icon: _isSubmittingReview
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send,
                                      color: AppColors.whiteColor,
                                    ),
                              label: Text(
                                _isSubmittingReview
                                    ? 'Submitting...'
                                    : 'Submit Review',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isSubmittingReview
                                    ? AppColors.primaryColor.withOpacity(0.6)
                                    : AppColors.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.project.status == 'pending')
                    const SizedBox(height: 16),

                  // Action Buttons
                  if (widget.project.status == 'pending')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _projectStatus == 'approved'
                                ? null
                                : _approveProject,
                            icon: const Icon(Icons.check_circle),
                            label: const Text(
                              'Approve',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _projectStatus == 'rejected'
                                ? null
                                : _rejectProject,
                            icon: const Icon(Icons.cancel),
                            label: const Text(
                              'Reject',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    switch (_projectStatus) {
      case 'approved':
        bgColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check_circle;
        text = 'Approved';
        break;
      case 'rejected':
        bgColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.cancel;
        text = 'Rejected';
        break;
      default:
        bgColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.pending;
        text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.indigo, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfTile(
    String title,
    String subtitle,
    String url,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _viewPdf(url, title),
            icon: const Icon(Icons.visibility, color: Colors.indigo),
            tooltip: 'View PDF',
          ),
          IconButton(
            onPressed: () => _downloadPdf(url, title),
            icon: Icon(Icons.download, color: color),
            tooltip: 'Download PDF',
          ),
        ],
      ),
    );
  }
}


