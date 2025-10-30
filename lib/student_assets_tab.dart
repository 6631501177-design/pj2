import 'package:flutter/material.dart';
import 'package:pj2/asset_details_page.dart';
import 'package:pj2/login.dart' as login_screen;
import 'package:pj2/student_main_screen.dart';

class StudentAssetsTab extends StatefulWidget {
  const StudentAssetsTab({super.key});

  @override
  State<StudentAssetsTab> createState() => _StudentAssetsTabState();
}

class _StudentAssetsTabState extends State<StudentAssetsTab> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> assets = [
      {
        'name': 'Asus VivoBook',
        'image': 'assets/images/AsusVivo14.jpg',
        'status': 'Available',
        'statusColor': const Color(0xFF4CAF50),
      },
      {
        'name': 'iPad',
        'image': 'assets/images/IPad.jpg',
        'status': 'Borrowed',
        'statusColor': const Color(0xFFF44336),
      },
      {
        'name': 'Canon',
        'image': 'assets/images/canon.jpg',
        'status': 'Available',
        'statusColor': const Color(0xFF4CAF50),
      },
      {
        'name': 'MacBook',
        'image': 'assets/images/macbook.jpg',
        'status': 'Pending',
        'statusColor': const Color(0xFFFFA000),
      },
      {
        'name': 'Projector',
        'image': 'assets/images/projector.jpg',
        'status': 'Available',
        'statusColor': const Color(0xFF4CAF50),
      },
      {
        'name': 'Wanbo T2R',
        'image': 'assets/images/wanbo.jpg',
        'status': 'Disabled',
        'statusColor': const Color(0xFF9E9E9E),
      },
      {
        'name': 'Samsung S10',
        'image': 'assets/images/samsungs10.jpg',
        'status': 'Available',
        'statusColor': const Color(0xFF4CAF50),
      },
    ];

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Welcome',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const login_screen.LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.8,
          ),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final asset = assets[index];
            return _buildAssetCard(
              context,
              asset['name']!,
              asset['image']!,
              asset['status']!,
              asset['statusColor']!,
            );
          },
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle_outline;
      case 'borrowed':
        return Icons.history_outlined;
      case 'pending':
        return Icons.access_time_outlined;
      case 'disabled':
        return Icons.block_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildAssetCard(
    BuildContext context,
    String name,
    String imagePath,
    String status,
    Color statusColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssetDetailsPage(
              assetName: name,
              imagePath: imagePath,
              status: status,
            ),
          ),
        );
      },
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.contain,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 50,
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cardTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIcon(status), size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
