import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'createAccount'.tr(),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'name'.tr(), // Replace with the key for "Name"
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterYourName'.tr(); // Key for "Please enter your name"
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'email'.tr(), // Replace with the key for "Email"
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterYourEmail'.tr(); // Key for "Please enter your email"
                    }
                    if (!value.contains('@')) {
                      return 'invalidEmail'.tr(); // Key for "Please enter a valid email"
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'password'.tr(), // Replace with the key for "Password"
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterYourPassword'.tr(); // Key for "Please enter a password"
                    }
                    if (value.length < 6) {
                      return 'passwordTooShort'.tr(); // Key for "Password must be at least 6 characters long"
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value ?? '',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('signUp'.tr()), // Key for "Sign Up"
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  child: Text('alreadyHaveAccount'.tr()), // Key for "Already have an account? Log in"
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Check if user already exists
      bool exists = await DatabaseHelper().userExists(_email);
      if (exists) {
        // Show an error message if the user already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('userAlreadyExists'.tr())), // Key for "User already exists with this email"
        );
        return;
      }

      // Create a new user map
      Map<String, dynamic> user = {
        'email': _email,
        'password': _password,
      };

      // Insert user into the database
      await DatabaseHelper().insertUser(user);

      // Navigate to the weight goal page
      Navigator.pushReplacementNamed(context, '/weight_goal');
    }
  }
}
