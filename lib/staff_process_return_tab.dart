import 'package:flutter/material.dart';
import 'package:pj2/staff_theme.dart';

class StaffProcessReturnTab extends StatefulWidget {
  const StaffProcessReturnTab({Key? key}) : super(key: key);

  @override
  State<StaffProcessReturnTab> createState() => _StaffProcessReturnTabState();
}

class _StaffProcessReturnTabState extends State<StaffProcessReturnTab> {
  //gonna replace with actual data
  final List<Map<String, dynamic>> _returnItems = [
    {
      'assetName': 'iPad Air',
      'borrower': 'Stiles',
      'approver': 'Dr. Harrison Wells',
      'borrowDate': '2/10/2025',
      'returnDate': '12/10/2025',
      'staff': 'John Diggle',
      'image': 'assets/images/IPad.jpg',
    },
    {
      'assetName': 'Asus VivoBook 14',
      'borrower': 'Mark',
      'approver': 'Dr. Martin Stein',
      'borrowDate': '5/10/2025',
      'returnDate': '15/10/2025',
      'staff': 'Cisco Ramon',
      'image': 'assets/images/AsusVivo14.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: staffPrimaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Process Return',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _returnItems.length,
              itemBuilder: (context, index) {
                final item = _returnItems[index];
                return _buildReturnItemCard(context, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnItemCard(BuildContext context, Map<String, dynamic> item) {
    // Debug print to verify data
    debugPrint('Building card with item: $item');

    return Card(
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    item['image'] ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item['assetName'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildDetailRow(
              'Borrowed by:',
              item['borrower']?.toString() ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Borrowed date:',
              item['borrowDate']?.toString() ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Returned date:',
              item['returnDate']?.toString() ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Approved by:',
              item['approver']?.toString() ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Processed by:',
              item['staff']?.toString() ?? 'N/A',
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showSuccessDialog(context, item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: staffButtonBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Process Return',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 14),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Return Confirmed.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Asset is now ready to be borrowed again',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              // const SizedBox(height: 20),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //       setState(() {
              //         _returnItems.removeWhere(
              //           (element) => element['id'] == item['id'],
              //         );
              //       });
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: staffButtonBlue,
              //       foregroundColor: Colors.white,
              //       padding: const EdgeInsets.symmetric(vertical: 14),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),
              //     child: const Text('OK'),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
