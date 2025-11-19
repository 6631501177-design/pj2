import 'package:flutter/material.dart';

class StaffAssetPage extends StatefulWidget {
  const StaffAssetPage({super.key});

  @override
  State<StaffAssetPage> createState() => _StaffAssetPageState();
}

class _StaffAssetPageState extends State<StaffAssetPage> {
  int _selectedIndex = 1; 

  List<Map<String, dynamic>> assets = [
    {
      'id': 1,
      'asset_name': 'Laptop HP',
      'status': 'Available',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'id': 2,
      'asset_name': 'Projector Epson',
      'status': 'Borrowed',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'id': 3,
      'asset_name': 'Tablet Samsung',
      'status': 'Pending',
      'image': 'https://via.placeholder.com/150',
    },
  ];

  void updateStatus(int id, String newStatus) {
    setState(() {
      final index = assets.indexWhere((asset) => asset['id'] == id);
      if (index != -1) {
        assets[index]['status'] = newStatus;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF244F62),
      appBar: AppBar(
        title: const Text('Staff Edit Asset',
        style: TextStyle(
        color: Colors.white, 
        fontWeight: FontWeight.bold, 
      ),
    ),
    backgroundColor: const Color(0xFF173B4E),
    centerTitle: true,
  ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.network(
                        asset['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(asset['asset_name']),
                      subtitle: Text('Status: ${asset['status']}'),
                      trailing: DropdownButton<String>(
                        value: asset['status'],
                        items: <String>[
                          'Available',
                          'Borrowed',
                          'Pending',
                          'Disable'
                        ]
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            updateStatus(asset['id'], value);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF325D71),
          indicatorColor: const Color(0xFF244F62),
          labelTextStyle:
              WidgetStateProperty.all(const TextStyle(color: Colors.white)),
          iconTheme:
              WidgetStateProperty.all(const IconThemeData(color: Colors.white)),
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_note), 
              label: 'Edit Assets',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StaffAssetPage(),
  ));
}
