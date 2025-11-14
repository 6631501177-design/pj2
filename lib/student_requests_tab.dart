import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pj2/student_main_screen.dart';

const Color pendingColor = Color(0xFFFFA500);

// Global key to access the StudentRequestsTab state
final GlobalKey<_StudentRequestsTabState> studentRequestsTabKey =
    GlobalKey<_StudentRequestsTabState>();

class StudentRequestsTab extends StatefulWidget {
  const StudentRequestsTab({super.key});

  @override
  _StudentRequestsTabState createState() => _StudentRequestsTabState();

  // Static method to access the state from anywhere
  static _StudentRequestsTabState? of(BuildContext context) {
    // First try to find using the global key
    if (studentRequestsTabKey.currentState != null) {
      return studentRequestsTabKey.currentState;
    }
    // Fallback to finding in the widget tree
    return context.findAncestorStateOfType<_StudentRequestsTabState>();
  }
}

class _StudentRequestsTabState extends State<StudentRequestsTab> {
  _StudentRequestsTabState();

  // This list will store the borrowed items
  final List<Map<String, dynamic>> _requests = [];

  // This method can be called to add a new request
  void addRequest(String assetName, String imagePath) {
    setState(() {
      final now = DateTime.now()
          .toLocal(); // Get current date in local timezone
      _requests.add({
        'assetName': assetName,
        'imagePath': imagePath,
        'status': 'Pending',
        'description':
            'Requested on ${DateFormat('MMM dd, yyyy').format(now)} - Pending approval',
        'color': pendingColor,
        'requestDate': now,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: studentRequestsTabKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Requests',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: bodyTextColor,
              ),
            ),
            const SizedBox(height: 24),
            // Show all requests
            ..._requests.map(
              (request) => _buildRequestCard(
                context,
                request['assetName'],
                request['imagePath'],
                request['status'],
                request['description'],
                request['color'],
              ),
            ),
            // Show message if no requests
            if (_requests.isEmpty)
              const Center(
                child: Text(
                  'No requests yet',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    String assetName,
    String imagePath,
    String status,
    String description,
    Color statusColor,
  ) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 50,
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assetName,
                    style: const TextStyle(
                      color: cardTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: $status',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
