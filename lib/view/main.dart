import 'package:flutter/material.dart';
import 'package:service_provider_side/providers/authentication_provider.dart';
import 'package:service_provider_side/providers/job_provider.dart';
import 'package:service_provider_side/view/main_dashboard_page.dart';
import 'package:service_provider_side/view/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:service_provider_side/view/auth_gate.dart';
import 'package:service_provider_side/firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // Ensure Flutter is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Service Provider App',
      theme: ThemeData(brightness: Brightness.dark),
      // Define the home page and the named routes
      // home: const WelcomePage(),
      home: const AuthGate(),
      routes: {
        MainDashboardPage.routeName: (context) => const MainDashboardPage(),
      },
    );
  }
}
