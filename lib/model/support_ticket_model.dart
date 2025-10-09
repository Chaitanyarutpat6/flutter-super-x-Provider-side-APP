import 'package:cloud_firestore/cloud_firestore.dart';

//import 'package.cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class SupportTicketModel {
  final String? id;
  final String userId;
  final String question;
  final String status;
  final DateTime createdAt;

  SupportTicketModel({
    this.id,
    required this.userId,
    required this.question,
    this.status = 'new',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'question': question,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}