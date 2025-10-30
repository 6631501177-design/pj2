import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lecturer Dashboard',
      home: const LecturerDashboard(),
    );
  }
}

class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({Key? key}) : super(key: key);

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3D6B7D),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildBodyForIndex(_index),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- App Bar ---
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF3D6B7D),
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
          TextButton(
            onPressed: () {
              // TODO: Logout logic
              debugPrint('Logout tapped');
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // --- Body per tab ---
  Widget _buildBodyForIndex(int idx) {
    switch (idx) {
      case 0:
        return Column(children: [_buildDashboardCard()]);
      case 1:
        return _placeholderCard(
          title: 'Assets',
          message: 'List and manage your assets here.',
        );
      case 2:
        return _placeholderCard(
          title: 'History',
          message: 'Borrow/return history will appear here.',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _placeholderCard({required String title, required String message}) {
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
          Text(title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              )),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  // --- Dashboard Card ---
  Widget _buildDashboardCard() {
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
                count: '13',
                color: const Color(0xFF4CAF50),
                backgroundColor: const Color(0xFFF1F8F4),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: 'Borrowed',
                count: '11',
                color: const Color(0xFFFF9800),
                backgroundColor: const Color(0xFFFFF3E0),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: 'Disabled',
                count: '4',
                color: const Color(0xFFF44336),
                backgroundColor: const Color(0xFFFFEBEE),
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

  // --- Bottom Navigation (custom, tappable) ---
  Widget _buildBottomNav(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material( // Material ancestor for InkWell
        color: const Color(0xFF2C5464),
        elevation: 8,
        child: SizedBox(
          height: 64, // consistent, generous tap target
          child: Row(
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                isActive: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
              _buildNavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Assets',
                isActive: _index == 1,
                onTap: () => setState(() => _index = 1),
              ),
              _buildNavItem(
                icon: Icons.history,
                label: 'History',
                isActive: _index == 2,
                onTap: () => setState(() => _index = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Each item takes equal width and full height for better hit testing
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color active = Colors.white;
    final Color inactive = Colors.white.withOpacity(0.6);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashFactory: InkRipple.splashFactory,
        child: Container(
          height: double.infinity, // make the whole area tappable
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isActive ? active : inactive, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? active : inactive,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
