import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ThemeNotifier.dart';
import '../user_preferences.dart'; // Ensure to import UserPreferences
import '../pages/home/widgets/reach_out_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Contact> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    _emergencyContacts = await UserPreferences.loadEmergencyContacts();
    setState(() {});
  }

  Future<void> _pickEmergencyContact() async {
    // Request contacts permission
    if (await Permission.contacts.request().isGranted) {
      // Open device contact picker
      final Contact? contact = await ContactsService.openDeviceContactPicker();
      if (contact != null) {
        // Save the selected contact to the _emergencyContacts list
        setState(() {
          _emergencyContacts.add(contact);
        });
        // Save the emergency contacts to UserPreferences
        await UserPreferences.saveEmergencyContacts(_emergencyContacts);
      }
    }
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    // Implement logic to make a phone call to the given phone number
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: themeNotifier.isDarkMode,
                  onChanged: (bool value) {
                    themeNotifier.toggleTheme();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Theme changed to ${value ? 'Dark' : 'Light'} mode')),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Emergency Contacts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(_emergencyContacts.length, (index) {
                          final contact = _emergencyContacts[index];
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(contact.displayName ?? ''),
                            subtitle: Text(contact.phones?.first.value ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.call),
                              onPressed: () {
                                _makePhoneCall(contact.phones?.first.value);
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _pickEmergencyContact,
                          child: const Text('Add Emergency Contact'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const ReachOutSection(),
        ],
      ),
    );
  }
}
