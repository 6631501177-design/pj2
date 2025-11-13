import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pj2/lecturer_dashboard_tab.dart';
import 'package:pj2/lecturer_history_page.dart';
import 'package:pj2/lecturer_requested_tab.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF0A4D68);
const Color secondaryColor = Color(0xFF088395);
const Color cardColor = Color(0xFFFFFFFF);
const Color cardTextColor = Colors.black;
const Color bodyTextColor = Colors.white;
const Color subtitleTextColor = Colors.white70;
const Color availableColor = Color(0xFF28A745);
const Color pendingColor = Color(0xFFFFA500);
const Color buttonColor = Color(0xFF4F709C);

// const String url = '192.168.1.121:3000';
// const String url = '10.0.2.2:3000';

class LecturerBrowseAssets extends StatefulWidget {
  const LecturerBrowseAssets({Key? key}) : super(key: key);

  @override
  State<LecturerBrowseAssets> createState() => _LecturerBrowseAssetsState();
}

class _LecturerBrowseAssetsState extends State<LecturerBrowseAssets> {
  List<dynamic> _assets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sessionCookie = prefs.getString('sessionCookie');

      if (sessionCookie == null) {
        throw Exception('Not logged in');
      }

      final response = await http
          .get(
            Uri.http(url, '/api/asset'),
            headers: {
              'Content-Type': 'application/json',
              'Cookie': sessionCookie, // Send the session cookie
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _assets = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load assets');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Helper function to get color from status string
  Color _getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF4CAF50); // Green
      case 'borrowed':
        return const Color(0xFFF44336); // Red
      case 'pending':
        return const Color(0xFFFFA000); // Amber
      case 'disable':
      case 'disabled': // Handle both spellings
        return const Color(0xFF9E9E9E); // Grey
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Browse Assets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    )
                  : _buildAssetsGrid(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search any assets',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetsGrid() {
    if (_assets.isEmpty) {
      return const Center(
        child: Text(
          'No assets found',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
          mainAxisExtent: 240,
        ),
        itemCount: _assets.length,
        itemBuilder: (context, index) {
          try {
            final asset = _assets[index];
            if (asset == null) return const SizedBox.shrink();

            final status = asset['status']?.toString() ?? 'Unknown';

            // --- UPDATED CODE ---
            // Get the image path directly from the API
            final String imagePath = asset['image']?.toString() ?? '';

            return _buildAssetCard(
              name: asset['asset_name']?.toString() ?? 'No Name',
              imagePath: imagePath, // Pass the path, not a URL
              status: status,
              statusColor: _getColorForStatus(status),
            );
            // --- END UPDATED CODE ---
          } catch (e) {
            return const Center(
              child: Text(
                'Error loading asset',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAssetCard({
    required String name,
    required String imagePath, // --- UPDATED ---
    required String status,
    required Color statusColor,
  }) {
    // Clean up the image path just in case
    final cleanImagePath = imagePath.replaceAll(RegExp(r'^[\\/]+'), '');

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 1.5,
                child: cleanImagePath.isNotEmpty
                    ? Image.asset(
                        // Use Image.asset()
                        cleanImagePath, // Pass the path directly
                        fit: BoxFit
                            .contain, // Use contain to show the whole image
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C5464),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                isActive: false,
                onTap: () => _navigateTo(context, const LecturerDashboard()),
              ),
              _buildNavItem(
                icon: Icons.list_alt,
                label: 'Requested',
                isActive: false,
                onTap: () =>
                    _navigateTo(context, const LecturerRequestedPage()),
              ),
              _buildNavItem(
                icon: Icons.search,
                label: 'Browse',
                isActive: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.history,
                label: 'History',
                isActive: false,
                onTap: () => _navigateTo(context, const LecturerHistoryPage()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
