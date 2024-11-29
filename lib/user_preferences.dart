import 'package:shared_preferences/shared_preferences.dart';
import 'package:contacts_service/contacts_service.dart';
import 'dart:convert';
import 'models/contact_model.dart'; // Ensure this import is correct

class UserPreferences {
  // Save login status
  static Future<void> setLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
  }

  // Get login status
  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false; // Default to false
  }

  // Save profile picture path
  static Future<void> setProfilePicture(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profilePicture', path);
  }

  // Get profile picture path
  static Future<String?> getProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profilePicture'); // Returns null if not set
  }

  // Clear login status
  static Future<void> clearLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Remove the login status
  }

  // Save emergency contacts
  static Future<void> saveEmergencyContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> contactsJson = contacts
        .map((contact) => jsonEncode(ContactModel.fromContact(contact).toJson()))
        .toList();
    await prefs.setStringList('emergencyContacts', contactsJson);
  }

  // Load emergency contacts
  static Future<List<Contact>> loadEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? contactsJson = prefs.getStringList('emergencyContacts');
    if (contactsJson != null) {
      // Convert the JSON strings back into Contact objects
      return contactsJson.map((json) {
        final model = ContactModel.fromJson(jsonDecode(json));
        return Contact()
          ..displayName = model.displayName
          ..phones = [Item(label: 'mobile', value: model.phoneNumber)];
      }).toList();
    }
    return []; // Return an empty list if no contacts found
  }

  // Clear emergency contacts
  static Future<void> clearEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('emergencyContacts');
  }

  // Save selected language
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }

  // Load selected language
  static Future<String> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'en'; // Default to English if not set
  }
}
