import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ThemeNotifier.dart';
import '../user_preferences.dart'; // Ensure to import UserPreferences
import '../pages/home/widgets/reach_out_section.dart';
import 'package:easy_localization/easy_localization.dart'; // Ensure to import easy_localization for lang

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Contact> _emergencyContacts = [];
  String _selectedLanguage = 'en'; // Default language is English

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
    _loadLanguage();
  }

  // Load emergency contacts
  Future<void> _loadEmergencyContacts() async {
    _emergencyContacts = await UserPreferences.loadEmergencyContacts();
    setState(() {});
  }

  // Load selected language from SharedPreferences
  Future<void> _loadLanguage() async {
    String language = await UserPreferences.loadLanguage();
    setState(() {
      _selectedLanguage = language;
      context.setLocale(Locale(language)); // Change language in the context
    });
  }

  // Save selected language to SharedPreferences
  void _saveLanguage(String languageCode) {
    UserPreferences.saveLanguage(languageCode);
    setState(() {
      _selectedLanguage = languageCode;
      context.setLocale(Locale(languageCode)); // Change language in the context
    });
  }

  // Pick emergency contact
  Future<void> _pickEmergencyContact() async {
    if (await Permission.contacts.request().isGranted) {
      final Contact? contact = await ContactsService.openDeviceContactPicker();
      if (contact != null) {
        setState(() {
          _emergencyContacts.add(contact);
        });
        await UserPreferences.saveEmergencyContacts(_emergencyContacts);
      }
    }
  }

  // Make phone call (implement your logic here)
  Future<void> _makePhoneCall(String? phoneNumber) async {
    // Implement logic to make a phone call to the given phone number
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr()), // Use the settings key from en.json
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                SwitchListTile(
                  title: Text('darkMode'.tr()), // Replace with darkMode key
                  value: themeNotifier.isDarkMode,
                  onChanged: (bool value) {
                    themeNotifier.toggleTheme();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('themeChanged'.tr(args: [value ? 'Dark' : 'Light'])),
                      ),
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
                        Text(
                          'emergencyContacts'.tr(), // Use the emergencyContacts key from en.json
                          style: const TextStyle(
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
                          child: Text('addEmergencyContact'.tr()), // Use addEmergencyContact key
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Language selection dropdown
                DropdownButton<String>(
                  value: _selectedLanguage,
                  items: const [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: 'fr',
                      child: Text('Français'),
                    ),
                    DropdownMenuItem(
                      value: 'es',
                      child: Text('Español'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _saveLanguage(value); // Save language preference and update locale
                    }
                  },
                  isExpanded: true,
                  hint: const Text('selectLanguage').tr(), // Translate the 'Select Language' key
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
