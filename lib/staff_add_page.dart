import 'package:flutter/material.dart';
import 'package:pj2/staff_history.dart';

class StaffAddPage extends StatefulWidget {
  const StaffAddPage({super.key});

  @override
  State<StaffAddPage> createState() => _StaffAddPageState();
}

class _StaffAddPageState extends State<StaffAddPage> {
  final TextEditingController _nameController = TextEditingController();

  final int _selectedIndex = 1;
  final List<Color> appColors = const [
    Color(0xFF244F62),
    Color(0xFF325D71),
    Color(0xFFD9D9D9),
    Color(0xFF5689C0),
    Color.fromARGB(255, 255, 255, 255),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors[0],
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add Asset",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Asset Name",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 6),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Type in Asset Name",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4B9CD3)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF275666),
                  elevation: 4,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  "Attach Photo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                  final assetName = _nameController.text.trim();
                  if (assetName.isNotEmpty) {
                    Navigator.pop(context, {'name': assetName});
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Container(
                  width: 150,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6CA3DB), Color(0xFF4B9CD3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16),
        child: Align(
          alignment: Alignment.topLeft,
          child: FloatingActionButton.small(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,

      bottomNavigationBar: SafeArea(
        top: false,
        left: false,
        right: false,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Container(
            color: appColors[1],
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: appColors[1],
                indicatorColor: appColors[0],
                labelTextStyle: const MaterialStatePropertyAll(
                  TextStyle(color: Colors.white),
                ),
                iconTheme: const MaterialStatePropertyAll(
                  IconThemeData(color: Colors.white),
                ),
              ),
              child: NavigationBar(
                backgroundColor: appColors[1],
                indicatorColor: Colors.transparent,
                height: 70,
                elevation: 0,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  if (index == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StaffHistoryPage()),
                    );
                  }
                },
                destinations: [
                  for (int i = 0; i < 4; i++)
                    NavigationDestination(
                      icon: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedIndex == i
                                ? appColors[0]
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 12,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                [
                                  Icons.home,
                                  Icons.edit,
                                  Icons.loop,
                                  Icons.history,
                                ][i],
                                color: Colors.white,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  'Home',
                                  'Edit Asset',
                                  'Process',
                                  'History',
                                ][i],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      label: '',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
