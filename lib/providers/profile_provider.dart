import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:service_provider_side/model/job_model.dart';
import 'package:service_provider_side/model/notification_model.dart';
import 'package:service_provider_side/model/provider_model.dart';
import 'package:service_provider_side/model/review_model.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Stream for the provider's own profile data
  Stream<ProviderModel?> get providerStream {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(null);
    }
    return _firestore.collection('providers').doc(currentUser.uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return ProviderModel.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  // Stream for the provider's reviews
  Stream<List<ReviewModel>> get reviewsStream {
     final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('reviews')
        .where('providerId', isEqualTo: currentUser.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReviewModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  // In lib/providers/profile_provider.dart

  // --- NEW: Stream for pending payout amount ---
  Stream<double> get pendingPayoutStream {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(0.0);
    }

    return _firestore
        .collection('jobs')
        .where('assignedProviderId', isEqualTo: currentUser.uid)
        .where('payoutStatus', isEqualTo: 'pending') // Find jobs waiting for payout
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        final job = JobModel.fromMap(doc.data(), doc.id);
        total += job.payout + (job.materialsCost ?? 0.0);
      }
      return total;
    });
  }

  // --- NEW: Getter for next payout date ---
  String get nextPayoutDate {
    final now = DateTime.now();
    // Example logic: Payouts are on the 15th of the month.
    if (now.day < 15) {
      // If it's before the 15th, next payout is this month.
      return DateFormat('MMM d, yyyy').format(DateTime(now.year, now.month, 15));
    } else {
      // If it's on or after the 15th, next payout is next month.
      return DateFormat('MMM d, yyyy').format(DateTime(now.year, now.month + 1, 15));
    }
  }
   // --- NEW: Stream for notifications ---
  Stream<List<NotificationModel>> get notificationsStream {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  // In lib/providers/profile_provider.dart

  // --- NEW: Method to update profile data ---
  Future<String?> updateProfile({
    required String fullName,
    required String phone,
    String? newProfilePictureUrl,
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return "No user logged in.";
    }

    try {
      // Create a map of the data to update
      Map<String, dynamic> dataToUpdate = {
        'fullName': fullName,
        'phone': phone,
      };

      // Only add the profile picture URL if a new one was provided
      if (newProfilePictureUrl != null) {
        dataToUpdate['profilePictureUrl'] = newProfilePictureUrl;
      }

      // Update the document in Firestore
      await _firestore.collection('providers').doc(currentUser.uid).update(dataToUpdate);
      
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }
  // In lib/providers/profile_provider.dart

  // --- NEW: Stream for blocked dates ---
  Stream<Set<DateTime>> get blockedDatesStream {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value({});
    }
    return _firestore
        .collection('providers')
        .doc(currentUser.uid)
        .collection('blocked_dates')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // The document ID is the date in 'YYYY-MM-DD' format
        return DateTime.parse(doc.id);
      }).toSet();
    });
  }

  // --- NEW: Method to block or unblock a date ---
  Future<void> toggleBlockedDate(DateTime date) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Use a consistent, simple format for the document ID
    String docId = DateFormat('yyyy-MM-dd').format(date);
    DocumentReference docRef = _firestore
        .collection('providers')
        .doc(currentUser.uid)
        .collection('blocked_dates')
        .doc(docId);

    // Check if the date already exists
    final doc = await docRef.get();
    if (doc.exists) {
      // If it exists, delete it to unblock the date
      await docRef.delete();
    } else {
      // If it doesn't exist, create it to block the date
      await docRef.set({'blockedAt': Timestamp.now()});
    }
  }
  // In lib/providers/profile_provider.dart

  // --- NEW: Method to update settings ---
  Future<void> updateSettings(Map<String, dynamic> settingsData) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore.collection('providers').doc(currentUser.uid).update(settingsData);
    } catch (e) {
      print("Error updating settings: $e");
    }
  }
}