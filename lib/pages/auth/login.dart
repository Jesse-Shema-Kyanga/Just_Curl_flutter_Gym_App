import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../helpers/database_helper.dart'; // Adjust the path as necessary
import '../../user_preferences.dart';
import '../home/home.dart';
import 'google_signin_api.dart'; // Update the path here

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
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
                  'logIn'.tr(),
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email'.tr();
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email'.tr();
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password'.tr();
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value ?? '',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('logIn'.tr()),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.red,
                  ),
                  label: Text('Sign in with Google'.tr()),
                  onPressed: _signInWithGoogle,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  child: Text('dontHaveAccount'.tr()),
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

      // Check user credentials
      final user = await DatabaseHelper().getUser(_email, _password);
      if (user != null) {
        // Save login status and email in shared preferences
        await Future.wait([
          UserPreferences.setLoginStatus(true),
          UserPreferences.setEmail(_email),
        ]);

        // Navigate to home page
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('invalidCredentials'.tr())),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final user = await GoogleSignInApi.login();
      if (user != null) {
        // Save Google user data
        await Future.wait([
          UserPreferences.setLoginStatus(true),
          UserPreferences.setEmail(user.email),
        ]);

        // Check if user exists in database
        final dbUser = await DatabaseHelper().getUserProfile(user.email);
        if (dbUser == null) {
          // Create new user profile if doesn't exist
          await DatabaseHelper().insertUserProfile({
            'email': user.email,
            'name': user.displayName ?? '',
            'workout_goal': '', // Default empty goal
          });
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in Failed'.tr())),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during sign in'.tr())),
      );
      print('Error during Google sign-in: $error');
    }
  }
}