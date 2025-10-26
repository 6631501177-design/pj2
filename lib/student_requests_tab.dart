import 'package:flutter/material.dart';
import 'package:pj2/student_main_screen.dart'; // For shared colors

class StudentRequestsTab extends StatelessWidget {
  const StudentRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          // Example Pending Request Card
          _buildRequestCard(
            context,
            'Samsung S10+',
            'assets/samsung.png',
            'Pending',
            'Pending approval from admin.',
            pendingColor,
          ),
          const SizedBox(height: 16),
          // Example Approved Request Card
          _buildRequestCard(
            context,
            'MacBook Air',
            'assets/macbook_pro.png',
            'Approved',
            'Ready for pickup at Room A-102.',
            availableColor, // Green for approved
          ),
        ],
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
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1), // Light status bg
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
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
