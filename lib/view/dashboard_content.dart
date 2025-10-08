import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/model/job_model.dart';
import 'package:service_provider_side/providers/job_provider.dart';
import 'package:service_provider_side/view/job_request_detail_page.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  // --- UI Colors ---
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF29B6F6);

  @override
  Widget build(BuildContext context) {
    // This widget is just the scrollable content. No Scaffold.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(),
          const SizedBox(height: 24),
          _buildOpportunitiesSection(),
        ],
      ),
    );
  }

  // --- Reusable Glassmorphism Card ---
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

  // --- Section Header ---
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

  // --- Widget Builders for Sections ---

  Widget _buildSummarySection() {
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
              child: _buildGlassCard(
                child: _buildSummaryItem(
                  'Today\'s Earnings',
                  '₹1,500',
                  Colors.greenAccent,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGlassCard(
                child: _buildSummaryItem('Upcoming Jobs', '3', accentColor),
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

  Widget _buildOpportunitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('New Opportunities'),
        // --- THIS IS THE NEW DYNAMIC PART ---
        StreamBuilder<List<JobModel>>(
          stream:
              JobProvider()
                  .newJobsStream, // Listen to the stream from JobProvider
          builder: (context, snapshot) {
            // Case 1: Waiting for data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Case 2: Error fetching data
            if (snapshot.hasError) {
              return _buildGlassCard(
                child: Text(
                  'Error loading jobs.',
                  style: TextStyle(color: Colors.redAccent[100]),
                ),
              );
            }
            // Case 3: No data available
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildGlassCard(
                child: const Text(
                  'No new job opportunities at the moment.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            // Case 4: Data is available, build the list
            final jobs = snapshot.data!;
            return ListView.builder(
              itemCount: jobs.length,
              shrinkWrap: true, // Important for ListView inside a Column
              physics:
                  const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
              itemBuilder: (context, index) {
                final job = jobs[index];
                return _buildOpportunityItem(
                  context: context,
                  title: job.title,
                  location: job.location,
                  payment: '₹${job.payout.toStringAsFixed(0)}',
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildOpportunityItem({
    required BuildContext context,
    required String title,
    required String location,
    required String payment,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const JobRequestDetailPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.0),
        child: _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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
                    location,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    payment,
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'job_request_detail_page.dart';
// import 'my_schedule_page.dart';

// class DashboardContent extends StatefulWidget {
//   const DashboardContent({super.key});

//   @override
//   State<DashboardContent> createState() => _MainDashboardPageStates();
// }

// class _MainDashboardPageStates extends State<DashboardContent> {
//   int _currentIndex = 0;

//   // --- UI Colors ---
//   static const Color primaryColor = Color(0xFF1A237E); // Indigo
//   static const Color accentColor = Color(0xFF29B6F6); // Light Blue

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // --- Gradient Background ---
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [primaryColor, accentColor],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // _buildCustomAppBar(),
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildSummarySection(),
//                       const SizedBox(height: 24),
//                       _buildScheduleSection(),
//                       const SizedBox(height: 24),
//                       _buildOpportunitiesSection(),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // --- Custom App Bar ---
//   Widget _buildCustomAppBar() {
//     return const Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Dashboard',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Row(
//             children: [
//               Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
//               SizedBox(width: 16),
//               Icon(
//                 Icons.account_circle_outlined,
//                 color: Colors.white,
//                 size: 28,
//               ),
//             ],
//           ),
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
//           child: child,
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

//   // --- Dashboard Sections ---

//   Widget _buildSummarySection() {
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
//             Expanded(
//               child: _buildGlassCard(
//                 child: _buildSummaryItem(
//                   'Today\'s Earnings',
//                   '₹1,500',
//                   Colors.greenAccent,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: _buildGlassCard(
//                 child: _buildSummaryItem('Upcoming Jobs', '3', accentColor),
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

//   Widget _buildScheduleSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader('At-a-Glance Schedule'),
//         _buildGlassCard(
//           child: Column(
//             children: [
//               _buildScheduleItem(
//                 '10:00 AM - Today',
//                 'Plumbing Fix at Koregaon Park',
//               ),
//               const Divider(color: Colors.white30, height: 24),
//               _buildScheduleItem('02:30 PM - Today', 'AC Servicing at Baner'),
//               const Divider(color: Colors.white30, height: 24),
//               _buildScheduleItem(
//                 '09:00 AM - Tomorrow',
//                 'Electrical Wiring Check',
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildScheduleItem(String time, String title) {
//     return Row(
//       children: [
//         const Icon(Icons.timer_outlined, color: Colors.white, size: 28),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 time,
//                 style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOpportunitiesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader('New Opportunities'),
//         _buildGlassCard(
//           child: Column(
//             children: [
//               _buildOpportunityItem(
//                 'Urgent: Leaky Faucet Repair',
//                 'Hinjewadi Phase 1',
//                 '₹500 - ₹700',
//               ),
//               const Divider(color: Colors.white30, height: 24),
//               _buildOpportunityItem(
//                 'Full Home Wiring Installation',
//                 'Viman Nagar',
//                 '₹10,000+ (Quote)',
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // In lib/main_dashboard_page.dart

//   Widget _buildOpportunityItem(String title, String location, String payment) {
//     // Wrap the card's content in an InkWell to make it tappable
//     return InkWell(
//       onTap: () {
//         Navigator.of(context).push(
//           MaterialPageRoute(builder: (context) => const JobRequestDetailPage()),
//         );
//         print('Navigating to Job Detail for: $title');
//         // TODO: Replace with actual navigation to the Job Request Detail page
//         // Navigator.of(context).push(MaterialPageRoute(
//         //   builder: (context) => JobRequestDetailPage(jobId: '...'),
//         // ));
//       },
//       child: _buildGlassCard(
//         // Re-using your existing beautiful card
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(
//                   Icons.location_on_outlined,
//                   color: Colors.white70,
//                   size: 16,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   location,
//                   style: const TextStyle(color: Colors.white70, fontSize: 14),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   payment,
//                   style: const TextStyle(
//                     color: Colors.greenAccent,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 // The button is now a visual indicator, the whole card is tappable
//                 const Icon(
//                   Icons.arrow_forward_ios,
//                   color: Colors.white70,
//                   size: 16,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
