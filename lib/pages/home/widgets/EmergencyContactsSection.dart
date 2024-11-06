import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../user_preferences.dart'; // Ensure to import UserPreferences

class EmergencyContactsSection extends StatefulWidget {
  const EmergencyContactsSection({Key? key}) : super(key: key);

  @override
  _EmergencyContactsSectionState createState() => _EmergencyContactsSectionState();
}

class _EmergencyContactsSectionState extends State<EmergencyContactsSection> {
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
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Logic to initiate a call
      // For example, you can use url_launcher to open the dialer
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
            // Display the emergency contacts
            ...List.generate(_emergencyContacts.length, (index) {
              final contact = _emergencyContacts[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(contact.displayName ?? ''),
                subtitle: Text(contact.phones?.first.value ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    // Make a phone call to the emergency contact
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
    );
  }
}
