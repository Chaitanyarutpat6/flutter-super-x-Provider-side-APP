import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/model/job_model.dart';
import 'package:service_provider_side/model/provider_model.dart'; // Import ProviderModel
import 'package:service_provider_side/providers/job_provider.dart';
import 'package:service_provider_side/providers/profile_provider.dart'; // Import ProfileProvider
import 'package:service_provider_side/view/payout_history_page.dart';
import 'package:service_provider_side/view/ratings_page.dart';

class EarningsDashboardPage extends StatelessWidget {
  const EarningsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // This page uses multiple providers, so a Consumer is a good choice
    return Consumer2<JobProvider, ProfileProvider>(
      builder: (context, jobProvider, profileProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummarySection(context, jobProvider, profileProvider),
              const SizedBox(height: 24),
              _buildPerformanceMetrics(
                context,
                profileProvider,
              ), // Now uses ProfileProvider
              const SizedBox(height: 24),
              _buildRecentTransactions(context, jobProvider),
            ],
          ),
        );
      },
    );
  }

  // --- Reusable Glassmorphism Card ---
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

  // --- Widget Builders for Sections (Now Dynamic) ---

  // Widget _buildSummarySection(BuildContext context, JobProvider jobProvider) {
  //   // This section is now also dynamic
  //   return StreamBuilder<double>(
  //     stream: jobProvider.todaysEarningsStream,
  //     builder: (context, snapshot) {
  //       final earnings = snapshot.data ?? 0.0;
  //       return _buildGlassCard(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               'This Month\'s Earnings',
  //               style: TextStyle(color: Colors.white70, fontSize: 16),
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               '₹${earnings.toStringAsFixed(0)}',
  //               style: const TextStyle(
  //                 color: Colors.greenAccent,
  //                 fontSize: 36,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             // This part is still using static data as an example
  //             const Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text('Pending', style: TextStyle(color: Colors.white70)),
  //                     SizedBox(height: 4),
  //                     Text(
  //                       '₹2,500',
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Next Payout',
  //                       style: TextStyle(color: Colors.white70),
  //                     ),
  //                     SizedBox(height: 4),
  //                     Text(
  //                       'Oct 15, 2025',
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildSummarySection(
    BuildContext context,
    JobProvider jobProvider,
    ProfileProvider profileProvider,
  ) {
    return StreamBuilder<double>(
      stream:
          jobProvider
              .todaysEarningsStream, // This can be changed to a monthly stream later
      builder: (context, earningsSnapshot) {
        final earnings = earningsSnapshot.data ?? 0.0;
        return _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This Month\'s Earnings',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${earnings.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // --- THIS ROW IS NOW DYNAMIC ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pending Amount Column
                  StreamBuilder<double>(
                    stream: profileProvider.pendingPayoutStream,
                    builder: (context, pendingSnapshot) {
                      final pendingAmount = pendingSnapshot.data ?? 0.0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pending',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${pendingAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  // Next Payout Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Payout',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profileProvider.nextPayoutDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- THIS IS THE UPDATED PERFORMANCE METRICS SECTION ---
  Widget _buildPerformanceMetrics(
    BuildContext context,
    ProfileProvider profileProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Performance Metrics'),
        // This StreamBuilder fetches the provider's profile to get the average rating
        StreamBuilder<ProviderModel?>(
          stream: profileProvider.providerStream,
          builder: (context, snapshot) {
            // Use default values while loading or if data is null
            final avgRating = snapshot.data?.averageRating ?? 0.0;

            return Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RatingsPage(),
                          ),
                        ),
                    borderRadius: BorderRadius.circular(20.0),
                    child: _buildGlassCard(
                      child: _buildMetricItem(
                        'Avg. Rating',
                        '${avgRating.toStringAsFixed(1)} ★', // Display dynamic rating
                        const Color(0xFF29B6F6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Completion rate can be made dynamic with another stream
                Expanded(
                  child: _buildGlassCard(
                    child: _buildMetricItem(
                      'Completion Rate',
                      '98%',
                      Colors.greenAccent,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricItem(String title, String value, Color valueColor) {
    return Column(
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

  Widget _buildRecentTransactions(
    BuildContext context,
    JobProvider jobProvider,
  ) {
    // This section remains the same
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Recent Payouts'),
        InkWell(
          onTap:
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PayoutHistoryPage(),
                ),
              ),
          borderRadius: BorderRadius.circular(20.0),
          child: _buildGlassCard(
            child: StreamBuilder<List<JobModel>>(
              stream: jobProvider.completedJobsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    'No recent payouts.',
                    style: TextStyle(color: Colors.white70),
                  );
                }
                final recentJobs = snapshot.data!.take(2).toList();
                return Column(
                  children: [
                    for (var job in recentJobs)
                      _buildTransactionItem(
                        job.title,
                        'Payout',
                        '₹${job.payout.toStringAsFixed(0)}',
                      ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String date, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:service_provider_side/model/job_model.dart';
// import 'package:service_provider_side/providers/job_provider.dart';
// import 'package:service_provider_side/view/payout_history_page.dart';
// import 'package:service_provider_side/view/ratings_page.dart';

// class EarningsDashboardPage extends StatelessWidget {
//   const EarningsDashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // This page is a content page for the main PageView.
//     // We use a Consumer to get the JobProvider and listen for changes.
//     return Consumer<JobProvider>(
//       builder: (context, jobProvider, child) {
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildSummarySection(context, jobProvider),
//               const SizedBox(height: 24),
//               _buildPerformanceMetrics(context, jobProvider),
//               const SizedBox(height: 24),
//               _buildRecentTransactions(context, jobProvider),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // --- Reusable Glassmorphism Card ---
//   Widget _buildGlassCard({required Widget child}) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20.0),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//         child: Container(
//           padding: const EdgeInsets.all(20.0),
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
//         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//       ),
//     );
//   }

//   // --- Widget Builders for Sections (Now Dynamic) ---

//   Widget _buildSummarySection(BuildContext context, JobProvider jobProvider) {
//     return StreamBuilder<double>(
//       stream: jobProvider.todaysEarningsStream, // Assuming you add a monthly stream later
//       builder: (context, snapshot) {
//         final earnings = snapshot.data ?? 0.0;
//         return _buildGlassCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('This Month\'s Earnings', style: TextStyle(color: Colors.white70, fontSize: 16)),
//               const SizedBox(height: 8),
//               Text('₹${earnings.toStringAsFixed(0)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 36, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 16),
//               const Row( // These can be made dynamic with more provider streams
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Pending', style: TextStyle(color: Colors.white70)),
//                       SizedBox(height: 4),
//                       Text('₹2,500', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Next Payout', style: TextStyle(color: Colors.white70)),
//                       SizedBox(height: 4),
//                       Text('Oct 15, 2025', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPerformanceMetrics(BuildContext context, JobProvider jobProvider) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader('Performance Metrics'),
//         Row(
//           children: [
//             Expanded(
//               child: InkWell(
//                 onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RatingsPage())),
//                 borderRadius: BorderRadius.circular(20.0),
//                 child: _buildGlassCard(child: _buildMetricItem('Avg. Rating', '4.9 ★', const Color(0xFF29B6F6))),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(child: _buildGlassCard(child: _buildMetricItem('Completion Rate', '98%', Colors.greenAccent))),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildMetricItem(String title, String value, Color valueColor) {
//     return Column(
//       children: [
//         Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
//         const SizedBox(height: 8),
//         Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: valueColor)),
//       ],
//     );
//   }

//   Widget _buildRecentTransactions(BuildContext context, JobProvider jobProvider) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader('Recent Payouts'),
//         InkWell(
//           onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PayoutHistoryPage())),
//           borderRadius: BorderRadius.circular(20.0),
//           child: _buildGlassCard(
//             child: StreamBuilder<List<JobModel>>( // Using completedJobsStream for recent payouts
//               stream: jobProvider.completedJobsStream,
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Text('No recent payouts.', style: TextStyle(color: Colors.white70));
//                 }
//                 final recentJobs = snapshot.data!.take(2).toList(); // Take the 2 most recent
//                 return Column(
//                   children: [
//                     for (var job in recentJobs)
//                       _buildTransactionItem(job.title, 'Payout', '₹${job.payout.toStringAsFixed(0)}'),
//                     const SizedBox(height: 8),
//                     const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text('View All', style: TextStyle(color: Colors.white70)),
//                         SizedBox(width: 4),
//                         Icon(Icons.arrow_forward, color: Colors.white70, size: 16),
//                       ],
//                     )
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTransactionItem(String title, String date, String amount) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
//                 const SizedBox(height: 4),
//                 Text(date, style: const TextStyle(color: Colors.white70, fontSize: 14)),
//               ],
//             ),
//           ),
//           Text(amount, style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'payout_history_page.dart';
// import 'ratings_page.dart'; // Import the new ratings page

// class EarningsDashboardPage extends StatelessWidget {
//   const EarningsDashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSummarySection(),
//           const SizedBox(height: 24),
//           // Use the new, corrected widget for performance metrics
//           const PerformanceMetricsSection(),
//           const SizedBox(height: 24),
//           const RecentTransactionsCard(),
//         ],
//       ),
//     );
//   }

//   // --- HELPER WIDGETS FOR THE MAIN PAGE ---

//   Widget _buildGlassCard({required Widget child}) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20.0),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//         child: Container(
//           padding: const EdgeInsets.all(20.0),
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

//   Widget _buildSummarySection() {
//     return _buildGlassCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'This Month\'s Earnings',
//             style: TextStyle(color: Colors.white70, fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             '₹12,500',
//             style: TextStyle(
//               color: Colors.greenAccent,
//               fontSize: 36,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Pending',
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     '₹2,500',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Next Payout',
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     'Oct 15, 2025',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // --- NEW WIDGET FOR PERFORMANCE METRICS TO FIX THE CONTEXT ERROR ---
// class PerformanceMetricsSection extends StatelessWidget {
//   const PerformanceMetricsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader('Performance Metrics'),
//         Row(
//           children: [
//             Expanded(
//               child: InkWell(
//                 onTap: () {
//                   // This context is valid and can find the Navigator
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => const RatingsPage(),
//                     ),
//                   );
//                 },
//                 borderRadius: BorderRadius.circular(20.0),
//                 child: _buildGlassCard(
//                   child: _buildMetricItem(
//                     'Avg. Rating',
//                     '4.9 ★',
//                     const Color(0xFF29B6F6),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: _buildGlassCard(
//                 child: _buildMetricItem(
//                   'Completion Rate',
//                   '98%',
//                   Colors.greenAccent,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // --- HELPER WIDGETS FOR THIS SECTION ---

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

//   Widget _buildGlassCard({required Widget child}) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20.0),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//         child: Container(
//           padding: const EdgeInsets.all(20.0),
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

//   Widget _buildMetricItem(String title, String value, Color valueColor) {
//     return Column(
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
// }

// // --- WIDGET FOR RECENT TRANSACTIONS (ALREADY CORRECT) ---
// class RecentTransactionsCard extends StatelessWidget {
//   const RecentTransactionsCard({super.key});
//   // ... (The code for this widget remains the same as before)
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
//           child: Text(
//             'Recent Payouts',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         InkWell(
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => const PayoutHistoryPage(),
//               ),
//             );
//           },
//           borderRadius: BorderRadius.circular(20.0),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20.0),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//               child: Container(
//                 padding: const EdgeInsets.all(20.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20.0),
//                   border: Border.all(color: Colors.white.withOpacity(0.3)),
//                 ),
//                 child: Column(
//                   children: [
//                     _buildTransactionItem(
//                       'Payout #P5821',
//                       'October 1, 2025',
//                       '₹5,500',
//                     ),
//                     const Divider(color: Colors.white30, height: 24),
//                     _buildTransactionItem(
//                       'Payout #P5799',
//                       'September 25, 2025',
//                       '₹4,800',
//                     ),
//                     const SizedBox(height: 8),
//                     const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'View All',
//                           style: TextStyle(color: Colors.white70),
//                         ),
//                         SizedBox(width: 4),
//                         Icon(
//                           Icons.arrow_forward,
//                           color: Colors.white70,
//                           size: 16,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTransactionItem(String title, String date, String amount) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               date,
//               style: const TextStyle(color: Colors.white70, fontSize: 14),
//             ),
//           ],
//         ),
//         Text(
//           amount,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
// }
