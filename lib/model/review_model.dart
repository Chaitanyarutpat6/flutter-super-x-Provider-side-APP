import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String jobId;
  final String providerId;
  final double rating;
  final String comment;
  final DateTime date;

  ReviewModel({
    required this.id,
    required this.jobId,
    required this.providerId,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ReviewModel(
      id: documentId,
      jobId: data['jobId'] ?? '',
      providerId: data['providerId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}