import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:service_provider_side/model/job_model.dart';

class JobProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<JobModel>> get newJobsStream {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'new')
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  Stream<List<JobModel>> get scheduledJobsStream {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('jobs')
        .where('assignedProviderId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'accepted')
        .orderBy('postedDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // --- THIS IS THE MISSING GETTER ---
  Stream<double> get todaysEarningsStream {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(0.0);
    }

    DateTime now = DateTime.now();
    DateTime startOfToday = DateTime(now.year, now.month, now.day);
    DateTime endOfToday = startOfToday.add(const Duration(days: 1));

    return _firestore
        .collection('jobs')
        .where('assignedProviderId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'completed')
        .where('completionDate', isGreaterThanOrEqualTo: startOfToday)
        .where('completionDate', isLessThan: endOfToday)
        .snapshots()
        .map((snapshot) {
          double total = 0.0;
          for (var doc in snapshot.docs) {
            total += (doc.data()['payout'] ?? 0.0).toDouble();
          }
          return total;
        });
  }

  Future<String?> acceptJob(String jobId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return "You must be logged in to accept a job.";
    }

    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': 'accepted',
        'assignedProviderId': currentUser.uid,
      });
      return "success";
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }
  Future<String?> completeJob({
    required String jobId,
    required String reportNotes,
    required double materialsCost,
    String? beforeImageUrl,
    String? afterImageUrl,
  }) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': 'completed',
        'completionDate': Timestamp.now(), // Set the completion date
        'reportNotes': reportNotes,
        'materialsCost': materialsCost,
        'beforeImageUrl': beforeImageUrl,
        'afterImageUrl': afterImageUrl,
      });
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }
  Stream<List<JobModel>> get completedJobsStream {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('jobs')
        .where('assignedProviderId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'completed')
        .orderBy('completionDate', descending: true) // Show most recent first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
