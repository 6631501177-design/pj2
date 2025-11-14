import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF0A4D68);
const Color secondaryColor = Color(0xFF088395);
const Color cardColor = Color(0xFFFFFFFF);
const Color cardTextColor = Colors.black;
const Color bodyTextColor = Colors.white;
const Color subtitleTextColor = Colors.white70;
const Color availableColor = Color(0xFF28A745);
const Color pendingColor = Color(0xFFFFA500);
const Color buttonColor = Color(0xFF4F709C);

class AssetDetailsPage extends StatefulWidget {
  final String assetName;
  final String imagePath;
  final String status;
  final int assetId;
  final VoidCallback? onRequestAdded;

  const AssetDetailsPage({
    super.key,
    required this.assetName,
    required this.imagePath,
    required this.status,
    required this.assetId,
    this.onRequestAdded,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'available':
        return availableColor;
      case 'borrowed':
        return Colors.red;
      case 'pending':
        return pendingColor;
      case 'disabled':
      default:
        return Colors.grey;
    }
  }

  @override
  State<AssetDetailsPage> createState() => _AssetDetailsPageState();
}

class _AssetDetailsPageState extends State<AssetDetailsPage> {
  late DateTime _borrowDate;
  late DateTime _returnDate;

  // Helper method to get today's date at local midnight
  DateTime _getTodayAtMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    _borrowDate = _getTodayAtMidnight();
    _returnDate = _borrowDate.add(const Duration(days: 1));
  }

  Future<void> _selectBorrowDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _borrowDate,
      firstDate: _getTodayAtMidnight(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        // Ensure we're storing just the date part without time
        _borrowDate = DateTime(picked.year, picked.month, picked.day);
        if (_returnDate.isBefore(_borrowDate.add(const Duration(days: 1)))) {
          _returnDate = DateTime(
            _borrowDate.year,
            _borrowDate.month,
            _borrowDate.day + 1,
          );
        }
      });
    }
  }

  Future<void> _selectReturnDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _returnDate,
      firstDate: _borrowDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        // Ensure we're storing just the date part without time
        _returnDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _submitBorrowRequest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('sessionCookie') ?? '';

      final response = await http.post(
        // Uri.parse('http://192.168.1.121:3000/api/borrow'),
        Uri.parse('http://172.27.22.205:3000/api/borrow'),
        headers: {'Content-Type': 'application/json', 'Cookie': sessionCookie},
        body: jsonEncode({
          'asset_id': widget.assetId,
          // Convert to UTC for the API
          'borrow_date': _borrowDate.toUtc().toIso8601String(),
          'return_date': _returnDate.toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          await _showSuccessDialog();
        }
      } else {
        if (mounted) {
          // Check if the error is about borrowing limit
          if (response.body.contains('already borrowed') ||
              response.body.contains('limit reached')) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Borrowing Limit Reached'),
                    ],
                  ),
                  content: const Text(
                    'You can only borrow one asset per day.',
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            // Show generic error for other cases
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to submit request: ${response.body}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    // Show success dialog
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 100),
                const SizedBox(height: 20),
                const Text(
                  'Request Submitted',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your request has been submitted successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.of(context).pop();

                      // The StatusPage will automatically refresh its data when navigated to
                      // No need to manually update it here as it fetches fresh data from the server

                      // Close the asset details page
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }

                      // Notify parent to switch to requests tab if callback is provided
                      if (widget.onRequestAdded != null) {
                        widget.onRequestAdded!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: const BackButton(color: bodyTextColor),
        title: Text(
          widget.assetName,
          style: const TextStyle(
            color: bodyTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLargeScreen
          ? _buildLargeScreenLayout(screenSize)
          : _buildSmallScreenLayout(),
    );
  }

  Widget _buildLargeScreenLayout(Size screenSize) {
    return Center(
      child: Container(
        width: screenSize.width * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Flexible(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.imagePath.startsWith('http')
                      ? Image.network(
                          widget.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                        )
                      : Image.asset(
                          widget.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Details Section
            Flexible(flex: 1, child: _buildDetailsSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallScreenLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Image Section
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.imagePath.startsWith('http')
                  ? Image.network(
                      widget.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                    )
                  : Image.asset(
                      widget.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          // Details Section
          _buildDetailsSection(),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget._getStatusColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.status.toUpperCase(),
                style: TextStyle(
                  color: widget._getStatusColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Asset Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.assetName,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text(
              'Borrow Period (1 day)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            // Borrow Date Picker
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.black),
              title: const Text('Borrow Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_borrowDate)),
              onTap: _selectBorrowDate,
              tileColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            // Return Date Picker
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.black),
              title: const Text('Return Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_returnDate)),
              onTap: _selectReturnDate,
              tileColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            // Request Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBorrowRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Request to Borrow',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
