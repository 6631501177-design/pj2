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
    final List<Map<String, String>> assets = [
      {'name': 'Asus VivoBook', 'image': 'assets/images/AsusVivo14.jpg'},
      {'name': 'iPad', 'image': 'assets/images/IPad.jpg'},
      {'name': 'Canon', 'image': 'assets/images/canon.jpg'},
      {'name': 'MacBook', 'image': 'assets/images/macbook.jpg'},
      {'name': 'Projector', 'image': 'assets/images/projector.jpg'},
      {'name': 'Wanbo T2R', 'image': 'assets/images/wanbo.jpg'},
      {'name': 'Samsung S10', 'image': 'assets/images/samsungs10.jpg'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Welcome',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // Show a confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              // If user confirms logout
              if (shouldLogout == true) {
                if (mounted) {
                  // Clear all routes and navigate to login
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const login_screen.LoginScreen(),
                    ),
                    (route) => false, // Remove all previous routes
                  );
                }
              }
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
            return _buildAssetCard(context, asset['name']!, asset['image']!);
          },
        ),
      ),
    );
  }

  Widget _buildAssetCard(BuildContext context, String name, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AssetDetailsPage(assetName: name, imagePath: imagePath),
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
              const SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cardTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
