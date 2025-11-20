import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Colors
const Color primaryColor = Color(0xFF0A4D68);
const Color bodyTextColor = Colors.white;
const Color subtitleTextColor = Colors.white70;
const Color cardColor = Color(0xFFFFFFFF);

// --- API URL ---
const String _apiUrl = '192.168.1.121:3000';
// const String _apiUrl = '172.27.22.205:3000';

class StudentHistoryTab extends StatefulWidget {
  const StudentHistoryTab({super.key});

  @override
  State<StudentHistoryTab> createState() => _StudentHistoryTabState();
}

class _StudentHistoryTabState extends State<StudentHistoryTab> {
  Future<List<dynamic>>? _futureHistory;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _futureHistory = _fetchHistory();
    });
  }

  Future<List<dynamic>> _fetchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cookie = prefs.getString('sessionCookie');

      if (cookie == null) {
        throw Exception('You must be logged in to view history.');
      }

      final response = await http
          .get(Uri.http(_apiUrl, '/api/history'), headers: {'Cookie': cookie})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data as List<dynamic>; // Return the actual data
      } else {
        throw Exception(
          'Failed to load history. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Re-throw the error so the FutureBuilder can catch it
      throw Exception('Error fetching history: $e');
    }
  }

  // Updated to handle null
  String _formatDate(String? dateString) {
    if (dateString == null || dateString == 'N/A') return 'N/A';
    try {
      // Parse the date and convert to local timezone
      final date = DateTime.parse(dateString).toLocal();
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: bodyTextColor,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
              future: _futureHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.orange),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No history found',
                      style: TextStyle(color: subtitleTextColor),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return _buildHistoryCard(
                      context,
                      item['asset_name'] ?? 'Unknown Asset',
                      item['borrow_date'],
                      item['return_date'],
                      item['status'] ?? 'Unknown',
                      // --- Pass new data from app.js ---
                      item['borrower_name'],
                      item['lender_name'],
                      item['staff_name'],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    String assetName,
    String? borrowDate,
    String? returnDate,
    String status,
    // --- Accept new data ---
    String? borrowerName,
    String? lenderName,
    String? staffName,
  ) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    assetName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _buildStatusChip(status), // Use the dynamic status
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Borrowed: ${_formatDate(borrowDate)}',
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              Icons.calendar_today,
              'Returned: ${_formatDate(returnDate)}',
            ),
            const Divider(height: 20),
            // --- Display new data ---
            _buildInfoRow(
              Icons.person_outline,
              'Borrowed by: ${borrowerName ?? 'N/A'}',
              size: 12,
            ),
            _buildInfoRow(
              Icons.verified_user_outlined,
              'Approved by: ${lenderName ?? 'N/A'}',
              size: 12,
            ),
            // Only show 'Return by' if staffName is not null
            if (staffName != null)
              _buildInfoRow(
                Icons.assignment_ind_outlined,
                'Return by: $staffName',
                size: 12,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {double size = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: size, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: size, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  // This widget now builds the status chip based on the data
  Widget _buildStatusChip(String status) {
    final String statusText = status.toUpperCase();
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'disapproved':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// // Colors
// const Color primaryColor = Color(0xFF0A4D68);
// const Color bodyTextColor = Colors.white;
// const Color subtitleTextColor = Colors.white70;
// const Color cardColor = Color(0xFFFFFFFF);

// const String _apiUrl = '192.168.1.121:3000';
// // const String _apiUrl = '172.27.14.220:3000';

// class StudentHistoryTab extends StatefulWidget {
//   const StudentHistoryTab({super.key});

//   @override
//   State<StudentHistoryTab> createState() => _StudentHistoryTabState();
// }

// class _StudentHistoryTabState extends State<StudentHistoryTab> {
//   Future<List<dynamic>>? _futureHistory;

//   @override
//   void initState() {
//     super.initState();
//     _loadHistory();
//   }

//   void _loadHistory() {
//     setState(() {
//       _futureHistory = _fetchHistory();
//     });
//   }

//   Future<List<dynamic>> _fetchHistory() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? cookie = prefs.getString('sessionCookie');

//       if (cookie == null) {
//         throw Exception('You must be logged in to view history.');
//       }

//       final response = await http
//           .get(Uri.http(_apiUrl, '/api/history'), headers: {'Cookie': cookie})
//           .timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data as List<dynamic>;
//       } else {
//         throw Exception(
//           'Failed to load history. Status code: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       // Re-throw the error so the FutureBuilder can catch it
//       throw Exception('Error fetching history: $e');
//     }
//   }

//   String _formatDate(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       return '${date.day} ${_getMonthName(date.month)} ${date.year}';
//     } catch (e) {
//       return dateString;
//     }
//   }

//   String _getMonthName(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryColor,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'My History',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: bodyTextColor,
//               ),
//             ),
//             const SizedBox(height: 16),
//             FutureBuilder<List<dynamic>>(
//               future: _futureHistory,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(color: Colors.white),
//                   );
//                 }

//                 if (snapshot.hasError) {
//                   return Center(
//                     child: Text(
//                       'Error: ${snapshot.error}',
//                       style: const TextStyle(color: Colors.orange),
//                       textAlign: TextAlign.center,
//                     ),
//                   );
//                 }

//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'No history found',
//                       style: TextStyle(color: subtitleTextColor),
//                     ),
//                   );
//                 }

//                 return ListView.separated(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: snapshot.data!.length,
//                   separatorBuilder: (context, index) =>
//                       const SizedBox(height: 12),
//                   itemBuilder: (context, index) {
//                     final item = snapshot.data![index];
//                     return _buildHistoryCard(
//                       context,
//                       item['asset_name'] ?? 'Unknown Asset',
//                       item['borrow_date'] ?? 'N/A',
//                       item['return_date'] ?? 'N/A',
//                       item['status'] ?? 'Unknown',
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHistoryCard(
//     BuildContext context,
//     String assetName,
//     String borrowDate,
//     String returnDate,
//     String status, // Receive the status
//   ) {
//     return Card(
//       color: cardColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
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
//                 _buildStatusChip(status), // Use the dynamic status
//               ],
//             ),
//             const SizedBox(height: 12),
//             _buildInfoRow(
//               Icons.calendar_today_outlined,
//               'Borrowed: ${_formatDate(borrowDate)}',
//             ),
//             const SizedBox(height: 4),
//             _buildInfoRow(
//               Icons.calendar_today,
//               'Returned: ${_formatDate(returnDate)}',
//             ),
//             // Removed the hard-coded "Approved by" and "Processed by" fields
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text, {double size = 14}) {
//     return Row(
//       children: [
//         Icon(icon, size: size, color: Colors.grey[600]),
//         const SizedBox(width: 8),
//         Text(
//           text,
//           style: TextStyle(fontSize: size, color: Colors.grey[800]),
//         ),
//       ],
//     );
//   }

//   // This widget now builds the status chip based on the data
//   Widget _buildStatusChip(String status) {
//     final String statusText = status.toUpperCase();
//     Color statusColor;

//     switch (status.toLowerCase()) {
//       case 'approved':
//         statusColor = Colors.green;
//         break;
//       case 'disapproved':
//         statusColor = Colors.red;
//         break;
//       default:
//         statusColor = Colors.grey;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: statusColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         statusText,
//         style: TextStyle(
//           color: statusColor,
//           fontWeight: FontWeight.w500,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }
// }
