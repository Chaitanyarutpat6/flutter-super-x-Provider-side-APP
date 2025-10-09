import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/model/job_model.dart';
import 'package:service_provider_side/providers/job_provider.dart';
import 'completed_job_detail_page.dart';

class JobHistoryPage extends StatelessWidget {
  const JobHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a content page, so it doesn't need its own Scaffold.
    return const JobHistoryList();
  }
}

// NEW WIDGET to handle the list and navigation
class JobHistoryList extends StatelessWidget {
  const JobHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the provider
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    return StreamBuilder<List<JobModel>>(
      stream: jobProvider.completedJobsStream, // Listen to the new stream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (snapshot.hasError) {
          print("!!! JOB HISTORY STREAM ERROR: ${snapshot.error}");
          return const Center(
            child: Text(
              'Error loading job history.',
              style: TextStyle(color: Colors.redAccent),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading job history.',
              style: TextStyle(color: Colors.redAccent),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: _buildGlassCard(
              child: const Text(
                'No completed jobs found.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        final jobs = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return _buildTappableHistoryCard(context: context, job: job);
          },
        );
      },
    );
  }

  Widget _buildTappableHistoryCard({
    required BuildContext context,
    required JobModel job,
  }) {
    // Format the completion date for display
    final date =
        job.completionDate != null
            ? DateFormat.yMMMd().format(job.completionDate!)
            : 'N/A';
    log("$date");
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CompletedJobDetailPage(job: job),
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
                      job.title,
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
                '₹${job.payout.toStringAsFixed(0)}',
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
}
