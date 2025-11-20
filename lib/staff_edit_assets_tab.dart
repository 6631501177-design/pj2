import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pj2/staff_add_asset_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pj2/staff_theme.dart';

// UPDATE IP to match server
const String _baseUrl = 'http://192.168.1.121:3000';

class StaffEditAssetsTab extends StatefulWidget {
  const StaffEditAssetsTab({Key? key}) : super(key: key);

  @override
  State<StaffEditAssetsTab> createState() => _StaffEditAssetsTabState();
}

class _StaffEditAssetsTabState extends State<StaffEditAssetsTab> {
  List<dynamic> _assets = [];
  bool _isLoading = true;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchAssets() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/asset'));
      if (response.statusCode == 200) {
        setState(() {
          _assets = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error fetching assets: $e");
    }
  }

  Future<void> _toggleStatus(int id, String currentStatus) async {
    final newStatus = (currentStatus == 'Disable') ? 'Available' : 'Disable';
    final action = (currentStatus == 'Disable') ? 'enable' : 'disable';

    // Show confirmation dialog
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm $action asset'),
            content: Text('Are you sure you want to $action this asset?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                child: Text('Yes, $action'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return; // User cancelled

    try {
      final prefs = await SharedPreferences.getInstance();
      final cookie = prefs.getString('sessionCookie');

      setState(() => _isLoading = true);
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/assets/$id/status'),
        headers: {'Cookie': cookie ?? '', 'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        await _fetchAssets();
        if (mounted) {
          // Show success dialog
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              content: Text(
                'Asset ${newStatus.toLowerCase()}d successfully',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: staffButtonBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('OK', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.only(
                top: 20,
                bottom: 16,
                left: 24,
                right: 24,
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      print("Error toggling status: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAsset(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookie = prefs.getString('sessionCookie');

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/assets/$id'),
        headers: {'Cookie': cookie ?? ''},
      );

      if (response.statusCode == 200) {
        _fetchAssets();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Asset deleted')));
        }
      }
    } catch (e) {
      print("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchAssets,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search assets...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StaffAddAssetPage(),
                      ),
                    );
                    if (result == true) _fetchAssets();
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
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.60, // Adjusted for buttons
                        ),
                    itemCount: _assets.length,
                    itemBuilder: (context, index) {
                      return _buildAssetCard(_assets[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    String imagePath = asset['image']?.toString() ?? '';
    imagePath = imagePath.replaceAll(RegExp(r'^[\\/]+'), '');
    final fullImageUrl = '$_baseUrl/$imagePath';
    final bool isDisabled = asset['status'] == 'Disable';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imagePath.isNotEmpty
                    ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              asset['asset_name'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              asset['status'] ?? '',
              style: TextStyle(
                color: asset['status']?.toLowerCase() == 'available'
                    ? Colors.green
                    : asset['status']?.toLowerCase() == 'borrowed'
                    ? Colors.orange
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // Navigate to the Edit Form (Defined below in Class 2)
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StaffEditAssetPage(asset: asset),
                            ),
                          );
                          if (result == true) _fetchAssets();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: staffButtonBlue),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            color: staffButtonBlue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _deleteConfirm(asset['id'], asset['asset_name']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        _toggleStatus(asset['id'], asset['status']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDisabled
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      foregroundColor: isDisabled ? Colors.green : Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    child: Text(
                      isDisabled ? 'Enable' : 'Disable',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteConfirm(int id, String? name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Asset'),
        content: Text('Permanently delete ${name ?? 'this asset'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAsset(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class StaffEditAssetPage extends StatefulWidget {
  final Map<String, dynamic> asset;
  const StaffEditAssetPage({Key? key, required this.asset}) : super(key: key);

  @override
  State<StaffEditAssetPage> createState() => _StaffEditAssetPageState();
}

class _StaffEditAssetPageState extends State<StaffEditAssetPage> {
  late TextEditingController _nameController;
  File? _newImage;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset['asset_name']);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _newImage = File(image.path));
  }

  Future<void> _updateAsset() async {
    setState(() => _isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookie = prefs.getString('sessionCookie');
      final assetId = widget.asset['id'];

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$_baseUrl/staff/edit/$assetId'),
      );
      request.headers['Cookie'] = cookie ?? '';
      request.fields['asset_name'] = _nameController.text;

      // Status field removed as staff shouldn't be able to change it

      if (_newImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _newImage!.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Updated successfully')));
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currentImagePath = widget.asset['image'];
    String fullImageUrl = '';
    if (currentImagePath != null && currentImagePath.isNotEmpty) {
      fullImageUrl =
          '$_baseUrl/${currentImagePath.replaceAll(RegExp(r'^[\\/]+'), '')}';
    }

    return Scaffold(
      backgroundColor: staffPrimaryColor,
      appBar: AppBar(
        title: const Text('Edit Asset', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _newImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_newImage!, fit: BoxFit.cover),
                        )
                      : (fullImageUrl.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            fullImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Asset Name',
                  border: OutlineInputBorder(),
                ),
              ),
              // Status field removed as staff shouldn't be able to change it
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _updateAsset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: staffButtonBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:pj2/staff_add_asset_page.dart';
// import 'package:pj2/staff_theme.dart';

// class StaffEditAssetPage extends StatelessWidget {
//   final String assetName;
//   final String imagePath;

//   const StaffEditAssetPage({
//     Key? key,
//     required this.assetName,
//     required this.imagePath,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: staffPrimaryColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: const BackButton(color: Colors.white),
//         title: const Text('Edit Asset', style: TextStyle(color: Colors.white)),
//       ),
//       body: Center(
//         child: Container(
//           width: double.infinity,
//           margin: const EdgeInsets.all(24),
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Edit Asset',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               TextField(
//                 controller: TextEditingController(text: assetName),
//                 decoration: const InputDecoration(
//                   labelText: 'Asset Name',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               OutlinedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.attach_file, color: staffButtonBlue),
//                 label: const Text(
//                   'Change Photo',
//                   style: TextStyle(color: staffButtonBlue),
//                 ),
//                 style: OutlinedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                   side: const BorderSide(color: staffButtonBlue),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: staffButtonBlue,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child: const Text(
//                   'Save Changes',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class StaffEditAssetsTab extends StatelessWidget {
//   const StaffEditAssetsTab({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final assets = [
//       {'name': 'MacBook Air', 'image': 'assets/images/macbook.jpg'},
//       {'name': 'Asus VivoBook 15', 'image': 'assets/images/AsusVivo14.jpg'},
//       {'name': 'iPad Air', 'image': 'assets/images/IPad.jpg'},
//       {'name': 'Samsung Tab S10+', 'image': 'assets/images/samsungs10.jpg'},
//       {'name': 'Canon EOS R10', 'image': 'assets/images/canon.jpg'},
//       {'name': 'Wanbo T2R Max', 'image': 'assets/images/wanbo.jpg'},
//       {'name': 'Projector', 'image': 'assets/images/projector.jpg'},
//     ];

//     return Scaffold(
//       backgroundColor: staffPrimaryColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         title: const Text(
//           'Edit Assets',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 28,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   const Expanded(
//                     child: TextField(
//                       decoration: InputDecoration(
//                         hintText: 'Search any assets',
//                         prefixIcon: Icon(Icons.search, color: Colors.white70),
//                         hintStyle: TextStyle(color: Colors.white70),
//                         filled: true,
//                         fillColor: staffSecondaryColor,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const StaffAddAssetPage(),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: staffButtonBlue,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 16,
//                         horizontal: 20,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text('Add Assets'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),

//               // Assets Grid
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 0.7, // Adjusted for buttons
//                 ),
//                 itemCount: assets.length,
//                 itemBuilder: (context, index) {
//                   return _buildAssetCard(
//                     context,
//                     assets[index]['name']!,
//                     assets[index]['image']!,
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAssetCard(BuildContext context, String name, String imagePath) {
//     return Card(
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Image.asset(
//               imagePath,
//               height: 100,
//               fit: BoxFit.contain,
//               errorBuilder: (context, error, stackTrace) =>
//                   const Icon(Icons.image_not_supported, size: 60),
//             ),
//             Text(
//               name,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//                 color: Colors.black87,
//               ),
//             ),
//             Column(
//               children: [
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => StaffEditAssetPage(
//                             assetName: name,
//                             imagePath: imagePath,
//                           ),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: staffButtonBlue,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: const Text('Edit'),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       showDialog(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: const Text('Disable Asset'),
//                           content: Text(
//                             'Are you sure you want to disable $name?',
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context),
//                               child: const Text('Cancel'),
//                             ),
//                             TextButton(
//                               onPressed: () {},
//                               style: TextButton.styleFrom(
//                                 foregroundColor: Colors.red,
//                               ),
//                               child: const Text('Disable'),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey.shade100,
//                       foregroundColor: Colors.black,
//                     ),
//                     child: const Text('Disable'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
