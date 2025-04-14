import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/constants/variables/asset.dart';
import 'package:kokiku/constants/variables/theme.dart';
import 'package:kokiku/datas/models/remote/user.dart';
import 'package:kokiku/presentations/widgets/custom_toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  Future<void> _loginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final localization = LocalizationService.of(context)!;

    setState(() {
      _emailError = email.isEmpty ? localization.translate('emptyEmail') :
      !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email) ? localization.translate('invalidEmail') : null;
      _passwordError = password.isEmpty ? localization.translate('emptyPassword') : null;
    });

    if (_emailError != null || _passwordError != null) return;

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      showSuccessToast(
        context: context,
        title: localization.translate('success'),
        message: localization.translate('loggedIn'),
      );
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      log("Error: $e");
      showErrorToast(
        context: context,
        title: localization.translate('error'),
        message: e.toString(),
      );
    }
  }

  Future<User?> _signInWithGoogle() async {
    final LocalizationService localizations = LocalizationService.of(context)!;

    try {
      // Trigger the Google Sign-In flow
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      // Obtain the Google authentication details
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase authentication
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      showSuccessToast(
        context: context,
        title: localizations.translate('loggedIn'),
        message: localizations.translate('loggedInSub'),
      );

      return userCredential.user;
    } catch (e) {
      log("Error: $e");

      showErrorToast(
        context: context,
        title: localizations.translate('loggedInFail'),
        message: e.toString(),
      );

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              Asset.landing,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(alignment: Alignment.topLeft, child: BackButton()),
                      SizedBox(
                        height: 120,
                        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        localization.translate('login'),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: localization.translate('email'),
                          border: OutlineInputBorder(),
                          errorText: _emailError,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: localization.translate('password'),
                          border: OutlineInputBorder(),
                          errorText: _passwordError,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loginWithEmail,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(localization.translate('login')),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            User? user = await _signInWithGoogle();
                            if (user != null) {
                              // Check if the user exists in the 'users' collection
                              var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

                              if (!userDoc.exists) {
                                // Create the user's document if it doesn't exist
                                UserModel newUser = UserModel(
                                  id: user.uid,
                                  email: user.email ?? '',
                                  name: user.displayName ?? '',
                                  accessIds: [], // You can add logic to assign access IDs if needed
                                  photoUrl: user.photoURL,
                                  createdAt: DateTime.now(),
                                );

                                // Store user data in Firestore
                                await FirebaseFirestore.instance.collection('users').doc(user.uid).set(newUser.toFirestore());
                              }

                              Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
                            } else {
                              // Handle failed login or user cancellation
                              log("Login failed or cancelled");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: AppTheme.primaryColor)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(Asset.google, width: 16),
                              const SizedBox(width: 16),
                              Text(localization.translate('continue_with_google')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(localization.translate('no_account')),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/register');
                            },
                            child: Text(localization.translate('createAccount')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}