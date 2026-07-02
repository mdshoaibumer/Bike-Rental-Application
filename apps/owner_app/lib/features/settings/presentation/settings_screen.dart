import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OwnerSettingsScreen extends StatefulWidget {
  const OwnerSettingsScreen({super.key});

  @override
  State<OwnerSettingsScreen> createState() => _OwnerSettingsScreenState();
}

class _OwnerSettingsScreenState extends State<OwnerSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailReports = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Business Section
          const Text('BUSINESS PROFILE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              leading: Icon(Icons.business, color: Colors.indigo),
              title: Text('Metro Fleet Rentals Ltd.'),
              subtitle: Text('GSTIN: 27AAAAA1111A1Z2\nFleet Size: 24 active'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 20),

          // Preference Section
          const Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('New Booking Push Alerts'),
                  subtitle: const Text('Get real-time booking notifications'),
                  value: _pushNotifications,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Daily Summary Reports'),
                  subtitle: const Text('Receive end of day revenue PDFs'),
                  value: _emailReports,
                  onChanged: (val) => setState(() => _emailReports = val),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Console Language'),
                  trailing: Text(_selectedLanguage, style: const TextStyle(color: Colors.grey)),
                  onTap: () {
                    setState(() {
                      _selectedLanguage = _selectedLanguage == 'English' ? 'Hindi' : 'English';
                    });
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About Section
          const Text('ABOUT & LEGAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Partner Agreement'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Support Desk'),
                  subtitle: const Text('support@bikerentalhub.com'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Logout Action Button
          ElevatedButton.icon(
            onPressed: () {
              // Sign out from application
              context.go('/login');
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('LOGOUT FROM CONSOLE', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Console Version 1.2.0',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          )
        ],
      ),
    );
  }
}
