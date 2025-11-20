import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'lecturer_dashboard_tab.dart';
import 'lecturer_browse_tab.dart';
import 'lecturer_history_page.dart';

const Color primaryColor = Color(0xFF0A4D68);
const Color secondaryColor = Color(0xFF088395);
const Color cardColor = Color(0xFFFFFFFF);
const Color cardTextColor = Colors.black;
const Color bodyTextColor = Colors.white;
const Color subtitleTextColor = Colors.white70;
const Color availableColor = Color(0xFF28A745);
const Color pendingColor = Color(0xFFFFA500);
const Color buttonColor = Color(0xFF4F709C);

class RequestedAsset {
  final int requestId;
  final String studentName;
  final String assetName;
  final String borrowDate;
  final String returnDate;
  final String status;

  RequestedAsset({
    required this.requestId,
    required this.studentName,
    required this.assetName,
    required this.borrowDate,
    required this.returnDate,
    required this.status,
  });

  // Factory is not used by this file's logic, but is fine to keep
  factory RequestedAsset.fromJson(Map<String, dynamic> json) {
    return RequestedAsset(
      requestId: json['request_id'] ?? 0,
      studentName: json['student_name'] ?? 'Unknown Student',
      assetName: json['asset_name'] ?? 'Unknown Asset',
      borrowDate: json['borrow_date'] ?? 'N/A',
      returnDate: json['return_date'] ?? 'N/A',
      // returnDate: json['return_date']?.toString() ?? 'N/A',
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
    );
  }
}

class LecturerRequestPage extends StatefulWidget {
  const LecturerRequestPage({super.key});

  @override
  State<LecturerRequestPage> createState() => _LecturerRequestPageState();
}

