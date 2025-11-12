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

// Using the same URL as your login.dart file
const String url = '192.168.1.121:3000';

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
    // ... (No changes needed to this widget) ...
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
    // This now uses the fetched _assets list
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
          mainAxisExtent: 240, // Slightly taller cards
        ),
        itemCount: _assets.length, // Use fetched list length
        itemBuilder: (context, index) {
          final asset = _assets[index];
          final status = asset['status'] ?? 'Unknown';
          return _buildAssetCard(
            name: asset['asset_name'] ?? 'No Name',
            image: asset['image'] ?? '', // URL from database
            status: status,
            statusColor: _getColorForStatus(status),
          );
        },
      ),
    );
  }

  Widget _buildAssetCard({
    required String name,
    required String image,
    required String status,
    required Color statusColor,
  }) {
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
                // Use Image.network to load from a URL
                child: Image.network(
                  image.trim(),
                  fit: BoxFit.cover,
                  // Placeholder while loading
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  // Error handler for bad URLs or network issues
                  errorBuilder: (context, error, stackTrace) => Container(
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
    // ... (No changes needed to this widget) ...
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
    // ... (No changes needed to this widget) ...
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
    // ... (No changes needed to this widget) ...
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
