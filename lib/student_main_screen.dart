import 'package:flutter/material.dart';
import 'package:pj2/student_assets_tab.dart';
import 'package:pj2/student_requests_tab.dart';
import 'package:pj2/student_history_tab.dart';

// --- Shared Colors ---
const Color primaryColor = Color(0xFF0A4D68);
const Color secondaryColor = Color(0xFF088395); // For accent/selected tab
const Color cardColor = Color(0xFFFFFFFF); // White cards from your design
const Color cardTextColor = Colors.black;
const Color bodyTextColor = Colors.white;
const Color subtitleTextColor = Colors.white70;
const Color availableColor = Color(0xFF28A745); // Green for "Available"
const Color pendingColor = Color(0xFFFFA500); // Orange for "Pending"
const Color buttonColor = Color(0xFF4F709C); // Action button blue
// --- End Shared Colors ---

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _selectedIndex = 0; // Index for the selected tab

  // List of tabs
  static const List<Widget> _widgetOptions = <Widget>[
    StudentAssetsTab(),
    StudentRequestsTab(),
    StudentHistoryTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: _widgetOptions.elementAt(
          _selectedIndex,
        ), // Display the selected tab
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.devices_other),
            label: 'Assets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Requests',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: secondaryColor, // Color for the selected icon/label
        unselectedItemColor: Colors.grey[400],
        onTap: _onItemTapped,
        backgroundColor: Colors.white, // White background for nav bar
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
      ),
    );
  }
}
