import 'package:flutter/material.dart';
import 'package:pj2/student_main_screen.dart';

class StudentHistoryTab extends StatelessWidget {
  const StudentHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My History',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: bodyTextColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildHistoryCard(
            context,
            'Samsung S10+',
            'assets/images/samsungs10.jpg',
            'Returned',
            'Returned on: 2025-10-20',
          ),
          const SizedBox(height: 16),
          _buildHistoryCard(
            context,
            'Canon EOS R10',
            'assets/images/canon.jpg',
            'Returned',
            'Returned on: 2025-09-15',
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    String assetName,
    String imagePath,
    String status,
    String details,
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
                    details,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: availableColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: availableColor,
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
