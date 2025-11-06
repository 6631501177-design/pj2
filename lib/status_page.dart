import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StatusPage extends StatefulWidget {
  final int studentId; // กำหนด studentId ของนักเรียน
  const StatusPage({super.key, required this.studentId});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List<dynamic> borrowList = [];
  bool isLoading = true;

  Future<void> fetchStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.1:3000/borrow/student/${widget.studentId}'), 
      );

      if (response.statusCode == 200) {
        setState(() {
          borrowList = json.decode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 500) {
        print('Server error');
        setState(() => isLoading = false);
      } else {
        print('Unknown error: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Error fetching data: $e');
      setState(() => isLoading = false);
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
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : borrowList.isEmpty
              ? const Center(child: Text('No data available'))
              : ListView.builder(
                  itemCount: borrowList.length,
                  itemBuilder: (context, index) {
                    final item = borrowList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 3,
                      child: ListTile(
                        title: Text(item['asset_name'] ?? 'Unknown Asset'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.containsKey('borrow_date'))
                              Text('Borrow Date: ${item['borrow_date']}'),
                            if (item.containsKey('return_date'))
                              Text('Return Date: ${item['return_date']}'),
                            Text('Status: ${item['status'] ?? '-'}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

