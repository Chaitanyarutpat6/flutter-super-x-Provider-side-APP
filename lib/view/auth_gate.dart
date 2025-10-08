import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_provider_side/view/main_dashboard_page.dart';
import 'package:service_provider_side/view/welcome_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // Listen to the Firebase authentication state
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the user is not logged in, show the WelcomePage
          if (!snapshot.hasData) {
            return const WelcomePage();
          }

          // If the user is logged in, show the MainDashboardPage
          return const MainDashboardPage();
        },
      ),
    );
  }
}