import 'package:flutter/material.dart';
import 'package:pj2/staff_edit.dart';

class StaffHistoryPage extends StatefulWidget {
  const StaffHistoryPage({super.key});

  @override
  State<StaffHistoryPage> createState() => _StaffHistoryPageState();
}

class _StaffHistoryPageState extends State<StaffHistoryPage> {
  int _selectedIndex = 3;

  final List<Map<String, dynamic>> assets = [
    {
      'name': 'iPad Air',
      'image': 'assets/images/ipad.jpg',
      'borrowedDate': '10/10/2025',
      'returnedDate': '12/10/2025',
      'borrowedBy': 'Maprang',
      'approvedBy': 'Pakkad',
      'staff': 'Robin',
    },
    {
      'name': 'Asus Vivobook 15',
      'image': 'assets/images/asus.png',
      'borrowedDate': '08/10/2025',
      'returnedDate': '10/10/2025',
      'borrowedBy': 'Maprang',
      'approvedBy': 'Pakkad',
      'staff': 'Robin',
    },
    {
      'name': 'Canon EOS 10',
      'image': 'assets/images/canon.jpg',
      'borrowedDate': '05/10/2025',
      'returnedDate': '08/10/2025',
      'borrowedBy': 'Maprang',
      'approvedBy': 'Pakkad',
      'staff': 'Robin',
    },
  ];

  Widget _buildCard(Map asset) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // ✅ เริ่มจากจุด start
          mainAxisSize: MainAxisSize.min,
          children: [
            // รูปภาพ
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  asset['image'],
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported,
                          size: 48, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // ชื่อ
            Center(
              child: Text(
                asset['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF244F62),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // ✅ เส้นขั้นระหว่างชื่อกับข้อมูล
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFE0E0E0),
              ),
            ),

            // ข้อมูลรายละเอียด
            Expanded(
              child: SingleChildScrollView( // ✅ ป้องกัน overflow
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.calendar_today, 'Borrowed',
                        asset['borrowedDate']),
                    _buildDetailRow(Icons.assignment_turned_in, 'Returned',
                        asset['returnedDate']),
                    _buildDetailRow(
                        Icons.person, 'Borrowed by', asset['borrowedBy']),
                    _buildDetailRow(
                        Icons.verified_user, 'Approved by', asset['approvedBy']),
                    _buildDetailRow(Icons.badge, 'Staff', asset['staff']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF244F62)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> appColors = const [
      Color(0xFF244F62),
      Color(0xFF325D71),
      Color(0xFFD9D9D9),
      Color(0xFF5689C0),
      Colors.white,
    ];

    return Scaffold(
      backgroundColor: appColors[0],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // ✅ title ชิดซ้าย
            children: [
              const Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 0.78, // ✅ ปรับให้ไม่ overflow
                  ),
                  itemCount: assets.length,
                  itemBuilder: (_, i) => _buildCard(assets[i]),
                ),
              ),
            ],
          ),
        ),
      ),
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
                labelTextStyle: MaterialStatePropertyAll(
                  const TextStyle(color: Colors.white),
                ),
                iconTheme: MaterialStatePropertyAll(
                  const IconThemeData(color: Colors.white),
                ),
              ),
              child: NavigationBar(
                backgroundColor: appColors[1],
                indicatorColor: Colors.transparent,
                height: 70,
                elevation: 0,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StaffEdit()),
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
                                  'Edit Assets',
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
