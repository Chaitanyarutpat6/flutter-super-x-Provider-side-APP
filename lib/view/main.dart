import 'package:flutter/material.dart';
import 'package:service_provider_side/providers/authentication_provider.dart';
import 'package:service_provider_side/providers/job_provider.dart';
import 'package:service_provider_side/providers/profile_provider.dart';
import 'package:service_provider_side/providers/support_provider.dart';
import 'package:service_provider_side/view/main_dashboard_page.dart';
import 'package:service_provider_side/view/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:service_provider_side/view/auth_gate.dart';
import 'package:service_provider_side/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/providers/job_provider.dart';
import 'package:service_provider_side/providers/storage_provider.dart';

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
        ChangeNotifierProvider(create: (_) => StorageProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SupportProvider()),
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
      home: const AuthGate(),
      routes: {
        MainDashboardPage.routeName: (context) => const MainDashboardPage(),
      },
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';
// import 'package:service_provider_side/firebase_options.dart';
// import 'package:service_provider_side/providers/authentication_provider.dart';
// import 'package:service_provider_side/providers/job_provider.dart';
// import 'package:service_provider_side/providers/storage_provider.dart';
// import 'package:service_provider_side/view/auth_gate.dart';
// import 'package:service_provider_side/view/main_dashboard_page.dart';
// import 'package:service_provider_side/firebase_options.dart';

// // Your main function is now synchronous again
// void main() {
//   runApp(const AppInitializer());
// }

// // A new widget to handle the async initialization
// class AppInitializer extends StatefulWidget {
//   const AppInitializer({super.key});

//   @override
//   State<AppInitializer> createState() => _AppInitializerState();
// }

// class _AppInitializerState extends State<AppInitializer> {
//   // A Future to hold the result of Firebase initialization
//   late final Future<FirebaseApp> _initialization;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsFlutterBinding.ensureInitialized();
//     _initialization = Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Use a FutureBuilder to wait for Firebase to initialize
//     return FutureBuilder(
//       future: _initialization,
//       builder: (context, snapshot) {
//         // If there's an error, show it
//         if (snapshot.hasError) {
//           return const Center(child: Text('Error initializing Firebase'));
//         }

//         // Once complete, show your application
//         if (snapshot.connectionState == ConnectionState.done) {
//           return MultiProvider(
//             providers: [
//               ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
//               ChangeNotifierProvider(create: (_) => JobProvider()),
//               ChangeNotifierProvider(create: (_) => StorageProvider()),
//             ],
//             child: const MyApp(),
//           );
//         }

//         // Otherwise, show a loading indicator
//         return const Center(child: CircularProgressIndicator());
//       },
//     );
//   }
// }


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Service Provider App',
//       theme: ThemeData(
//         brightness: Brightness.dark,
//       ),
//       home: const AuthGate(),
//       routes: {
//         MainDashboardPage.routeName: (context) => const MainDashboardPage(),
//       },
//     );
//   }
// }