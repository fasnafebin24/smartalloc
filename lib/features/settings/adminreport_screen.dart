import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminReprtScreen extends StatefulWidget {
  const AdminReprtScreen({super.key});

  @override
  State<AdminReprtScreen> createState() => _AdminReprtScreenState();
}

class _AdminReprtScreenState extends State<AdminReprtScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Reports"),

       
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFilteredStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No reports found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final data = report.data() as Map<String, dynamic>;
              
              return _buildReportCard(context, report.id, data);
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    Query query = _firestore.collection('Report');
    
    
    return query.orderBy('timestamp', descending: true).snapshots();
  }

  Widget _buildReportCard(BuildContext context, String docId, Map<String, dynamic> data) {
    final String comment = data['comment'] ?? 'No comment';
    final int status = data['status'] ?? 0;
    final Timestamp? timestamp = data['timestamp'];
    final String useravatar = data['useravatar'] ?? '';
    final String username = data['username'] ?? 'Unknown';

    final DateTime dateTime = timestamp?.toDate() ?? DateTime.now();
    final String formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showReportDetails(context, docId, data),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info and status
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF00BCD4),
                    backgroundImage: useravatar.isNotEmpty 
                        ? NetworkImage(useravatar) 
                        : null,
                    child: useravatar.isEmpty 
                        ? Text(
                            username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              // Comment section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.comment, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comment,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showReportDetails(context, docId, data),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00BCD4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (status == 1)
                    ElevatedButton.icon(
                      onPressed: () => _updateReportStatus(context, docId, 0),
                      label: const Text('Resolved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _updateReportStatus(context, docId, 1),
                      icon: const Icon(Icons.replay, size: 18),
                      label: const Text('Reopen'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    final bool isPending = status == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPending ? Colors.orange[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPending ? Icons.pending : Icons.check_circle,
            size: 16,
            color: isPending ? Colors.orange[700] : Colors.green[700],
          ),
          const SizedBox(width: 4),
          Text(
            isPending ? 'Pending' : 'Resolved',
            style: TextStyle(
              color: isPending ? Colors.orange[700] : Colors.green[700],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(BuildContext context, String docId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          final String comment = data['comment'] ?? 'No comment';
          final int status = data['status'] ?? 0;
          final Timestamp? timestamp = data['timestamp'];
          final String useravatar = data['useravatar'] ?? '';
          final String username = data['username'] ?? 'Unknown';
          final String userId = data['userid'] ?? '';
          final DateTime dateTime = timestamp?.toDate() ?? DateTime.now();
          final String formattedDate = DateFormat('MMMM dd, yyyy at hh:mm a').format(dateTime);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Report Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // User info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF00BCD4),
                      backgroundImage: useravatar.isNotEmpty 
                          ? NetworkImage(useravatar) 
                          : null,
                      child: useravatar.isEmpty 
                          ? Text(
                              username[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'User ID: $userId',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(status),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildDetailRow(Icons.calendar_today, 'Submitted', formattedDate),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.comment, 'Comment', comment, isMultiline: true),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateReportStatus(context, docId, status == 1 ? 0 : 1);
                        },
                        icon: Icon(status == 1 ? Icons.check : Icons.replay),
                        label: Text(status == 1 ? 'Resolve' : 'Reopen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: status == 1 ? Colors.green : Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isMultiline = false}) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF00BCD4)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _updateReportStatus(BuildContext context, String docId, int newStatus) async {
    try {
      await _firestore.collection('Report').doc(docId).update({
        'status': newStatus,
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 0 ? 'Report marked as resolved' : 'Report reopened',
            ),
            backgroundColor: newStatus == 0 ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}