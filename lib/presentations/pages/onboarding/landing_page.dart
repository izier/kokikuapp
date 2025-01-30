// ignore_for_file: use_build_context_synchronously

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

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<User?> _signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    final LocalizationService localizations = LocalizationService.of(context)!;

    try {
      // Trigger the Google Sign-In flow
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
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

      setState(() {
        isLoading = false;
      });

      showSuccessToast(
        context: context,
        title: localizations.translate('loggedIn'),
        message: localizations.translate('loggedInSub'),
      );

      return userCredential.user;
    } catch (e) {
      setState(() {
        isLoading = false;
      });

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
    final LocalizationService localizations = LocalizationService.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColorLight,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              Asset.landing, // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Contents
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  // Logo
                  Row(
                    children: [
                      Image.asset(
                        Asset.logo, // Replace with your logo path
                        height: 50,
                      ),
                      const SizedBox(width: 8),
                      Text(
                          localizations.translate('appTitle'),
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          )
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Main Text
                  Text(
                      localizations.translate('landing'),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  const SizedBox(height: 16),
                  Text(
                      localizations.translate('landingSub'),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white
                      )
                  ),
                  const Spacer(),
                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to get started
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(localizations.translate('createAccount')),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to login
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(localizations.translate('login')),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                      child: Text(
                        localizations.translate('orContinueWith'),
                        style: TextStyle(color: Colors.white),
                      )
                  ),
                  const SizedBox(height: 8),
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
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Asset.google, width: 16),
                          const SizedBox(width: 16),
                          Text('Google')
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
