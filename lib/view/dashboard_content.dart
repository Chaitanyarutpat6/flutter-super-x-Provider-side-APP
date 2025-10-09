import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/model/job_model.dart';
import 'package:service_provider_side/providers/job_provider.dart';
import 'package:service_provider_side/view/job_request_detail_page.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the UI in a Consumer to listen for changes from JobProvider
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummarySection(context, jobProvider),
              const SizedBox(height: 24),
              _buildScheduleSection(context, jobProvider),
              const SizedBox(height: 24),
              _buildOpportunitiesSection(context, jobProvider),
            ],
          ),
        );
      },
    );
  }

  // --- All helper methods are now stateless and don't need to be in a State class ---

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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, JobProvider jobProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Provider!',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Here\'s a summary of your day.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: StreamBuilder<double>(
                stream: jobProvider.todaysEarningsStream,
                builder: (context, snapshot) {
                  final earnings = snapshot.data ?? 0.0;
                  return _buildGlassCard(
                    child: _buildSummaryItem(
                      'Today\'s Earnings',
                      '₹${earnings.toStringAsFixed(0)}',
                      Colors.greenAccent,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StreamBuilder<List<JobModel>>(
                stream: jobProvider.scheduledJobsStream,
                builder: (context, snapshot) {
                  final jobCount = snapshot.data?.length ?? 0;
                  return _buildGlassCard(
                    child: _buildSummaryItem(
                      'Upcoming Jobs',
                      jobCount.toString(),
                      const Color(0xFF29B6F6),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String title, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(BuildContext context, JobProvider jobProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('At-a-Glance Schedule'),
        StreamBuilder<List<JobModel>>(
          stream: jobProvider.scheduledJobsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildGlassCard(
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildGlassCard(
                child: const Text(
                  'No upcoming jobs on your schedule.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
            final scheduledJobs = snapshot.data!;
            return _buildGlassCard(
              child: Column(
                children:
                    scheduledJobs.map((job) {
                      final time = TimeOfDay.fromDateTime(
                        job.postedDate,
                      ).format(context);
                      final date = DateFormat.yMMMd().format(job.postedDate);
                      return _buildScheduleItem(time, job.title, date);
                    }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScheduleItem(String time, String title, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$date - $time',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunitiesSection(
    BuildContext context,
    JobProvider jobProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('New Opportunities'),
        StreamBuilder<List<JobModel>>(
          stream: jobProvider.newJobsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (snapshot.hasError) {
              return _buildGlassCard(
                child: const Text(
                  'Error loading jobs.',
                  style: TextStyle(color: Colors.redAccent),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildGlassCard(
                child: const Text(
                  'No new job opportunities at the moment.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
            final jobs = snapshot.data!;
            return ListView.builder(
              itemCount: jobs.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return _buildOpportunityItem(context: context, job: job);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildOpportunityItem({
    required BuildContext context,
    required JobModel job,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JobRequestDetailPage(job: job),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.0),
        child: _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${job.payout.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:service_provider_side/model/job_model.dart';
// import 'package:service_provider_side/providers/job_provider.dart';
// import 'package:service_provider_side/view/job_request_detail_page.dart';

// class DashboardContent extends StatelessWidget {
//   const DashboardContent({super.key});

//   // --- UI Colors ---
//   static const Color primaryColor = Color(0xFF1A237E);
//   static const Color accentColor = Color(0xFF29B6F6);

//   @override
//   Widget build(BuildContext context) {
//     // We get the provider once here, but set listen to false because the StreamBuilders will handle listening.
//     final jobProvider = Provider.of<JobProvider>(context, listen: false);

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSummarySection(context, jobProvider), // Pass provider
//           const SizedBox(height: 24),
//           _buildScheduleSection(context, jobProvider),
//           const SizedBox(height: 24),
//           _buildOpportunitiesSection(context, jobProvider),
//         ],
//       ),
//     );
//   }

//   // --- Reusable Glassmorphism Card ---
//   Widget _buildGlassCard({required Widget child}) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20.0),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//         child: Container(
//           padding: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(20.0),
//             border: Border.all(color: Colors.white.withOpacity(0.3)),
//           ),
//           child: Material(type: MaterialType.transparency, child: child),
//         ),
//       ),
//     );
//   }

//   // --- Section Header ---
//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   // --- WIDGET BUILDERS FOR SECTIONS ---

//   // --- THIS IS THE UPDATED SUMMARY SECTION ---
//   Widget _buildSummarySection(BuildContext context, JobProvider jobProvider) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Hello, Provider!',
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'Here\'s a summary of your day.',
//                 style: TextStyle(fontSize: 16, color: Colors.white70),
//               ),
//             ],
//           ),
//         ),
//         Row(
//           children: [
//             // --- Today's Earnings Card (Now Dynamic) ---
//             Expanded(
//               child: StreamBuilder<double>(
//                 stream: jobProvider.todaysEarningsStream,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     print("!!! EARNINGS STREAM ERROR: ${snapshot.error}");
//                   }
//                   final earnings = snapshot.data ?? 0.0;
//                   return _buildGlassCard(
//                     child: _buildSummaryItem(
//                       'Today\'s Earnings',
//                       '₹${earnings.toStringAsFixed(0)}',
//                       Colors.greenAccent,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(width: 16),
//             // --- Upcoming Jobs Card (Now Dynamic) ---
//             Expanded(
//               child: StreamBuilder<List<JobModel>>(
//                 stream: jobProvider.scheduledJobsStream,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     print("!!! EARNINGS STREAM ERROR: ${snapshot.error}");
//                   }
//                   final jobCount = snapshot.data?.length ?? 0;
//                   return _buildGlassCard(
//                     child: _buildSummaryItem(
//                       'Upcoming Jobs',
//                       jobCount.toString(),
//                       accentColor,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildSummaryItem(String title, String value, Color valueColor) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(color: Colors.white70, fontSize: 14),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: valueColor,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildScheduleSection(BuildContext context, JobProvider jobProvider) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader('At-a-Glance Schedule'),
//         StreamBuilder<List<JobModel>>(
//           stream: jobProvider.scheduledJobsStream,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return _buildGlassCard(
//                 child: const Center(
//                   child: CircularProgressIndicator(color: Colors.white),
//                 ),
//               );
//             }
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return _buildGlassCard(
//                 child: const Text(
//                   'No upcoming jobs on your schedule.',
//                   style: TextStyle(color: Colors.white70),
//                 ),
//               );
//             }
//             final scheduledJobs = snapshot.data!;
//             return _buildGlassCard(
//               child: Column(
//                 children:
//                     scheduledJobs.map((job) {
//                       final time = TimeOfDay.fromDateTime(
//                         job.postedDate,
//                       ).format(context);
//                       String formattedDate = DateFormat('yyyy-MM-dd').format(job.postedDate);
//                       return _buildScheduleItem(time, job.title, formattedDate);
//                     }).toList(),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildScheduleItem(String time, String title, String date) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           const Icon(Icons.timer_outlined, color: Colors.white, size: 28),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   time,
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   date,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOpportunitiesSection(
//     BuildContext context,
//     JobProvider jobProvider,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader('New Opportunities'),
//         StreamBuilder<List<JobModel>>(
//           stream: jobProvider.newJobsStream,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               );
//             }
//             if (snapshot.hasError) {
//               return _buildGlassCard(
//                 child: const Text(
//                   'Error loading jobs.',
//                   style: TextStyle(color: Colors.redAccent),
//                 ),
//               );
//             }
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return _buildGlassCard(
//                 child: const Text(
//                   'No new job opportunities at the moment.',
//                   style: TextStyle(color: Colors.white70),
//                 ),
//               );
//             }
//             final jobs = snapshot.data!;
//             return ListView.builder(
//               itemCount: jobs.length,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemBuilder: (context, index) {
//                 final job = jobs[index];
//                 return _buildOpportunityItem(context: context, job: job);
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildOpportunityItem({
//     required BuildContext context,
//     required JobModel job,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: InkWell(
//         onTap: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => JobRequestDetailPage(job: job),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(20.0),
//         child: _buildGlassCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 job.title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.location_on_outlined,
//                     color: Colors.white70,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     job.location,
//                     style: const TextStyle(color: Colors.white70, fontSize: 14),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     '₹${job.payout.toStringAsFixed(0)}',
//                     style: const TextStyle(
//                       color: Colors.greenAccent,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const Icon(
//                     Icons.arrow_forward_ios,
//                     color: Colors.white70,
//                     size: 16,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