class _LecturerRequestPageState extends State<LecturerRequestPage> {
  // --- IP UPDATED to match your app.js ---
  final String baseUrl = 'http://192.168.1.121:3000';
  // final String baseUrl = 'http://172.27.22.205:3000';
  List<RequestedAsset> requestedAssets = [];
  bool isLoading = true;
  String message = '';
  // --- SELECTED INDEX FIXED (was 2, should be 1) ---
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('sessionCookie') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/checkrequest'),
        headers: {'Cookie': sessionCookie},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          requestedAssets = responseData.map((item) {
            // Map the server response to match your RequestedAsset model
            return RequestedAsset(
              requestId: item['id'],
              studentName: item['borrowed_by'] ?? 'Unknown Student',
              assetName: item['asset_name'] ?? 'Unknown Asset',
              borrowDate: item['borrow_date']?.toString() ?? 'N/A',
              // --- RETURN DATE FIXED ---
              // This will now correctly read 'return_date' if it exists
              // (But your app.js is not sending it)
              returnDate: item['return_date']?.toString() ?? 'N/A',
              status: (item['status'] ?? 'pending').toString().toLowerCase(),
            );
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load requests: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        message = 'Error: $e';
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching requests: $e')));
      }
    }
  }

  Future<void> approveRequest(int requestId) async {
    bool? shouldApprove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Approve Request'),
          content: const Text('Are you sure you want to approve this request?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (shouldApprove != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('sessionCookie') ?? '';

      final response = await http.patch(
        Uri.parse('$baseUrl/api/borrow/$requestId'),
        headers: {'Content-Type': 'application/json', 'Cookie': sessionCookie},
        body: jsonEncode({'status': 'Approved'}),
      );

      if (response.statusCode == 200) {
        await fetchRequests();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request approved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to approve: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> rejectRequest(int requestId) async {
    // Show dialog to get rejection reason
    TextEditingController reasonController = TextEditingController();
    bool? shouldProceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Enter rejection reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a rejection reason'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (shouldProceed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('sessionCookie') ?? '';

      final response = await http.patch(
        Uri.parse('$baseUrl/api/borrow/$requestId'),
        headers: {'Content-Type': 'application/json', 'Cookie': sessionCookie},
        body: jsonEncode({
          'status': 'Disapproved',
          'rejection_reason': reasonController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        await fetchRequests();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request rejected successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Failed to reject: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
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

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _navigateTo(context, const LecturerDashboard());
        break;
      case 1:
        // Current page, do nothing
        break;
      case 2:
        _navigateTo(context, const LecturerBrowseAssets());
        break;
      case 3:
        _navigateTo(context, const LecturerHistoryPage());
        break;
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
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
                isActive: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              _buildNavItem(
                icon: Icons.list_alt,
                label: 'Requested',
                isActive: _selectedIndex == 1,
                // --- TAP HANDLER FIXED ---
                onTap: () => _onItemTapped(1),
              ),
              _buildNavItem(
                icon: Icons.search,
                label: 'Browse',
                isActive: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
              _buildNavItem(
                icon: Icons.history,
                label: 'History',
                isActive: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0, // Removed elevation
        title: const Text(
          'Requested Assets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchRequests,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : message.isNotEmpty
          ? Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : requestedAssets.isEmpty
          ? const Center(
              child: Text(
                'No requested assets',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: requestedAssets.length,
              itemBuilder: (context, index) {
                final asset = requestedAssets[index];
                return _buildRequestCard(context, asset);
              },
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Helper method to format date string
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == 'N/A') {
      return 'N/A';
    }

    try {
      // Parse as local time, not UTC
      final date = DateTime.parse(dateString).toLocal();
      final months = [
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
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  Widget _buildDateInfo(String label, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            _formatDate(date),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, RequestedAsset asset) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.studentName, // 'borrowed_by'
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        asset.assetName, // 'asset_name'
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDateInfo(
                        'Borrow',
                        asset.borrowDate,
                      ), // 'borrow_date'
                      // This will now show "Return: N/A" because
                      // app.js is not sending 'return_date'
                      _buildDateInfo('Return', asset.returnDate),
                    ],
                  ),
                ),
                if (asset.status == 'pending')
                  Column(
                    // Use Column for buttons
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () => approveRequest(asset.requestId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: availableColor.withOpacity(0.1),
                          foregroundColor: availableColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Approve',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4), // Space between buttons
                      ElevatedButton(
                        onPressed: () => rejectRequest(asset.requestId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          foregroundColor: Colors.red,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: asset.status == 'approved'
                          ? availableColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      asset.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: asset.status == 'approved'
                            ? availableColor
                            : Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'lecturer_dashboard_tab.dart';
// import 'lecturer_browse_tab.dart';
// import 'lecturer_history_page.dart';

// const Color primaryColor = Color(0xFF0A4D68);
// const Color secondaryColor = Color(0xFF088395);
// const Color cardColor = Color(0xFFFFFFFF);
// const Color cardTextColor = Colors.black;
// const Color bodyTextColor = Colors.white;
// const Color subtitleTextColor = Colors.white70;
// const Color availableColor = Color(0xFF28A745);
// const Color pendingColor = Color(0xFFFFA500);
// const Color buttonColor = Color(0xFF4F709C);

// class RequestedAsset {
//   final int requestId;
//   final String studentName;
//   final String assetName;
//   final String borrowDate;
//   final String returnDate;
//   final String status;

//   RequestedAsset({
//     required this.requestId,
//     required this.studentName,
//     required this.assetName,
//     required this.borrowDate,
//     required this.returnDate,
//     required this.status,
//   });

//   factory RequestedAsset.fromJson(Map<String, dynamic> json) {
//     return RequestedAsset(
//       requestId: json['request_id'] ?? 0,
//       studentName: json['student_name'] ?? 'Unknown Student',
//       assetName: json['asset_name'] ?? 'Unknown Asset',
//       borrowDate: json['borrow_date'] ?? 'N/A',
//       returnDate: json['return_date'] ?? 'N/A',
//       status: (json['status'] ?? 'pending').toString().toLowerCase(),
//     );
//   }
// }

// class LecturerRequestPage extends StatefulWidget {
//   const LecturerRequestPage({super.key});

//   @override
//   State<LecturerRequestPage> createState() => _LecturerRequestPageState();
// }

// class _LecturerRequestPageState extends State<LecturerRequestPage> {
//   final String baseUrl = 'http://192.168.1.121:3000';
//   List<RequestedAsset> requestedAssets = [];
//   bool isLoading = true;
//   String message = '';
//   int _selectedIndex = 2;

//   @override
//   void initState() {
//     super.initState();
//     fetchRequests();
//   }

//   Future<void> fetchRequests() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final sessionCookie = prefs.getString('sessionCookie') ?? '';

//       final response = await http.get(
//         Uri.parse('$baseUrl/api/checkrequest'),
//         headers: {'Cookie': sessionCookie},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> responseData = jsonDecode(response.body);
//         setState(() {
//           requestedAssets = responseData.map((item) {
//             // Map the server response to match your RequestedAsset model
//             return RequestedAsset(
//               requestId: item['id'],
//               studentName: item['borrowed_by'] ?? 'Unknown Student',
//               assetName: item['asset_name'] ?? 'Unknown Asset',
//               borrowDate: item['borrow_date']?.toString() ?? 'N/A',
//               returnDate: '', // This field might not be in the response
//               status: (item['status'] ?? 'pending').toString().toLowerCase(),
//             );
//           }).toList();
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load requests: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         message = 'Error: $e';
//         isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error fetching requests: $e')));
//       }
//     }
//   }

//   Future<void> approveRequest(int requestId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final sessionCookie = prefs.getString('sessionCookie') ?? '';

//       final response = await http.patch(
//         Uri.parse('$baseUrl/api/borrow/$requestId'),
//         headers: {'Content-Type': 'application/json', 'Cookie': sessionCookie},
//         body: jsonEncode({'status': 'Approved'}),
//       );

//       if (response.statusCode == 200) {
//         await fetchRequests();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Request approved successfully')),
//           );
//         }
//       } else {
//         throw Exception('Failed to approve: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     }
//   }

//   Future<void> rejectRequest(int requestId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final sessionCookie = prefs.getString('sessionCookie') ?? '';

//       final response = await http.patch(
//         Uri.parse('$baseUrl/api/borrow/$requestId'),
//         headers: {'Content-Type': 'application/json', 'Cookie': sessionCookie},
//         body: jsonEncode({'status': 'Disapproved'}),
//       );

//       if (response.statusCode == 200) {
//         await fetchRequests();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Request rejected successfully')),
//           );
//         }
//       } else {
//         throw Exception('Failed to reject: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     }
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

//   void _onItemTapped(int index) {
//     if (index == _selectedIndex) return;

//     setState(() {
//       _selectedIndex = index;
//     });

//     switch (index) {
//       case 0:
//         _navigateTo(context, const LecturerDashboard());
//         break;
//       case 1:
//         // Current page, do nothing
//         break;
//       case 2:
//         _navigateTo(context, const LecturerBrowseAssets());
//         break;
//       case 3:
//         _navigateTo(context, const LecturerHistoryPage());
//         break;
//     }
//   }

//   final List<Color> appColors = const [
//     Color(0xFF244F62),
//     Color(0xFF325D71),
//     Color(0xFFD9D9D9),
//     Color(0xFF5689C0),
//     Color.fromARGB(255, 255, 255, 255),
//   ];

//   Widget _buildNavItem({
//     required IconData icon,
//     required String label,
//     required bool isActive,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 24),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: isActive ? Colors.white : Colors.white70,
//               fontSize: 12,
//               fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNav() {
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
//                 isActive: _selectedIndex == 0,
//                 onTap: () => _onItemTapped(0),
//               ),
//               _buildNavItem(
//                 icon: Icons.list_alt,
//                 label: 'Requested',
//                 isActive: _selectedIndex == 1,
//                 onTap: () {},
//               ),
//               _buildNavItem(
//                 icon: Icons.search,
//                 label: 'Browse',
//                 isActive: _selectedIndex == 2,
//                 onTap: () => _onItemTapped(2),
//               ),
//               _buildNavItem(
//                 icon: Icons.history,
//                 label: 'History',
//                 isActive: _selectedIndex == 3,
//                 onTap: () => _onItemTapped(3),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryColor,
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: const Text(
//           'Requested Assets',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: fetchRequests,
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : message.isNotEmpty
//           ? Center(
//               child: Text(
//                 message,
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//             )
//           : requestedAssets.isEmpty
//           ? const Center(
//               child: Text(
//                 'No requested assets',
//                 style: TextStyle(color: Colors.grey, fontSize: 16),
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.only(bottom: 20),
//               itemCount: requestedAssets.length,
//               itemBuilder: (context, index) {
//                 final asset = requestedAssets[index];
//                 return _buildRequestCard(context, asset);
//               },
//             ),
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }

//   // Helper method to format date string
//   String _formatDate(String? dateString) {
//     if (dateString == null || dateString.isEmpty || dateString == 'N/A') {
//       return 'N/A';
//     }

//     try {
//       final date = DateTime.parse(dateString);
//       final months = [
//         'Jan',
//         'Feb',
//         'Mar',
//         'Apr',
//         'May',
//         'Jun',
//         'Jul',
//         'Aug',
//         'Sep',
//         'Oct',
//         'Nov',
//         'Dec',
//       ];
//       return '${date.day} ${months[date.month - 1]} ${date.year}';
//     } catch (e) {
//       return dateString; // Return original if parsing fails
//     }
//   }

//   Widget _buildDateInfo(String label, String date) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2.0),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(
//               fontSize: 13,
//               color: Colors.grey,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Text(
//             _formatDate(date),
//             style: const TextStyle(
//               fontSize: 13,
//               color: Colors.black87,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRequestCard(BuildContext context, RequestedAsset asset) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         asset.studentName,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF2C3E50),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         asset.assetName,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       _buildDateInfo('Borrow Date', asset.borrowDate),
//                       if (asset.returnDate.isNotEmpty &&
//                           asset.returnDate != 'N/A')
//                         _buildDateInfo('Return Date', asset.returnDate),
//                     ],
//                   ),
//                 ),
//                 if (asset.status == 'pending')
//                   Row(
//                     children: [
//                       Container(
//                         margin: const EdgeInsets.only(right: 8),
//                         child: ElevatedButton(
//                           onPressed: () => approveRequest(asset.requestId),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: availableColor.withOpacity(0.1),
//                             foregroundColor: availableColor,
//                             elevation: 0,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 4,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             'Approve',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => rejectRequest(asset.requestId),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red.withOpacity(0.1),
//                           foregroundColor: Colors.red,
//                           elevation: 0,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 4,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'Reject',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 else
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: asset.status == 'approved'
//                           ? availableColor.withOpacity(0.1)
//                           : Colors.grey.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       asset.status.toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: asset.status == 'approved'
//                             ? availableColor
//                             : Colors.grey,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             // Student Name
//             Text(
//               'Student: ${asset.studentName}',
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF333333),
//                 fontWeight: FontWeight.w500,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 6),
//             // Asset Name
//             Text(
//               'Asset: ${asset.assetName}',
//               style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 10),
//             // Dates in a row
//             Row(
//               children: [
//                 Expanded(child: _buildDateInfo('Borrow', asset.borrowDate)),
//                 if (asset.returnDate.isNotEmpty && asset.returnDate != 'N/A')
//                   Expanded(child: _buildDateInfo('Return', asset.returnDate)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
