import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pj2/lecturer_dashboard_tab.dart';
import 'package:pj2/lecturer_browse_tab.dart';
import 'package:pj2/lecturer_request_page.dart';

const Color primaryColor = Color(0xFF0A4D68);
const Color secondaryColor = Color(0xFF088395);
const Color cardColor = Color(0xFFFFFFFF);
const Color cardTextColor = Colors.black;
const Color bodyTextColor = Colors.white;
const Color subtitleTextColor = Colors.white70;
const Color availableColor = Color(0xFF28A745);
const Color pendingColor = Color(0xFFFFA500);
const Color buttonColor = Color(0xFF4F709C);

// --- API URL ---
// Updated to match your app.js allowedOrigins
// const String _apiUrl = '192.168.1.121:3000';
const String _apiUrl = '172.27.22.205:3000';

class LecturerHistoryPage extends StatefulWidget {
  const LecturerHistoryPage({super.key});

  @override
  _LecturerHistoryPageState createState() => _LecturerHistoryPageState();
}

class _LecturerHistoryPageState extends State<LecturerHistoryPage> {
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
      body: FutureBuilder<List<dynamic>>(
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final history = snapshot.data![index];
              return _buildHistoryCard(history);
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> history) {
    final String assetName = history['asset_name'] ?? 'Unknown Asset';
    final String? borrowDate = history['borrow_date'];
    final String? returnDate = history['return_date'];
    final String status = history['status'] ?? 'unknown';

    final String borrowerName = history['borrower_name'] ?? 'N/A';
    final String lenderName = history['lender_name'] ?? 'N/A';
    final String? staffName = history['staff_name'];

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
                    assetName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(status), // Use the dynamic status
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Borrow Date', _formatDate(borrowDate)),
            if (returnDate != null && returnDate != 'N/A') ...[
              const SizedBox(height: 8),
              _buildDetailRow('Return Date', _formatDate(returnDate)),
            ],
            const Divider(height: 20),
            // --- Display new data ---
            _buildDetailRow('Borrowed by', borrowerName),
            const SizedBox(height: 8),
            _buildDetailRow('Approved by', lenderName),
            // Only show 'Return by' if staffName is not null
            if (staffName != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Return by', staffName),
            ],
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

  // Helper function to format date string
  String _formatDate(String? dateString) {
    if (dateString == null || dateString == 'N/A') return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  // Helper function to get month name
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

  // --- Bottom Navigation Bar ---
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

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pj2/lecturer_dashboard_tab.dart';
// import 'package:pj2/lecturer_browse_tab.dart';
// import 'package:pj2/lecturer_request_page.dart';

// const Color primaryColor = Color(0xFF0A4D68);
// const Color secondaryColor = Color(0xFF088395);
// const Color cardColor = Color(0xFFFFFFFF);
// const Color cardTextColor = Colors.black;
// const Color bodyTextColor = Colors.white;
// const Color subtitleTextColor = Colors.white70;
// const Color availableColor = Color(0xFF28A745);
// const Color pendingColor = Color(0xFFFFA500);
// const Color buttonColor = Color(0xFF4F709C);

// // --- API URL ---
// const String _apiUrl = '192.168.1.121:3000';
// // const String _apiUrl = '172.22.112.1:3000';

// class LecturerHistoryPage extends StatefulWidget {
//   const LecturerHistoryPage({super.key});

//   @override
//   _LecturerHistoryPageState createState() => _LecturerHistoryPageState();
// }

// class _LecturerHistoryPageState extends State<LecturerHistoryPage> {
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
//         return data as List<dynamic>; // Return the actual data
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryColor,
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
//       ),
//       body: FutureBuilder<List<dynamic>>(
//         future: _futureHistory,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: Colors.white),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'Error: ${snapshot.error}',
//                 style: const TextStyle(color: Colors.orange),
//                 textAlign: TextAlign.center,
//               ),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text(
//                 'No history found',
//                 style: TextStyle(color: subtitleTextColor),
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: snapshot.data!.length,
//             itemBuilder: (context, index) {
//               final history = snapshot.data![index];
//               return _buildHistoryCard(history);
//             },
//           );
//         },
//       ),
//       bottomNavigationBar: _buildBottomNav(context),
//     );
//   }

//   Widget _buildHistoryCard(Map<String, dynamic> history) {
//     final String assetName = history['asset_name'] ?? 'Unknown Asset';
//     final String? borrowDate = history['borrow_date'];
//     final String? returnDate = history['return_date'];
//     final String status = history['status'] ?? 'unknown';

//     // --- Get new data from app.js ---
//     final String borrowerName = history['borrower_name'] ?? 'N/A';
//     final String lenderName = history['lender_name'] ?? 'N/A';
//     final String? staffName = history['staff_name']; // Can be null

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
//                     ),
//                   ),
//                 ),
//                 _buildStatusChip(status), // Use the dynamic status
//               ],
//             ),
//             const Divider(height: 24),
//             _buildDetailRow('Borrow Date', _formatDate(borrowDate)),
//             if (returnDate != null && returnDate != 'N/A') ...[
//               const SizedBox(height: 8),
//               _buildDetailRow('Return Date', _formatDate(returnDate)),
//             ],
//             const Divider(height: 20),
//             // --- Display new data ---
//             _buildDetailRow('Borrowed by', borrowerName),
//             const SizedBox(height: 8),
//             _buildDetailRow('Approved by', lenderName),
//             // Only show 'Return by' if staffName is not null
//             if (staffName != null) ...[
//               const SizedBox(height: 8),
//               _buildDetailRow('Return by', staffName),
//             ],
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
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
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

//   // Helper function to format date string
//   String _formatDate(String? dateString) {
//     if (dateString == null || dateString == 'N/A') return 'N/A';
//     try {
//       final date = DateTime.parse(dateString);
//       return '${date.day} ${_getMonthName(date.month)} ${date.year}';
//     } catch (e) {
//       return dateString; // Return original if parsing fails
//     }
//   }

//   // Helper function to get month name
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

//   // --- Bottom Navigation Bar ---
//   Widget _buildBottomNav(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF2C5464),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(
//                 icon: Icons.home,
//                 label: 'Home',
//                 isActive: false,
//                 onTap: () => _navigateTo(context, const LecturerDashboard()),
//               ),
//               _buildNavItem(
//                 icon: Icons.list_alt,
//                 label: 'Requested',
//                 isActive: false,
//                 onTap: () => _navigateTo(context, const LecturerRequestPage()),
//               ),
//               _buildNavItem(
//                 icon: Icons.search,
//                 label: 'Browse',
//                 isActive: false,
//                 onTap: () => _navigateTo(context, const LecturerBrowseAssets()),
//               ),
//               _buildNavItem(
//                 icon: Icons.history,
//                 label: 'History',
//                 isActive: true,
//                 onTap: () {},
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _navigateTo(BuildContext context, Widget page) {
//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (_, __, ___) => page,
//         transitionDuration: Duration.zero,
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required IconData icon,
//     required String label,
//     required bool isActive,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
//             size: 28,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
//               fontSize: 12,
//               fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:pj2/lecturer_dashboard_tab.dart';
// // import 'package:pj2/lecturer_browse_tab.dart';
// // import 'package:pj2/lecturer_request_page.dart';

// // const Color primaryColor = Color(0xFF0A4D68);
// // const Color secondaryColor = Color(0xFF088395);
// // const Color cardColor = Color(0xFFFFFFFF);
// // const Color cardTextColor = Colors.black;
// // const Color bodyTextColor = Colors.white;
// // const Color subtitleTextColor = Colors.white70;
// // const Color availableColor = Color(0xFF28A745);
// // const Color pendingColor = Color(0xFFFFA500);
// // const Color buttonColor = Color(0xFF4F709C);

// // // API URL (Make sure this is correct for your network)
// // const String _apiUrl = '192.168.1.121:3000';

// // class LecturerHistoryPage extends StatefulWidget {
// //   const LecturerHistoryPage({super.key});

// //   @override
// //   _LecturerHistoryPageState createState() => _LecturerHistoryPageState();
// // }

// // class _LecturerHistoryPageState extends State<LecturerHistoryPage> {
// //   Future<List<dynamic>>? _futureHistory;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadHistory();
// //   }

// //   void _loadHistory() {
// //     setState(() {
// //       _futureHistory = _fetchHistory();
// //     });
// //   }

// //   Future<List<dynamic>> _fetchHistory() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final String? cookie = prefs.getString('sessionCookie');

// //       if (cookie == null) {
// //         throw Exception('You must be logged in to view history.');
// //       }

// //       final response = await http
// //           .get(Uri.http(_apiUrl, '/api/history'), headers: {'Cookie': cookie})
// //           .timeout(const Duration(seconds: 10));

// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);
// //         return data as List<dynamic>; // Return the actual data
// //       } else {
// //         throw Exception(
// //           'Failed to load history. Status code: ${response.statusCode}',
// //         );
// //       }
// //     } catch (e) {
// //       // Re-throw the error so the FutureBuilder can catch it
// //       throw Exception('Error fetching history: $e');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: primaryColor,
// //       appBar: AppBar(
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         automaticallyImplyLeading: false,
// //         title: const Text(
// //           'Borrowing History',
// //           style: TextStyle(
// //             color: Colors.white,
// //             fontSize: 24,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ),
// //       body: FutureBuilder<List<dynamic>>(
// //         future: _futureHistory,
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(
// //               child: CircularProgressIndicator(color: Colors.white),
// //             );
// //           }

// //           if (snapshot.hasError) {
// //             return Center(
// //               child: Text(
// //                 'Error: ${snapshot.error}',
// //                 style: const TextStyle(color: Colors.orange),
// //                 textAlign: TextAlign.center,
// //               ),
// //             );
// //           }

// //           if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //             return const Center(
// //               child: Text(
// //                 'No history found',
// //                 style: TextStyle(color: subtitleTextColor),
// //               ),
// //             );
// //           }

// //           return ListView.builder(
// //             padding: const EdgeInsets.all(16),
// //             itemCount: snapshot.data!.length,
// //             itemBuilder: (context, index) {
// //               final history = snapshot.data![index];
// //               return _buildHistoryCard(history);
// //             },
// //           );
// //         },
// //       ),
// //       bottomNavigationBar: _buildBottomNav(context),
// //     );
// //   }

// //   Widget _buildHistoryCard(Map<String, dynamic> history) {
// //     final String assetName = history['asset_name'] ?? 'Unknown Asset';
// //     final String borrowDate = history['borrow_date'] ?? 'N/A';
// //     final String returnDate = history['return_date'] ?? 'N/A';
// //     final String status = history['status']?.toLowerCase() ?? 'unknown';
// //     final String? approvedBy = history['approved_by']?.toString();
// //     final String? processedBy = history['processed_by']?.toString();
// //     final bool isReturned = status == 'returned' || status == 'completed';

// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Expanded(
// //                   child: Text(
// //                     assetName,
// //                     style: const TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //                 _buildStatusChip(status),
// //               ],
// //             ),
// //             const Divider(height: 24),
// //             _buildDetailRow('Borrow Date', _formatDate(borrowDate)),
// //             if (returnDate != 'N/A') ...[
// //               const SizedBox(height: 8),
// //               _buildDetailRow('Return Date', _formatDate(returnDate)),
// //             ],
// //             const SizedBox(height: 8),
// //             if (approvedBy != null && approvedBy.isNotEmpty) ...[
// //               _buildDetailRow('Approved by', approvedBy),
// //               const SizedBox(height: 8),
// //             ],
// //             if (isReturned &&
// //                 processedBy != null &&
// //                 processedBy.isNotEmpty) ...[
// //               _buildDetailRow('Processed by', processedBy),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDetailRow(String label, String value) {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         SizedBox(
// //           width: 140,
// //           child: Text(
// //             label,
// //             style: const TextStyle(color: Colors.grey, fontSize: 14),
// //           ),
// //         ),
// //         const SizedBox(width: 8),
// //         Expanded(
// //           child: Text(
// //             value,
// //             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // This widget now builds the status chip based on the data
// //   Widget _buildStatusChip(String status) {
// //     final String statusText = status.toUpperCase();
// //     Color statusColor;

// //     switch (status.toLowerCase()) {
// //       case 'approved':
// //         statusColor = Colors.green;
// //         break;
// //       case 'disapproved':
// //         statusColor = Colors.red;
// //         break;
// //       default:
// //         statusColor = Colors.grey;
// //     }

// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //       decoration: BoxDecoration(
// //         color: statusColor.withOpacity(0.1),
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Text(
// //         statusText,
// //         style: TextStyle(
// //           color: statusColor,
// //           fontWeight: FontWeight.w500,
// //           fontSize: 12,
// //         ),
// //       ),
// //     );
// //   }

// //   // Helper function to format date string
// //   String _formatDate(String dateString) {
// //     try {
// //       final date = DateTime.parse(dateString);
// //       return '${date.day} ${_getMonthName(date.month)} ${date.year}';
// //     } catch (e) {
// //       return dateString; // Return original if parsing fails
// //     }
// //   }

// //   // Helper function to get month name
// //   String _getMonthName(int month) {
// //     const months = [
// //       'Jan',
// //       'Feb',
// //       'Mar',
// //       'Apr',
// //       'May',
// //       'Jun',
// //       'Jul',
// //       'Aug',
// //       'Sep',
// //       'Oct',
// //       'Nov',
// //       'Dec',
// //     ];
// //     return months[month - 1];
// //   }

// //   // --- Bottom Navigation Bar ---
// //   Widget _buildBottomNav(BuildContext context) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: const Color(0xFF2C5464),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.2),
// //             blurRadius: 8,
// //             offset: const Offset(0, -2),
// //           ),
// //         ],
// //       ),
// //       child: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(vertical: 8),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceAround,
// //             children: [
// //               _buildNavItem(
// //                 icon: Icons.home,
// //                 label: 'Home',
// //                 isActive: false,
// //                 onTap: () => _navigateTo(context, const LecturerDashboard()),
// //               ),
// //               _buildNavItem(
// //                 icon: Icons.list_alt,
// //                 label: 'Requested',
// //                 isActive: false,
// //                 onTap: () => _navigateTo(context, const LecturerRequestPage()),
// //               ),
// //               _buildNavItem(
// //                 icon: Icons.search,
// //                 label: 'Browse',
// //                 isActive: false,
// //                 onTap: () => _navigateTo(context, const LecturerBrowseAssets()),
// //               ),
// //               _buildNavItem(
// //                 icon: Icons.history,
// //                 label: 'History',
// //                 isActive: true,
// //                 onTap: () {},
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   void _navigateTo(BuildContext context, Widget page) {
// //     Navigator.pushReplacement(
// //       context,
// //       PageRouteBuilder(
// //         pageBuilder: (_, __, ___) => page,
// //         transitionDuration: Duration.zero,
// //       ),
// //     );
// //   }

// //   Widget _buildNavItem({
// //     required IconData icon,
// //     required String label,
// //     required bool isActive,
// //     required VoidCallback onTap,
// //   }) {
// //     return InkWell(
// //       onTap: onTap,
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(
// //             icon,
// //             color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
// //             size: 28,
// //           ),
// //           const SizedBox(height: 4),
// //           Text(
// //             label,
// //             style: TextStyle(
// //               color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
// //               fontSize: 12,
// //               fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
