import 'package:flutter/material.dart';
import 'package:pj2/asset_details_page.dart' as asset_details;
import 'package:pj2/login.dart' as login_screen;
import 'package:pj2/student_main_screen.dart';

// --- Imports for API calls ---
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// ---

// --- API URL ---
const String _apiUrl = '192.168.1.121:3000';
// const String _apiUrl = '172.27.22.205:3000';

class StudentAssetsTab extends StatefulWidget {
  const StudentAssetsTab({super.key});

  @override
  State<StudentAssetsTab> createState() => _StudentAssetsTabState();
}

class _StudentAssetsTabState extends State<StudentAssetsTab> {
  List _assets = []; // <-- Will hold data from API
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    // Ensure we are in a fresh state
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cookie = prefs.getString('sessionCookie');

      final response = await http
          .get(
            Uri.http(_apiUrl, '/api/asset'), // <-- Calls /api/asset
            headers: {
              'Cookie': cookie ?? '', // <-- Send session cookie
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _assets = jsonDecode(response.body);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load assets. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not connect to server. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Updated Logout Function ---
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cookie = prefs.getString('sessionCookie');

    try {
      // Notify backend to destroy session
      await http.post(
        Uri.http(_apiUrl, '/logout'),
        headers: {'Cookie': cookie ?? ''},
      );
    } catch (e) {
      // Ignore errors, just clear local data
    }

    // Clear local data
    await prefs.remove('sessionCookie');
    await prefs.remove('userData');

    // Navigate to login screen
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const login_screen.LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _logout, // <-- Updated
          ),
        ],
      ),
      body: _buildBody(), // <-- Use helper for body
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.orange, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _fetchAssets, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_assets.isEmpty) {
      return const Center(
        child: Text(
          'No assets found.',
          style: TextStyle(color: subtitleTextColor, fontSize: 18),
        ),
      );
    }

    // --- Main Asset Grid ---
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.8,
        ),
        itemCount: _assets.length,
        itemBuilder: (context, index) {
          final asset = _assets[index];
          // Get the image name from the asset data or use a default
          String? imageName = asset['image'];
          String assetPath;

          // Map of asset names to their corresponding image files
          final Map<String, String> imageMap = {
            'AsusVivo14': 'AsusVivo14.jpg',
            'IPad': 'IPad.jpg',
            'canon': 'canon.jpg',
            'macbook': 'macbook.jpg',
            'projector': 'projector.jpg',
            'samsungs10': 'samsungs10.jpg',
            'wanbo': 'wanbo.jpg',
          };

          if (imageName == null || imageName.isEmpty) {
            debugPrint('Image name is empty for asset ${asset['id']}');
            assetPath = '';
          } else {
            // Remove any path and extension from the image name
            imageName = imageName.split('/').last.split('.').first;
            // Get the corresponding asset path from the map, or use a default
            assetPath =
                'assets/images/${imageMap[imageName] ?? 'default_asset.png'}';
            debugPrint('Using asset path: $assetPath');
          }

          return _buildAssetCard(
            context,
            asset['id'],
            asset['asset_name'],
            assetPath, // Changed from imageUrl to assetPath
            asset['status'],
          );
        },
      ),
    );
  }

  // --- Helper to get color from status string ---
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF4CAF50); // Green
      case 'borrowed':
        return const Color(0xFFF44336); // Red
      case 'pending':
        return const Color(0xFFFFA000); // Orange
      case 'disable': // Match your SQL enum
        return const Color(0xFF9E9E9E); // Grey
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle_outline;
      case 'borrowed':
        return Icons.history_outlined;
      case 'pending':
        return Icons.access_time_outlined;
      case 'disable': // Match your SQL enum
        return Icons.block_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildAssetCard(
    BuildContext context,
    dynamic assetId,
    String name,
    String assetPath,
    String status,
  ) {
    final Color statusColor = _getStatusColor(status);
    final bool isAvailable = status.toLowerCase() == 'available';

    return GestureDetector(
      onTap: isAvailable
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => asset_details.AssetDetailsPage(
                    assetName: name,
                    imagePath: assetPath,
                    status: status,
                    assetId: assetId,
                  ),
                ),
              );
            }
          : () {
              // Show a snackbar when trying to interact with an unavailable asset
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'This asset is currently not available for borrowing',
                  ),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
      child: Card(
        color: cardColor, // Keep the same background color for all cards
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: isAvailable
            ? 4
            : 1, // Only change elevation for visual feedback
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Image with better error handling ---
              assetPath.isNotEmpty
                  ? Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading asset: $assetPath - $error');
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 50,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Image not found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 50,
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

              // --- End of missing part ---
            ],
          ),
        ),
      ),
    );
  }
} // <-- This was the missing closing brace
