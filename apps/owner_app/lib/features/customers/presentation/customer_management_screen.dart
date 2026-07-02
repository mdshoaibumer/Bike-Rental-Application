import 'package:flutter/material.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  String kycStatus; // PENDING, APPROVED, REJECTED
  final String dlUrl;
  final String aadhaarUrl;
  bool isBlocked;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.kycStatus,
    required this.dlUrl,
    required this.aadhaarUrl,
    this.isBlocked = false,
  });
}

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final List<Customer> _customers = [
    Customer(
      id: '1',
      name: 'Amit Sharma',
      phone: '+91 98765 43210',
      email: 'amit.sharma@gmail.com',
      kycStatus: 'PENDING',
      dlUrl: 'https://placeholder.com/dl.jpg',
      aadhaarUrl: 'https://placeholder.com/aadhaar.jpg',
    ),
    Customer(
      id: '2',
      name: 'Rohan Verma',
      phone: '+91 91234 56789',
      email: 'rohan.v@yahoo.com',
      kycStatus: 'APPROVED',
      dlUrl: 'https://placeholder.com/dl2.jpg',
      aadhaarUrl: 'https://placeholder.com/aadhaar2.jpg',
    ),
    Customer(
      id: '3',
      name: 'Priya Patel',
      phone: '+91 88776 65544',
      email: 'priya.patel@gmail.com',
      kycStatus: 'REJECTED',
      dlUrl: 'https://placeholder.com/dl3.jpg',
      aadhaarUrl: 'https://placeholder.com/aadhaar3.jpg',
    ),
  ];

  void _verifyKYC(String id, bool approved) {
    setState(() {
      final customer = _customers.firstWhere((c) => c.id == id);
      customer.kycStatus = approved ? 'APPROVED' : 'REJECTED';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(approved ? 'KYC Document Approved' : 'KYC Document Rejected')),
    );
  }

  void _toggleBlock(String id) {
    setState(() {
      final customer = _customers.firstWhere((c) => c.id == id);
      customer.isBlocked = !customer.isBlocked;
    });
    final customer = _customers.firstWhere((c) => c.id == id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(customer.isBlocked ? 'Customer Blocked' : 'Customer Unblocked')),
    );
  }

  void _showKYCDetailsDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('${customer.name} - Verification Documents'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Driving License Image:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                height: 100,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: const Center(child: Text('[Driving License Document Mock Preview]')),
              ),
              const SizedBox(height: 12),
              const Text('Aadhaar Card Image:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                height: 100,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: const Center(child: Text('[Aadhaar Document Mock Preview]')),
              ),
            ],
          ),
          actions: [
            if (customer.kycStatus == 'PENDING') ...[
              TextButton(
                onPressed: () {
                  _verifyKYC(customer.id, false);
                  Navigator.pop(ctx);
                },
                child: const Text('Reject KYC', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  _verifyKYC(customer.id, true);
                  Navigator.pop(ctx);
                },
                child: const Text('Approve KYC'),
              ),
            ] else
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users & KYC Console'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _customers.length,
        itemBuilder: (ctx, idx) {
          final customer = _customers[idx];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      _buildKYCBadge(customer.kycStatus),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Phone: ${customer.phone}', style: const TextStyle(fontSize: 13)),
                  Text('Email: ${customer.email}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showKYCDetailsDialog(customer),
                        icon: const Icon(Icons.document_scanner_outlined, size: 16),
                        label: const Text('Verify KYC Doc'),
                      ),
                      ElevatedButton(
                        onPressed: () => _toggleBlock(customer.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customer.isBlocked ? Colors.green : Colors.red,
                        ),
                        child: Text(
                          customer.isBlocked ? 'Unblock User' : 'Block User',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKYCBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'PENDING':
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        break;
      case 'APPROVED':
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
      default:
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        'KYC: $status',
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
