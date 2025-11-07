import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List<dynamic> borrowList = [];
  bool isLoading = true;
  String errorMessage = '';

  Color _getStatusColor(dynamic status) {
    try {
      final statusStr = status?.toString().toLowerCase() ?? 'pending';
      switch (statusStr) {
        case 'approved':
          return Colors.green;
        case 'rejected':
          return Colors.red;
        case 'returned':
          return Colors.blue;
        case 'pending':
        default:
          return Colors.orange;
      }
    } catch (e) {
      return Colors.orange; // Default color if any error occurs
    }
  }

  Future<void> _refreshData() async {
    await fetchStatus();
  }

  Future<void> fetchStatus() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      // Get the session cookie from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('sessionCookie') ?? '';

      print('Fetching borrow data...');
      final response = await http.get(
        // Uri.parse('http://192.168.1.121:3000/api/borrow-requests/check'),
        Uri.parse('http://172.27.14.220:3000/api/borrow-requests/check'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cookie': sessionCookie,
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Parsed data: $data');

        if (mounted) {
          setState(() {
            borrowList = List<dynamic>.from(data['requests'] ?? []);
            isLoading = false;
            errorMessage = '';
          });
        }
      } else {
        final errorMsg =
            'Failed to load data. Status code: ${response.statusCode}';
        print(errorMsg);
        if (mounted) {
          setState(() {
            errorMessage = errorMsg;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      final errorMsg = 'Error fetching data: $e';
      print(errorMsg);
      if (mounted) {
        setState(() {
          errorMessage = errorMsg;
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing Status'),
        backgroundColor: const Color(0xFF0A4D68),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : borrowList.isEmpty
            ? const Center(child: Text('No borrowing records found'))
            : ListView.builder(
                itemCount: borrowList.length,
                itemBuilder: (context, index) {
                  final item = borrowList[index];
                  final borrowDate = item['borrow_date'] != null
                      ? DateTime.parse(item['borrow_date'])
                      : null;
                  final returnDate = item['return_date'] != null
                      ? DateTime.parse(item['return_date'])
                      : null;
                  final status = (item['status'] ?? 'pending')
                      .toString()
                      .toLowerCase();

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Asset Name and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'] ??
                                      item['asset_name'] ??
                                      'Unknown Asset',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    status,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Asset ID
                          if (item['asset_id'] != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                'Asset ID: ${item['id'] ?? item['asset_id']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),

                          // Dates
                          if (borrowDate != null || returnDate != null) ...[
                            const Divider(height: 20, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Borrow Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(borrowDate!),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Return Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(returnDate!),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
