import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:service_provider_side/model/faq_model.dart';
import 'package:service_provider_side/model/support_ticket_model.dart';

class SupportProvider with ChangeNotifier {
  // --- ADD THESE TWO LINES ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<FaqModel> _faqList = [
    FaqModel(
      question: 'How are service providers vetted?',
      answer:
          'Every provider undergoes a rigorous, multi-stage "Prive Vetting Protocol," including background checks, in-person skill assessments, and reference verification to ensure the highest standards of trust and quality.',
    ),
    FaqModel(
      question: 'How do I book an urgent repair?',
      answer:
          'From the "Property & Asset Command Center" on your dashboard, you can use the on-demand booking feature to access our curated network of pre-vetted handymen for immediate assistance.',
    ),
    FaqModel(
      question: 'How are salaries for domestic staff handled?',
      answer:
          'The app features an integrated, cashless salary payment system that automates monthly payments to your staff and generates digital payslips for your records, ensuring transparency and convenience.',
    ),
  ];

  List<FaqModel> get faqs => _faqList;

  Future<String?> submitSupportQuestion(String question) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return "You must be logged in to submit a question.";
    }
    if (question.isEmpty) {
      return "Question cannot be empty.";
    }

    try {
      SupportTicketModel newTicket = SupportTicketModel(
        userId: currentUser.uid,
        question: question,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('support_tickets').add(newTicket.toMap());
      
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }
}