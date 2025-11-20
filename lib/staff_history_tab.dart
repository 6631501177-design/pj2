import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pj2/staff_theme.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// UPDATE THIS IP TO MATCH YOUR SERVER
const String _baseUrl = 'http://192.168.1.121:3000';

class StaffHistoryTab extends StatefulWidget {
  const StaffHistoryTab({Key? key}) : super(key: key);

  @override
  _StaffHistoryTabState createState() => _StaffHistoryTabState();
}

class _StaffHistoryTabState extends State<StaffHistoryTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<dynamic> _allHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cookie = prefs.getString('sessionCookie');

      if (cookie == null) {
        throw Exception('You must be logged in to view history.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/history'),
        headers: {'Cookie': cookie},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _allHistory = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredHistory {
    if (_searchQuery.isEmpty) return _allHistory;
    return _allHistory.where((history) {
      final assetName = (history['asset_name'] ?? '').toString().toLowerCase();
      final borrowerName = (history['borrower_name'] ?? '')
          .toString()
          .toLowerCase();
      final q = _searchQuery.toLowerCase();
      return assetName.contains(q) || borrowerName.contains(q);
    }).toList();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => setState(() => _searchQuery = query),
              decoration: InputDecoration(
                hintText: 'Search by asset / borrower',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : filteredHistory.isEmpty
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
                      return _buildHistoryCard(filteredHistory[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> history) {
    // Data Mapping from app.js
    final assetName = history['asset_name'] ?? 'N/A';
    final borrowerName = history['borrower_name'] ?? 'N/A';
    final approverName = history['lender_name'] ?? 'N/A';
    final staffName = history['staff_name']; // Can be null if not returned yet
    final borrowDate = history['borrow_date'];
    final returnDate = history['return_date'];
    final status = history['status']?.toString() ?? 'unknown';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    assetName,
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Borrowed by', borrowerName),
            const SizedBox(height: 8),
            _buildDetailRow('Borrowed', _formatDate(borrowDate)),
            if (returnDate != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Returned', _formatDate(returnDate)),
            ],
            const SizedBox(height: 8),
            _buildDetailRow('Approved by', approverName),
            if (staffName != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Return processed by', staffName),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showDetailsDialog(context, history),
                  style: TextButton.styleFrom(
                    foregroundColor: staffButtonBlue,
                    backgroundColor: staffButtonBlue.withOpacity(0.1),
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
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
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
      case 'approved':
        return Colors.green;
      case 'disapproved':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null || date.toString() == 'N/A') return 'N/A';
    try {
      final parsed = DateTime.parse(date.toString());
      return '${parsed.day}/${parsed.month}/${parsed.year}';
    } catch (e) {
      return date.toString();
    }
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> history) {
    final assetName = history['asset_name'] ?? 'N/A';
    final borrowerName = history['borrower_name'] ?? 'N/A';
    final approverName = history['lender_name'] ?? 'N/A';
    final staffName = history['staff_name'] ?? 'N/A';
    final borrowDate = history['borrow_date'];
    final returnDate = history['return_date'];
    final status = history['status']?.toString() ?? 'N/A';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Details - $assetName'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRowDialog('Borrower', borrowerName),
              const SizedBox(height: 8),
              _buildDetailRowDialog('Borrowed On', _formatDate(borrowDate)),
              if (returnDate != null) ...[
                const SizedBox(height: 8),
                _buildDetailRowDialog('Returned On', _formatDate(returnDate)),
              ],
              const SizedBox(height: 8),
              _buildDetailRowDialog('Status', status.toUpperCase()),
              const Divider(height: 20),
              _buildDetailRowDialog('Approved by', approverName),
              const SizedBox(height: 8),
              _buildDetailRowDialog('Return Processed by', staffName),
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
            width: 110,
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

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:pj2/staff_theme.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class StaffHistoryTab extends StatefulWidget {
//   const StaffHistoryTab({Key? key}) : super(key: key);

//   @override
//   _StaffHistoryTabState createState() => _StaffHistoryTabState();
// }

// class _StaffHistoryTabState extends State<StaffHistoryTab> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   final String _baseUrl = 'http://192.168.1.121:3000';
//   // final String _baseUrl = 'http://172.22.112.1:3000';

//   List<dynamic> _allHistory = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadHistory();
//   }

//   Future<void> _loadHistory() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? cookie = prefs.getString('sessionCookie');

//       if (cookie == null) {
//         throw Exception('You must be logged in to view history.');
//       }

//       final response = await http.get(
//         Uri.parse('$_baseUrl/api/history'),
//         headers: {'Cookie': cookie},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         setState(() {
//           _allHistory = data;
//           _isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load history: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("Error: $e");
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   List<dynamic> get _filteredHistory {
//     if (_searchQuery.isEmpty) return _allHistory;

//     return _allHistory.where((history) {
//       // FIX: Use keys that match app.js
//       final assetName = (history['asset_name'] ?? '').toString().toLowerCase();
//       final borrowerName = (history['borrower_name'] ?? '')
//           .toString()
//           .toLowerCase();
//       final q = _searchQuery.toLowerCase();

//       return assetName.contains(q) || borrowerName.contains(q);
//     }).toList();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredHistory = _filteredHistory;

//     return Scaffold(
//       backgroundColor: staffPrimaryColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         title: const Text(
//           'Borrowing History',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: _loadHistory,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16.0,
//               vertical: 8.0,
//             ),
//             child: TextField(
//               controller: _searchController,
//               onChanged: (query) {
//                 setState(() {
//                   _searchQuery = query;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Search by asset / borrower',
//                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: Colors.white),
//                   )
//                 : filteredHistory.isEmpty
//                 ? const Center(
//                     child: Text(
//                       'No matching records found',
//                       style: TextStyle(color: Colors.white70, fontSize: 16),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: filteredHistory.length,
//                     itemBuilder: (context, index) {
//                       final history = filteredHistory[index];
//                       return _buildHistoryCard(history);
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHistoryCard(Map<String, dynamic> history) {
//     // FIX: Use keys that match app.js
//     final assetName = history['asset_name'] ?? 'N/A';
//     final borrowerName = history['borrower_name'] ?? 'N/A';
//     final approverName = history['lender_name'] ?? 'N/A';
//     final staffName = history['staff_name']; // Can be null
//     final borrowDate = history['borrow_date'];
//     final returnDate = history['return_date'];

//     final status = history['status']?.toString() ?? 'unknown';
//     final statusColor = _getStatusColor(status);

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     assetName,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     status.toUpperCase(),
//                     style: TextStyle(
//                       color: statusColor,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 24),

//             _buildDetailRow('Borrowed by', borrowerName),
//             const SizedBox(height: 8),

//             _buildDetailRow('Borrowed', _formatDate(borrowDate)),

//             if (returnDate != null && returnDate != 'N/A') ...[
//               const SizedBox(height: 8),
//               _buildDetailRow('Returned', _formatDate(returnDate)),
//             ],

//             const SizedBox(height: 8),
//             _buildDetailRow('Approved by', approverName),

//             if (staffName != null) ...[
//               const SizedBox(height: 8),
//               _buildDetailRow('Return approved by', staffName),
//             ],

//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     _showDetailsDialog(context, history);
//                   },
//                   style: TextButton.styleFrom(
//                     foregroundColor: staffButtonBlue,
//                     backgroundColor: staffButtonBlue.withOpacity(0.1),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text('View Details'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 140,
//           child: Text(
//             label,
//             style: const TextStyle(color: Colors.grey, fontSize: 14),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.black87,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'borrowed':
//         return Colors.orange;
//       case 'returned':
//       case 'approved':
//         return Colors.green;
//       case 'disapproved':
//         return Colors.red;
//       default:
//         return Colors.blueGrey;
//     }
//   }

//   String _formatDate(dynamic date) {
//     if (date == null || date.toString() == 'N/A') return 'N/A';
//     try {
//       final parsed = DateTime.parse(date.toString());
//       return '${parsed.day.toString().padLeft(2, '0')}/'
//           '${parsed.month.toString().padLeft(2, '0')}/'
//           '${parsed.year}';
//     } catch (e) {
//       return date
//           .toString(); // Return original string if already formatted by SQL
//     }
//   }

//   void _showDetailsDialog(BuildContext context, Map<String, dynamic> history) {
//     // FIX: Use keys that match app.js
//     final assetName = history['asset_name'] ?? 'N/A';
//     final borrowerName = history['borrower_name'] ?? 'N/A';
//     final approverName = history['lender_name'] ?? 'N/A';
//     final staffName = history['staff_name'] ?? 'N/A';
//     final borrowDate = history['borrow_date'];
//     final returnDate = history['return_date'];
//     final status = history['status']?.toString() ?? 'N/A';

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Details - $assetName'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildDetailRowDialog('Borrower', borrowerName),
//               const SizedBox(height: 8),
//               _buildDetailRowDialog('Borrowed On', _formatDate(borrowDate)),
//               if (returnDate != null && returnDate != 'N/A') ...[
//                 const SizedBox(height: 8),
//                 _buildDetailRowDialog('Returned On', _formatDate(returnDate)),
//               ],
//               const SizedBox(height: 8),
//               _buildDetailRowDialog('Status', status.toUpperCase()),
//               const Divider(height: 20),
//               _buildDetailRowDialog('Approved by', approverName),
//               const SizedBox(height: 8),
//               _buildDetailRowDialog('Return Processed by', staffName),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRowDialog(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 110,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           const Text(': '),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }
// }
