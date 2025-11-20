import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pj2/staff_edit_assets_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pj2/staff_history_tab.dart';
import 'package:pj2/staff_process_return_tab.dart';
import 'package:pj2/staff_theme.dart';
import 'package:pj2/login.dart' as login_screen;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class StaffMainScreen extends StatefulWidget {
  const StaffMainScreen({super.key});

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const DashboardContent(),
    const StaffEditAssetsTab(),
    const StaffProcessReturnTab(),
    const StaffHistoryTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: staffPrimaryColor,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: staffSecondaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined, size: 30),
                activeIcon: Icon(Icons.dashboard, size: 30),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit_outlined, size: 30),
                activeIcon: Icon(Icons.edit, size: 30),
                label: 'Edit Assets',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.refresh_outlined, size: 30),
                activeIcon: Icon(Icons.refresh, size: 30),
                label: 'Process Return',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined, size: 30),
                activeIcon: Icon(Icons.history, size: 30),
                label: 'History',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: staffSecondaryColor,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  // Use the IP that matches your setup
  final String _baseUrl = 'http://192.168.1.121:3000';

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
      final String? cookie = prefs.getString('sessionCookie');

      if (cookie == null) {
        throw Exception('Not logged in');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/dashboard'),
        headers: {'Cookie': cookie},
      );

      if (response.statusCode == 200) {
        setState(() {
          _dashboardData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load dashboard: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cookie = prefs.getString('sessionCookie');

      // Call API to destroy session
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {'Cookie': cookie ?? ''},
      );
    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      // Clear local storage and navigate to login
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const login_screen.LoginScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract data with fallbacks
    final String available = _dashboardData?['Available']?.toString() ?? '...';
    final String borrowed = _dashboardData?['Borrowed']?.toString() ?? '...';
    final String disabled = _dashboardData?['Disabled']?.toString() ?? '...';

    return Scaffold(
      backgroundColor: staffPrimaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildAppBar(context),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else if (_errorMessage != null)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Error loading dashboard',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: _fetchDashboardData,
                        ),
                      ],
                    ),
                  )
                else
                  _buildDashboardCard(available, borrowed, disabled),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'Welcome',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
    String available,
    String borrowed,
    String disabled,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                count: available,
                color: const Color(0xFF4CAF50),
                backgroundColor: const Color(0xFFF1F8F4),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: 'Borrowed',
                count: borrowed,
                color: const Color(0xFFF44336),
                backgroundColor: const Color(0xFFFFF3E0),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: 'Disabled',
                count: disabled,
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
}
