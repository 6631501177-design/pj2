import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LecturerRequestPage extends StatefulWidget {
  const LecturerRequestPage({super.key});

  @override
  State<LecturerRequestPage> createState() => _LecturerRequestPageState();
}

class _LecturerRequestPageState extends State<LecturerRequestPage> {
  final String baseUrl = 'http://192.168.1.169:3000'; 
  List<dynamic> requests = [];
  String message = '';

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  // ดึงคำขอจาก API
  Future<void> fetchRequests() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/request'));
      if (response.statusCode == 200) {
        setState(() {
          requests = jsonDecode(response.body);
          message = '';
        });
      } else {
        setState(() {
          message = 'Failed to load requests (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error: $e';
      });
    }
  }

  // Approve
  Future<void> approveRequest(int requestId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/request/approve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'request_id': requestId}),
      );
      if (response.statusCode == 200) {
        fetchRequests();
        setState(() => message = 'Approved request $requestId');
      } else {
        setState(() => message = 'Failed to approve (${response.statusCode})');
      }
    } catch (e) {
      setState(() => message = 'Error: $e');
    }
  }

  // Reject
  Future<void> rejectRequest(int requestId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/request/reject'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'request_id': requestId}),
      );
      if (response.statusCode == 200) {
        fetchRequests();
        setState(() => message = 'Rejected request $requestId');
      } else {
        setState(() => message = 'Failed to reject (${response.statusCode})');
      }
    } catch (e) {
      setState(() => message = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF244F62),
      appBar: AppBar(
        title: const Text('Lecturer Request Manager'),
        backgroundColor: const Color(0xFF173B4E),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: fetchRequests,
              child: const Text('Refresh Requests'),
            ),
            const SizedBox(height: 10),
            if (message.isNotEmpty)
              Text(message, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(req['asset_name'] ?? 'Unknown Asset'),
                      subtitle: Text('Student: ${req['student_name']}\nStatus: ${req['status']}'),
                      trailing: req['status'] == 'pending'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => approveRequest(req['request_id']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => rejectRequest(req['request_id']),
                                ),
                              ],
                            )
                          : Text(req['status'], style: const TextStyle(color: Colors.grey)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
