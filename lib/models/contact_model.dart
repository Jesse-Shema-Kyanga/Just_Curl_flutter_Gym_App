import 'package:contacts_service/contacts_service.dart';

class ContactModel {
  String displayName;
  String? phoneNumber;

  ContactModel({required this.displayName, this.phoneNumber});

  // Convert a Contact to a ContactModel
  factory ContactModel.fromContact(Contact contact) {
    return ContactModel(
      displayName: contact.displayName ?? '',
      phoneNumber: contact.phones?.isNotEmpty == true ? contact.phones!.first.value : null,
    );
  }

  // Convert ContactModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'phoneNumber': phoneNumber,
    };
  }

  // Create a ContactModel from JSON
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      displayName: json['displayName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }
}
