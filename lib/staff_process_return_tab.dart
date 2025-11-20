import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pj2/staff_theme.dart';

// UPDATE THIS IP TO MATCH YOUR SERVER
const String _baseUrl = 'http://192.168.1.121:3000';

class StaffProcessReturnTab extends StatefulWidget {
  const StaffProcessReturnTab({Key? key}) : super(key: key);

  @override
  State<StaffProcessReturnTab> createState() => _StaffProcessReturnTabState();
}

class _StaffProcessReturnTabState extends State<StaffProcessReturnTab> {
  List<dynamic> _returnItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReturnItems();
  }

  Future<void> _fetchReturnItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cookie = prefs.getString('sessionCookie');

      if (cookie == null) throw Exception('Not logged in');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/return'),
        headers: {'Cookie': cookie},
      );

      if (response.statusCode == 200) {
        setState(() {
          _returnItems = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _processReturn(int borrowId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cookie = prefs.getString('sessionCookie');

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/process-return/$borrowId'),
        headers: {'Cookie': cookie ?? '', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _fetchReturnItems(); // Refresh list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Return processed successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: staffPrimaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Process Return',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchReturnItems,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _errorMessage != null
                ? Center(
                    child: Text(
                      'Error: $_errorMessage',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : _returnItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items pending return',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _returnItems.length,
                    itemBuilder: (context, index) {
                      return _buildReturnCard(_returnItems[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnCard(Map<String, dynamic> item) {
    // Data mapping from app.js /api/return
    final assetName = item['asset_name'] ?? 'N/A';
    final borrowerName = item['borrower_name'] ?? 'N/A';
    final approvedBy = item['approved_by'] ?? 'N/A';
    final borrowDate = item['borrow_date'] ?? 'N/A';
    final returnDate = item['return_date'] ?? 'N/A'; // This is the Due Date

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.assignment_return,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    assetName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Borrowed by:', borrowerName),
            _buildDetailRow('Borrowed date:', borrowDate),
            _buildDetailRow('Due date:', returnDate),
            _buildDetailRow('Approved by:', approvedBy),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showConfirmDialog(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: staffButtonBlue,
                ),
                child: const Text(
                  'Process Return',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          Text(
            value?.toString() ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Return'),
        content: Text('Mark ${item['asset_name']} as returned?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processReturn(item['borrow_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: staffButtonBlue),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
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
// import 'package:pj2/staff_theme.dart';

// class StaffProcessReturnTab extends StatefulWidget {
//   const StaffProcessReturnTab({Key? key}) : super(key: key);

//   @override
//   State<StaffProcessReturnTab> createState() => _StaffProcessReturnTabState();
// }

// class _StaffProcessReturnTabState extends State<StaffProcessReturnTab> {
//   // Use the IP that matches your setup
//   final String _baseUrl = 'http://192.168.1.121:3000';

//   List<dynamic> _returnItems = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchReturnItems();
//   }

//   // 1. Fetch items that need to be returned
//   Future<void> _fetchReturnItems() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? cookie = prefs.getString('sessionCookie');

//       if (cookie == null) {
//         throw Exception('Not logged in');
//       }

//       final response = await http.get(
//         Uri.parse('$_baseUrl/api/return'),
//         headers: {'Cookie': cookie},
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _returnItems = jsonDecode(response.body);
//           _isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load return items: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   // 2. Process the return (Call the PATCH API)
//   Future<void> _processReturn(int borrowId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? cookie = prefs.getString('sessionCookie');

//       final response = await http.patch(
//         Uri.parse('$_baseUrl/api/process-return/$borrowId'),
//         headers: {'Cookie': cookie ?? '', 'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         // Close dialog if open (handled in _showSuccessDialog)
//         // Refresh list
//         _fetchReturnItems();
//       } else {
//         // Handle error
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error processing return: ${response.body}'),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Connection error: $e')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: staffPrimaryColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         title: const Text(
//           'Process Return',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: _fetchReturnItems,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: Colors.white),
//                   )
//                 : _errorMessage != null
//                 ? Center(
//                     child: Text(
//                       'Error: $_errorMessage',
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   )
//                 : _returnItems.isEmpty
//                 ? const Center(
//                     child: Text(
//                       'No items pending return',
//                       style: TextStyle(color: Colors.white70, fontSize: 16),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: _returnItems.length,
//                     itemBuilder: (context, index) {
//                       final item = _returnItems[index];
//                       return _buildReturnItemCard(context, item);
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReturnItemCard(BuildContext context, Map<String, dynamic> item) {
//     // app.js does not return an image path in /api/return, so we set a default empty string
//     // triggering the errorBuilder placeholder.
//     String imagePath = '';

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.asset(
//                     imagePath,
//                     width: 60,
//                     height: 60,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) => Container(
//                       width: 60,
//                       height: 60,
//                       color: Colors.grey[200],
//                       child: const Icon(
//                         Icons.image_not_supported,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Text(
//                     item['asset_name'] ?? 'N/A',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2C3E50),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             _buildDetailRow(
//               'Borrowed by:',
//               item['borrower_name']?.toString() ?? 'N/A',
//             ),
//             const SizedBox(height: 8),
//             _buildDetailRow(
//               'Borrowed date:',
//               item['borrow_date']?.toString() ?? 'N/A',
//             ),
//             const SizedBox(height: 8),
//             _buildDetailRow(
//               'Due date:', // Changed from 'Returned date' since it hasn't been returned yet
//               item['return_date']?.toString() ?? 'N/A',
//             ),
//             const SizedBox(height: 8),
//             _buildDetailRow(
//               'Approved by:',
//               item['approved_by']?.toString() ?? 'N/A',
//             ),

//             // Staff row removed because this item is not yet processed by staff
//             const SizedBox(height: 16),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => _showSuccessDialog(context, item),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: staffButtonBlue,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   'Process Return',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 14),
//           ),
//           const SizedBox(width: 4),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 color: Color(0xFF2C3E50),
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSuccessDialog(BuildContext context, Map<String, dynamic> item) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           backgroundColor: Colors.white,
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 10),
//               const Icon(Icons.check_circle, color: Colors.green, size: 80),
//               const SizedBox(height: 20),
//               const Text(
//                 'Confirm Return',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'Mark ${item['asset_name']} as returned?',
//                 style: const TextStyle(fontSize: 16, color: Colors.black54),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Close dialog
//                     _processReturn(item['borrow_id']); // Call API
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: staffButtonBlue,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text('Confirm'),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
