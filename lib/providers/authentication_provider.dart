import 'dart:io'; // Add this for File handling
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Add this for XFile
import 'package:service_provider_side/model/provider_model.dart';
import 'package:service_provider_side/providers/storage_provider.dart'; // Import StorageProvider

class AuthenticationProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- THIS IS THE CORRECTED SIGN UP METHOD ---
  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    // Add the image files as parameters
    XFile? aadharImage,
    XFile? licenseImage,
  }) async {
    String? res = "An unknown error occurred.";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          fullName.isNotEmpty &&
          phone.isNotEmpty) {
        // 1. Create the user in Firebase Authentication
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (cred.user != null) {
          // --- NEW: UPLOAD IMAGES TO FIREBASE STORAGE ---
          final storageProvider = StorageProvider();
          String? aadharUrl;
          String? licenseUrl;

          // Upload Aadhaar image if it exists
          if (aadharImage != null) {
            aadharUrl = await storageProvider.uploadImage(
              aadharImage,
              'providers/${cred.user!.uid}', // Folder path
              'aadhar_proof', // File name
            );
          }

          // Upload License image if it exists
          if (licenseImage != null) {
            licenseUrl = await storageProvider.uploadImage(
              licenseImage,
              'providers/${cred.user!.uid}', // Folder path
              'license_proof', // File name
            );
          }

          // 2. Create a ProviderModel with the new data, including image URLs
          ProviderModel newProvider = ProviderModel(
            uid: cred.user!.uid,
            fullName: fullName,
            email: email,
            phone: phone,
            aadharUrl: aadharUrl, // Save the URL
            licenseUrl: licenseUrl, // Save the URL
          );

          // 3. Save the provider's data (with image URLs) to Firestore
          await _firestore
              .collection('providers')
              .doc(cred.user!.uid)
              .set(newProvider.toMap());

          res = "success";
        }
      } else {
        res = "Please fill in all the fields.";
      }
    } on FirebaseAuthException catch (e) {
      res = e.message;
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Login method remains the same
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    String? res = "An unknown error occurred.";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please fill in all the fields.";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        res = 'Invalid email or password.';
      } else {
        res = e.message;
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> logout() async {}
}



























///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:service_provider_side/model/provider_model.dart'; // Corrected path

// class AuthenticationProvider with ChangeNotifier {
//   // Instances of Firebase services
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // --- METHODS ---

//   Future<String?> signUp({
//     required String fullName,
//     required String email,
//     required String password,
//     required String phone,
//     // We'll add more fields like skills later
//   }) async {
//     String? res = "An unknown error occurred.";
//     try {
//       if (email.isNotEmpty && password.isNotEmpty && fullName.isNotEmpty && phone.isNotEmpty) {
//         // 1. Create the user in Firebase Authentication
//         UserCredential cred = await _auth.createUserWithEmailAndPassword(
//           email: email,
//           password: password,
//         );

//         if (cred.user != null) {
//           // 2. Create a ProviderModel object with the new user's data
//           ProviderModel newProvider = ProviderModel(
//             uid: cred.user!.uid,
//             fullName: fullName,
//             email: email,
//             phone: phone,
//             // We can add default values for other fields
//             averageRating: 0.0,
//             certifiedSkills: [],
//           );

//           // 3. Save the new provider's data to the 'providers' collection in Firestore
//           await _firestore.collection('providers').doc(cred.user!.uid).set(newProvider.toMap());

//           res = "success";
//         }
//       } else {
//         res = "Please fill in all the fields.";
//       }
//     } on FirebaseAuthException catch (e) {
//       // Handle specific Firebase errors
//       if (e.code == 'weak-password') {
//         res = 'The password provided is too weak.';
//       } else if (e.code == 'email-already-in-use') {
//         res = 'An account already exists for that email.';
//       } else {
//         res = e.message; // Other Firebase Auth errors
//       }
//     } catch (e) {
//       res = e.toString();
//     }
//     return res;
//   }

//   // We will implement login and logout logic later
//   Future<String?> login({
//     required String email,
//     required String password,
//   }) async {
//     String? res = "An unknown error occurred.";
//     try {
//       if (email.isNotEmpty && password.isNotEmpty) {
//         // Sign in the user with Firebase Authentication
//         await _auth.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//         res = "success";
//       } else {
//         res = "Please fill in all the fields.";
//       }
//     } on FirebaseAuthException catch (e) {
//       // Handle specific Firebase login errors
//       if (e.code == 'user-not-found' || e.code == 'wrong-password') {
//         res = 'Invalid email or password.';
//       } else {
//         res = e.message;
//       }
//     } catch (e) {
//       res = e.toString();
//     }
//     return res;
//   }
//   Future<void> logout() async {}
// }