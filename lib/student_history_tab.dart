import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Colors
const Color bodyTextColor = Colors.white;
const Color subtitleTextColor = Colors.white70;
const Color cardColor = Color(0xFFFFFFFF);

// const String _apiUrl =
//     '192.168.1.121:3000'; // Update this with your actual API URL
const String _apiUrl = '172.27.14.220:3000';

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

        // If no data from API, return sample data for testing
        if (data.isEmpty) {
          return [
            {
              'asset_name': 'Samsung S10+',
              'borrow_date': '2025-10-02',
              'return_date': '2025-10-03',
            },
            {
              'asset_name': 'iPad',
              'borrow_date': '2025-09-16',
              'return_date': '2025-09-17',
            },
            {
              'asset_name': 'MacBook',
              'borrow_date': '2025-08-28',
              'return_date': '2025-08-29',
            },
          ];
        }

        return data;
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      // If there's any error, return sample data for testing
      return [
        {
          'asset_name': 'Samsung S10+',
          'borrow_date': '2025-10-02',
          'return_date': '2025-10-03',
        },
        {
          'asset_name': 'iPad',
          'borrow_date': '2025-09-16',
          'return_date': '2025-09-17',
        },
        {
          'asset_name': 'MacBook',
          'borrow_date': '2025-08-28',
          'return_date': '2025-08-29',
        },
      ];
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
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
    return SingleChildScrollView(
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
                    item['borrow_date'] ?? 'N/A',
                    item['return_date'] ?? 'N/A',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    String assetName,
    String borrowDate,
    String returnDate,
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
                // const Icon(
                //   Icons.inventory_2_outlined,
                //   size: 24,
                //   color: Colors.blueGrey,
                // ),
                const SizedBox(width: 8),
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
                _buildStatusChip(),
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
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.verified_user_outlined,
              'Approved by: Martin',
              size: 12,
            ),
            _buildInfoRow(Icons.person_outline, 'Processed by: John', size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {double size = 14}) {
    return Row(
      children: [
        Icon(icon, size: size, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: size, color: Colors.grey[800]),
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Returned',
        style: TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
