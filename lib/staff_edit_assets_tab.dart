import 'package:flutter/material.dart';
import 'package:pj2/staff_add_asset_page.dart';
import 'package:pj2/staff_theme.dart';

class StaffEditAssetPage extends StatelessWidget {
  final String assetName;
  final String imagePath;

  const StaffEditAssetPage({
    Key? key,
    required this.assetName,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: staffPrimaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Edit Asset', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Asset',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: TextEditingController(text: assetName),
                decoration: const InputDecoration(
                  labelText: 'Asset Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.attach_file, color: staffButtonBlue),
                label: const Text(
                  'Change Photo',
                  style: TextStyle(color: staffButtonBlue),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: staffButtonBlue),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: staffButtonBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StaffEditAssetsTab extends StatelessWidget {
  const StaffEditAssetsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assets = [
      {'name': 'MacBook Air', 'image': 'assets/images/macbook.jpg'},
      {'name': 'Asus VivoBook 15', 'image': 'assets/images/AsusVivo14.jpg'},
      {'name': 'iPad Air', 'image': 'assets/images/IPad.jpg'},
      {'name': 'Samsung Tab S10+', 'image': 'assets/images/samsungs10.jpg'},
      {'name': 'Canon EOS R10', 'image': 'assets/images/canon.jpg'},
      {'name': 'Wanbo T2R Max', 'image': 'assets/images/wanbo.jpg'},
      {'name': 'Projector', 'image': 'assets/images/projector.jpg'},
    ];

    return Scaffold(
      backgroundColor: staffPrimaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Edit Assets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search any assets',
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: staffSecondaryColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StaffAddAssetPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: staffButtonBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Add Assets'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Assets Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7, // Adjusted for buttons
                ),
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  return _buildAssetCard(
                    context,
                    assets[index]['name']!,
                    assets[index]['image']!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetCard(BuildContext context, String name, String imagePath) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              imagePath,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 60),
            ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StaffEditAssetPage(
                            assetName: name,
                            imagePath: imagePath,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: staffButtonBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Disable Asset'),
                          content: Text(
                            'Are you sure you want to disable $name?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Disable'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Disable'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
