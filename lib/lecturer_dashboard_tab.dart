import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pj2/lecturer_browse_tab.dart';
import 'package:pj2/lecturer_history_page.dart';
import 'package:pj2/lecturer_request_page.dart';
// import 'package:pj2/lecturer_requested_tab.dart';
import 'package:pj2/login.dart' as login_screen;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Color palette from student_main_screen.dart
const Color primaryColor = Color(0xFF0A4D68);
const Color secondaryColor = Color(0xFF088395);
const Color cardColor = Color(0xFFFFFFFF);
const Color cardTextColor = Colors.black;
const Color bodyTextColor = Colors.white;
const Color subtitleTextColor = Colors.white70;
const Color availableColor = Color(0xFF28A745);
const Color pendingColor = Color(0xFFFFA500);
const Color buttonColor = Color(0xFF4F709C);

// API URL
const String url = '192.168.1.121:3000';

class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({Key? key}) : super(key: key);

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sessionCookie = prefs.getString('sessionCookie');

      if (sessionCookie == null) {
        throw Exception('Not logged in');
      }

      final response = await http
          .get(
            Uri.http(url, '/api/dashboard'),
            headers: {
              'Content-Type': 'application/json',
              'Cookie': sessionCookie, // Send the session cookie
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _dashboardData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      // Optionally, navigate to login if unauthorized
      if (e.toString().contains('Not logged in')) {
        _logout();
      }
    }
  }

  void _logout() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const login_screen.LoginScreen(),
        ),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A4D68),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : _errorMessage != null
                        ? Center(
                            child: Text(
                              'Error: $_errorMessage',
                              style: const TextStyle(color: Colors.orange),
                            ),
                          )
                        : _buildDashboardCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Welcome',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout, // Use the new logout function
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard() {
    // Use data from _dashboardData, with '...' as a fallback
    final available = _dashboardData?['Available']?.toString() ?? '...';
    final borrowed = _dashboardData?['Borrowed']?.toString() ?? '...';
    final disabled = _dashboardData?['Disabled']?.toString() ?? '...';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Dashboard",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard(
                label: 'Available',
                count: available, // Use fetched data
                color: const Color(0xFF4CAF50),
                backgroundColor: const Color(0xFFF1F8F4),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: 'Borrowed',
                count: borrowed, // Use fetched data
                color: const Color(0xFFF44336),
                backgroundColor: const Color(0xFFFFF3E0),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: 'Disabled',
                count: disabled, // Use fetched data
                color: const Color(0xFFBDBDBD),
                backgroundColor: const Color(0xFFF5F5F5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String count,
    required Color color,
    required Color backgroundColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
                isActive: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.list_alt,
                label: 'Requested',
                isActive: false,
                onTap: () => _navigateTo(context, const LecturerRequestPage()),
              ),
              _buildNavItem(
                icon: Icons.search,
                label: 'Browse',
                isActive: false,
                onTap: () => _navigateTo(context, const LecturerBrowseAssets()),
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
