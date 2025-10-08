import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_provider_side/model/job_model.dart';

class JobProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Stream of New Job Opportunities ---
  Stream<List<JobModel>> get newJobsStream {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'new') // Only fetch jobs with a 'new' status
        .orderBy('postedDate', descending: true) // Show the newest jobs first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Convert each document into a JobModel
        return JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // We will add methods here later to accept jobs, complete jobs, etc.
}