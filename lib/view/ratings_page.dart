import 'dart:ui';
import 'package:flutter/material.dart';

class RatingsPage extends StatelessWidget {
  const RatingsPage({super.key});

  // Dummy data for feedback
  final List<Map<String, dynamic>> feedbackList = const [
    {'rating': 5.0, 'comment': 'Exceptional work, was very professional and fixed the issue quickly.', 'date': 'October 6, 2025'},
    {'rating': 5.0, 'comment': 'Arrived on time and was very polite. Highly recommended.', 'date': 'October 4, 2025'},
    {'rating': 4.0, 'comment': 'Good service, though it took a little longer than expected.', 'date': 'October 1, 2025'},
  ];

  // --- UI Colors ---
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF29B6F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildOverallRatingCard(),
                      const SizedBox(height: 24),
                      _buildFeedbackList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'My Ratings & Feedback',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildOverallRatingCard() {
    return _buildGlassCard(
      child: Column(
        children: [
          const Text('Overall Rating', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('4.9', style: TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Icon(Icons.star, color: Colors.yellow[600], size: 32),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Based on 58 completed jobs', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFeedbackList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            'Recent Feedback',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        ...feedbackList.map((feedback) {
          return _buildFeedbackCard(
            rating: feedback['rating'],
            comment: feedback['comment'],
            date: feedback['date'],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFeedbackCard({required double rating, required String comment, required String date}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStarRating(rating),
                Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text('"$comment"', style: const TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.yellow[600],
          size: 20,
        );
      }),
    );
  }
}