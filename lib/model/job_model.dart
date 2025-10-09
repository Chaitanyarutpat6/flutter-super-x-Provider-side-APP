import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String title;
  final String location;
  final double payout;
  final DateTime postedDate;
  final String status;
  final String? assignedProviderId;
  final String? description; // New field
  final String? customerName; // New field
  final String? customerPhone; // New field
  final DateTime? completionDate; // New field for completion
  final String? beforeImageUrl; // New field for image
  final String? afterImageUrl; // New field for image
  final String? reportNotes; // New field for report text
  final double materialsCost;

  JobModel({
    required this.id,
    required this.title,
    required this.location,
    required this.payout,
    required this.postedDate,
    required this.status,
    this.assignedProviderId,
    this.description, // Initialize new fields
    this.customerName,
    this.customerPhone,
    this.completionDate,
    this.beforeImageUrl,
    this.afterImageUrl,
    this.reportNotes,
    this.materialsCost = 0.0,
  });

  factory JobModel.fromMap(Map<String, dynamic> data, String id) {
    return JobModel(
      id: id,
      title: data['title'] as String,
      location: data['location'] as String,
      payout: (data['payout'] as num).toDouble(),
      postedDate: (data['postedDate'] as Timestamp).toDate(),
      status: data['status'] as String,
      assignedProviderId: data['assignedProviderId'] as String?,
      description: data['description'] as String?, // Map new fields
      customerName: data['customerName'] as String?,
      customerPhone: data['customerPhone'] as String?,
      completionDate: (data['completionDate'] as Timestamp?)?.toDate(),
      beforeImageUrl: data['beforeImageUrl'] as String?,
      afterImageUrl: data['afterImageUrl'] as String?,
      reportNotes: data['reportNotes'] as String?,
      materialsCost: (data['materialsCost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'payout': payout,
      'postedDate': Timestamp.fromDate(postedDate),
      'status': status,
      'assignedProviderId': assignedProviderId,
      'description': description,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'completionDate': completionDate != null ? Timestamp.fromDate(completionDate!) : null,
      'beforeImageUrl': beforeImageUrl,
      'afterImageUrl': afterImageUrl,
      'reportNotes': reportNotes,
      'materialsCost': materialsCost,
    };
  }

  // Add copyWith for easy updates
  JobModel copyWith({
    String? id,
    String? title,
    String? location,
    double? payout,
    DateTime? postedDate,
    String? status,
    String? assignedProviderId,
    String? description,
    String? customerName,
    String? customerPhone,
    DateTime? completionDate,
    String? beforeImageUrl,
    String? afterImageUrl,
    String? reportNotes,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      payout: payout ?? this.payout,
      postedDate: postedDate ?? this.postedDate,
      status: status ?? this.status,
      assignedProviderId: assignedProviderId ?? this.assignedProviderId,
      description: description ?? this.description,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      completionDate: completionDate ?? this.completionDate,
      beforeImageUrl: beforeImageUrl ?? this.beforeImageUrl,
      afterImageUrl: afterImageUrl ?? this.afterImageUrl,
      reportNotes: reportNotes ?? this.reportNotes,
    );
  }
}