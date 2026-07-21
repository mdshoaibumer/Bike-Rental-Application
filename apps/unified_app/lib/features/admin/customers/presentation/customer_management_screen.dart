import 'package:flutter/material.dart';
import 'package:shared/demo/mock_data.dart';

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
  late final List<Customer> _customers;

  @override
  void initState() {
    super.initState();
    _customers = MockData.customers.map((c) => Customer(
      id: c['id'],
      name: c['name'],
      phone: c['phone'],
      email: c['email'],
      kycStatus: c['kycStatus'],
      dlUrl: c['dlUrl'],
      aadhaarUrl: c['aadhaarUrl'],
      isBlocked: c['isBlocked'],
    )).toList();
  }

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('${customer.name} - Verification', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Driving License:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Icon(Icons.badge_rounded, size: 48, color: Colors.grey)),
              ),
              const SizedBox(height: 16),
              const Text('Aadhaar Card:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Icon(Icons.contact_mail_rounded, size: 48, color: Colors.grey)),
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
                child: const Text('Reject', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  _verifyKYC(customer.id, true);
                  Navigator.pop(ctx);
                },
                child: const Text('Approve'),
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
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _customers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (ctx, idx) {
          final customer = _customers[idx];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Theme.of(context).colorScheme.surfaceVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: Text(
                              customer.name.substring(0, 1),
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                customer.phone,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildKYCBadge(customer.kycStatus),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Text(customer.email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showKYCDetailsDialog(customer),
                        icon: const Icon(Icons.document_scanner_rounded, size: 18),
                        label: const Text('Verify Docs'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(120, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _toggleBlock(customer.id),
                        icon: Icon(
                          customer.isBlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                          size: 18,
                        ),
                        label: Text(
                          customer.isBlocked ? 'Unblock' : 'Block',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customer.isBlocked ? Colors.grey[800] : Colors.red[600],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(110, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
