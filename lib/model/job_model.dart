import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String title;
  final String location;
  final String description;
  final double payout;
  final String status;
  final DateTime postedDate;
  final String? assignedProviderId;

  JobModel({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.payout,
    required this.status,
    required this.postedDate,
    this.assignedProviderId,
  });

  // Factory constructor to create a JobModel from a Firestore document
  factory JobModel.fromMap(Map<String, dynamic> data, String documentId) {
    return JobModel(
      id: documentId,
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      payout: (data['payout'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'new',
      postedDate: (data['postedDate'] as Timestamp).toDate(),
      assignedProviderId: data['assignedProviderId'],
    );
  }

  // Method to convert a JobModel object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'description': description,
      'payout': payout,
      'status': status,
      'postedDate': Timestamp.fromDate(postedDate),
      'assignedProviderId': assignedProviderId,
    };
  }
}