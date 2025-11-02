import 'package:flutter/material.dart';
import 'package:pj2/lecturer_dashboard_tab.dart';
import 'package:pj2/lecturer_browse_tab.dart';
import 'package:pj2/lecturer_requested_tab.dart';
import 'package:pj2/student_main_screen.dart';

class LecturerHistoryPage extends StatefulWidget {
  const LecturerHistoryPage({super.key});

  @override
  _LecturerHistoryPageState createState() => _LecturerHistoryPageState();
}

class _LecturerHistoryPageState extends State<LecturerHistoryPage> {
  final List<Map<String, dynamic>> _history = [
    {
      'assetName': 'iPad Air 5th Gen',
      'borrower': 'Barry Allen',
      'approver': 'Dr. Harrison Wells',
      'borrowDate': DateTime(2025, 10, 20),
      'returnDate': DateTime(2025, 10, 22),
      'staff': 'John Diggle',
      'status': 'returned',
    },
    {
      'assetName': 'Canon EOS R10',
      'borrower': 'Iris West',
      'approver': 'Dr. Harrison Wells',
      'borrowDate': DateTime(2025, 10, 23),
      'returnDate': DateTime(2025, 10, 25),
      'staff': 'Sara Lance',
      'status': 'borrowed',
    },
    {
      'assetName': 'Asus VivoBook 15',
      'borrower': 'Oliver Queen',
      'approver': 'Dr. Harrison Wells',
      'borrowDate': DateTime(2025, 10, 22),
      'returnDate': DateTime(2025, 10, 24),
      'staff': 'Cisco Ramon',
      'status': 'returned',
    },
    {
      'assetName': 'Samsung Tab S10',
      'borrower': 'Ray Palmer',
      'approver': 'Dr. Harrison Wells',
      'borrowDate': DateTime(2025, 10, 23),
      'returnDate': DateTime(2025, 10, 24),
      'staff': 'Caitlin Snow',
      'status': 'returned',
    },
    {
      'assetName': 'Macbook Air',
      'borrower': 'Ray Palmer',
      'approver': 'Dr. Harrison Wells',
      'borrowDate': DateTime(2025, 10, 22),
      'returnDate': DateTime(2025, 10, 24),
      'staff': 'Caitlin Snow',
      'status': 'returned',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Borrowing History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final history = _history[index];
          return _buildHistoryCard(history);
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> history) {
    final status = history['status']?.toString() ?? 'unknown';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    history['assetName'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Borrowed by', '${history['borrower']}'),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Borrow Date',
              _formatDate(history['borrowDate'] as DateTime),
            ),
            if (history['returnDate'] != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                'Return Date',
                _formatDate(history['returnDate'] as DateTime),
              ),
            ],
            const SizedBox(height: 8),
            _buildDetailRow('Approved by', history['approver']),
            const SizedBox(height: 8),
            _buildDetailRow('Staff', history['staff'] ?? 'N/A'),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _showDetailsDialog(context, history);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF4F709C).withValues(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'returned':
        return Colors.green;
      case 'overdue':
        return Colors.orange;
      case 'borrowed':
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Details - ${history['assetName'] ?? 'Asset'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRowDialog('Borrower', history['borrower'] ?? 'N/A'),
              const SizedBox(height: 8),
              _buildDetailRowDialog(
                'Borrowed On',
                _formatDate(history['borrowDate'] as DateTime),
              ),
              if (history['returnDate'] != null) ...[
                const SizedBox(height: 8),
                _buildDetailRowDialog(
                  'Returned On',
                  _formatDate(history['returnDate'] as DateTime),
                ),
              ],
              const SizedBox(height: 8),
              _buildDetailRowDialog(
                'Status',
                (history['status'] ?? 'N/A').toString().toUpperCase(),
              ),
              const Divider(height: 20),
              _buildDetailRowDialog(
                'Approved by',
                history['approver'] ?? 'N/A',
              ),
              const SizedBox(height: 8),
              _buildDetailRowDialog('Staff', history['staff'] ?? 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowDialog(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
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
                isActive: false,
                onTap: () => _navigateTo(context, const LecturerBrowseAssets()),
              ),
              _buildNavItem(
                icon: Icons.history,
                label: 'History',
                isActive: true,
                onTap: () {},
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
