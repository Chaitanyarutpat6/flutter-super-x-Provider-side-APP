import 'dart:ui';
import 'package:flutter/material.dart';
import 'completed_job_detail_page.dart'; // Import the new page

class JobHistoryPage extends StatelessWidget {
  const JobHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a content page, so it doesn't need its own Scaffold.
    return const Column(
      children: [
        Expanded(
          // Extract the list into its own widget to solve the context error
          child: JobHistoryList(),
        ),
      ],
    );
  }
}

// NEW WIDGET to handle the list and navigation
class JobHistoryList extends StatelessWidget {
  const JobHistoryList({super.key});

  final List<Map<String, String>> completedJobs = const [
    {
      'title': 'Plumbing Fix at Koregaon Park',
      'date': 'October 7, 2025',
      'payout': '₹650',
    },
    {
      'title': 'AC Servicing at Baner',
      'date': 'October 7, 2025',
      'payout': '₹850',
    },
    {
      'title': 'Electrical Wiring Check',
      'date': 'October 6, 2025',
      'payout': '₹1200',
    },
    {
      'title': 'Geyser Installation',
      'date': 'October 5, 2025',
      'payout': '₹700',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: completedJobs.length,
      itemBuilder: (context, index) {
        final job = completedJobs[index];
        return _buildHistoryCard(
          context: context, // Pass the context
          title: job['title']!,
          date: job['date']!,
          payout: job['payout']!,
        );
      },
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Material(type: MaterialType.transparency, child: child),
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required BuildContext context,
    required String title,
    required String date,
    required String payout,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          // This context is now valid for navigation
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CompletedJobDetailPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.0),
        child: _buildGlassCard(
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                payout,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
