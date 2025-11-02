import 'package:flutter/material.dart';
import 'package:pj2/staff_theme.dart';

class StaffHistoryTab extends StatefulWidget {
  const StaffHistoryTab({Key? key}) : super(key: key);

  @override
  _StaffHistoryTabState createState() => _StaffHistoryTabState();
}

class _StaffHistoryTabState extends State<StaffHistoryTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allHistory = [
    {
      'assetName': 'iPad Air 5th Gen',
      'borrowerName': 'Barry Allen',
      'approverName': 'Dr. Harrison Wells',
      'borrowDate': DateTime(2025, 10, 20),
      'returnDate': DateTime(2025, 10, 22),
      'Processed By': 'Cisco Ramon',
      'status': 'returned',
    },
    {
      'assetName': 'Canon EOS R10',
      'borrowerName': 'Iris West',
      'approverName': 'Dr. Harrison Wells',
      'borrowDate': DateTime(2025, 10, 21),
      'returnDate': DateTime(2025, 10, 22),
      'Processed By': 'Cisco Ramon',
      'status': 'borrowed',
    },
    {
      'assetName': 'Macbook Air',
      'borrowerName': 'Oliver Queen',
      'approverName': 'Dr. Harrison Wells',
      'borrowDate': DateTime(2025, 10, 22),
      'returnDate': DateTime(2025, 10, 24),
      'Processed By': 'Cisco Ramon',
      'status': 'returned',
    },
    {
      'assetName': 'Asus VivoBook 14',
      'borrowerName': 'Caitlin Snow',
      'approverName': 'Dr. Harrison Wells',
      'borrowDate': DateTime(2025, 10, 18),
      'returnDate': DateTime(2025, 10, 20),
      'Processed By': 'Cisco Ramon',
      'status': 'returned',
    },
    {
      'assetName': 'IPad Air',
      'borrowerName': 'Stiles Stilinski',
      'approverName': 'Dr. Harrison Wells',
      'borrowDate': DateTime(2025, 10, 21),
      'returnDate': DateTime(2025, 10, 23),
      'Processed By': 'Cisco Ramon',
      'status': 'returned',
    },
    {
      'assetName': 'Macbook Air',
      'borrowerName': 'Stiles Stilinski',
      'approverName': 'Dr. Harrison Wells',
      'borrowDate': DateTime(2025, 10, 18),
      'returnDate': DateTime(2025, 10, 20),
      'Processed By': 'Cisco Ramon',
      'status': 'returned',
    },
  ];

  List<Map<String, dynamic>> get _filteredHistory {
    return _allHistory.where((history) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          (history['assetName']?.toLowerCase() ?? '').contains(
            _searchQuery.toLowerCase(),
          ) ||
          (history['borrowerName']?.toLowerCase() ?? '').contains(
            _searchQuery.toLowerCase(),
          );
      return matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _filteredHistory;

    return Scaffold(
      backgroundColor: staffPrimaryColor,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by asset',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: filteredHistory.isEmpty
                ? const Center(
                    child: Text(
                      'No matching records found',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final history = filteredHistory[index];
                      return _buildHistoryCard(history);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> history) {
    final status = history['status']?.toString() ?? 'unknown';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 3,
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
                    history['assetName'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
            _buildDetailRow('Borrowed by', history['borrowerName'] ?? 'N/A'),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Borrowed',
              _formatDate(history['borrowDate'] as DateTime),
            ),
            if (history['returnDate'] != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                'Returned',
                _formatDate(history['returnDate'] as DateTime),
              ),
            ],
            const SizedBox(height: 8),
            _buildDetailRow('Approved by', history['approverName'] ?? 'N/A'),
            if (history['Processed By'] != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Return approved by', history['Processed By']),
            ],

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _showDetailsDialog(context, history);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: staffButtonBlue,
                    backgroundColor: staffButtonBlue.withOpacity(0.1),
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
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'borrowed':
        return Colors.orange;
      case 'returned':
      default:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
              _buildDetailRowDialog(
                'Borrower',
                history['borrowerName'] ?? 'N/A',
              ),
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
                history['approverName'] ?? 'N/A',
              ),
              const SizedBox(height: 8),
              _buildDetailRowDialog(
                'Return Processed by',
                history['Processed By'] ?? 'N/A',
              ),
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
}
