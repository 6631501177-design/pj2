import 'package:flutter/material.dart';

void main() {
  runApp(const AssetManagementApp());
}

class AssetManagementApp extends StatelessWidget {
  const AssetManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asset Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF3D6B7D),
      ),
      home: const LecturerBrowseAssets(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LecturerBrowseAssets extends StatefulWidget {
  const LecturerBrowseAssets({Key? key}) : super(key: key);

  @override
  State<LecturerBrowseAssets> createState() => _LecturerBrowseAssetsState();
}

class _LecturerBrowseAssetsState extends State<LecturerBrowseAssets> {
  int _selectedTab = 1; // 0 = Requested Assets, 1 = Browse Assets

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3D6B7D),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Tabs
            _buildTopBar(),
            
            // Search Bar
            _buildSearchBar(),
            
            // Assets Grid
            Expanded(
              child: _buildAssetsGrid(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Top Bar with Tab Buttons
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF3D6B7D),
      child: Row(
        children: [
          _buildTabButton('Requested Assets', 0),
          const SizedBox(width: 8),
          _buildTabButton('Browse Assets', 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search any assets',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[600],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // Assets Grid
  Widget _buildAssetsGrid() {
    final assets = [
      {
        'name': 'MacBook Air',
        'image': '💻',
        'status': 'Available',
        'statusColor': const Color(0xFF4CAF50),
      },
      {
        'name': 'Asus ViVobook 15',
        'image':' assets/images/AsusVivo14.jpg',
        'status': 'Available',
        'statusColor': const Color(0xFF4CAF50),
      },
      {
        'name': 'iPad Air',
        'image': ' assets/images/.jpg',
        'status': 'Available',
        'statusColor': const Color(0xFF4CAF50),
      },
      {
        'name': 'Samsung Tab S10+',
        'image': '📱',
        'status': 'Available',
        'statusColor': const Color(0xFF4CAF50),
      },
      {
        'name': 'Canon EOS R10',
        'image': '📷',
        'status': 'Borrowed',
        'statusColor': const Color(0xFFF44336),
      },
      {
        'name': 'Wanbo T2R Max',
        'image': '📽️',
        'status': 'Available',
        'statusColor': const Color(0xFF4CAF50),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          return _buildAssetCard(
            name: assets[index]['name'] as String,
            image: assets[index]['image'] as String,
            status: assets[index]['status'] as String,
            statusColor: assets[index]['statusColor'] as Color,
          );
        },
      ),
    );
  }

  // Individual Asset Card
  Widget _buildAssetCard({
    required String name,
    required String image,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Asset Image/Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                image,
                style: const TextStyle(fontSize: 50),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Asset Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C5464),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: false,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.search,
                label: 'Assets',
                isActive: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.history,
                label: 'History',
                isActive: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation Item
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
