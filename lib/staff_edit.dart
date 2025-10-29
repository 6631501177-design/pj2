import 'package:flutter/material.dart';
import 'package:pj2/staff_edit_page.dart';

class StaffEdit extends StatefulWidget {
  const StaffEdit({super.key});

  @override
  State<StaffEdit> createState() => _StaffEditState();
}

class _StaffEditState extends State<StaffEdit> {
  int _selectedIndex = 1;
  final List<Map<String, dynamic>> assets = [
    {
      'name': 'MacBook Air',
      'image': 'assets/images/macbook.jpg',
      'status': 'Disable',
    },
    {
      'name': 'Asus ViVobook 15',
      'image': 'assets/images/asus.png',
      'status': 'Disable',
    },
    {
      'name': 'IPad Air',
      'image': 'assets/images/ipad.jpg',
      'status': 'Disable',
    },
    {
      'name': 'Samsung Tab S10+',
      'image': 'assets/images/samsung.jpg',
      'status': 'Enable',
    },
    {
      'name': 'Canon EOS R10',
      'image': 'assets/images/canon.jpg',
      'status': 'Disable',
    },
    {
      'name': 'Wanbo T2R Max',
      'image': 'assets/images/wanbo.jpg',
      'status': 'Disable',
    },
  ];

  Widget _actionButton(
    String label,
    VoidCallback onPressed,
    Color color, {
    double w = 140,
    double h = 38,
  }) {
    return SizedBox(
      width: w,
      height: h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _assetCard(Map item, int index) {
    final bool isEnabled = item['status'] == 'Enable';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            SizedBox(
              height: 80,
              child: Center(
                child: Image.asset(
                  item['image'] as String,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['name'] as String,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF244F62),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                _actionButton('Edit', () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StaffEditPage(item: Map<String, dynamic>.from(item)),
                    ),
                  );
                  if (result != null) setState(() => assets[index] = result);
                }, const Color(0xFF6E9FD0)),
                const SizedBox(height: 10),
                _actionButton(
                  item['status'] as String,
                  () => setState(
                    () => item['status'] = isEnabled ? 'Disable' : 'Enable',
                  ),
                  isEnabled ? const Color(0xFFAED6F1) : const Color(0xFF6E9FD0),
                ),
              ],
            ),
          ],
        ),
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
      Color.fromARGB(255, 255, 255, 255),
    ];
    return Scaffold(
      backgroundColor: appColors[0],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: appColors[2]),
                        ),
                        child: const TextField(
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search any assets',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.blueGrey,
                              size: 18,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: appColors[2],
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        minimumSize: Size(80, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: const Text(
                        'Add Assets',
                        style: TextStyle(
                          color: Color(0xFF244F62),
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: assets.length,
                    itemBuilder: (c, i) => _assetCard(assets[i], i),
                  ),
                ),
              ],
            ),
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
