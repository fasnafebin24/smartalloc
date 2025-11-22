import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartalloc/utils/variables/globalvariables.dart';

class ReportSubmissionScreen extends StatefulWidget {
 

  const ReportSubmissionScreen({
    super.key,
  });

  @override
  State<ReportSubmissionScreen> createState() => _ReportSubmissionScreenState();
}

class _ReportSubmissionScreenState extends State<ReportSubmissionScreen> {
  final TextEditingController _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isLoading = true;
  bool _hasExistingReport = false;
  String? _existingComment;

  @override
  void initState() {
    super.initState();
    _checkExistingReport();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingReport() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Report')
          .doc(userdetails?.uid)
          .get();

      if (mounted) {
        setState(() {
          _hasExistingReport = doc.exists;
          if (doc.exists) {
            _existingComment = doc.data()?['comment'] ?? '';
            _commentController.text = _existingComment ?? '';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Report')
          .doc(userdetails?.uid)
          .set({
        'userid': userdetails?.uid,
        'username': userdetails?.name??'',
        'useravatar': userdetails?.avatarUrl,
        'comment': _commentController.text.trim(),
        'status': 1,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_hasExistingReport
                ? 'Report updated successfully'
                : 'Report submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_hasExistingReport ? 'Update Report' : 'Submit Report'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_hasExistingReport) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'You have already submitted a report. You can update it below.',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Describe your issue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please provide details about the problem you\'re reporting',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _commentController,
                      maxLines: 8,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Enter your comment here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a comment';
                        }
                        if (value.trim().length < 10) {
                          return 'Comment must be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _hasExistingReport
                                  ? 'Update Report'
                                  : 'Submit Report',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}