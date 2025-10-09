import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:service_provider_side/model/job_model.dart'; // Import your JobModel
import 'package:service_provider_side/view/job_completion_form_page.dart'; // Import the completion page

class ActiveJobPage extends StatefulWidget {
  final JobModel job; // JobModel to display
  const ActiveJobPage({super.key, required this.job});

  @override
  State<ActiveJobPage> createState() => _ActiveJobPageState();
}

class _ActiveJobPageState extends State<ActiveJobPage> {
  // UI Colors (can be moved to a constants file)
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF29B6F6);

  bool _isJobStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Active Job', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background gradient or image (adjust as per your main app)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: kToolbarHeight + 20), // Space for app bar
                  _buildJobDetailsCard(),
                  const SizedBox(height: 24),
                  _buildActionsSection(context),
                  const SizedBox(height: 24),
                  _buildCustomerContactCard(),
                ],
              ),
            ),
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

  Widget _buildJobDetailsCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.job.title,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.calendar_today, DateFormat('EEE, MMM d, yyyy').format(widget.job.postedDate)),
          _buildDetailRow(Icons.access_time, DateFormat('hh:mm a').format(widget.job.postedDate)),
          _buildDetailRow(Icons.location_on, widget.job.location),
          _buildDetailRow(Icons.attach_money, '₹${widget.job.payout.toStringAsFixed(0)}'),
          const SizedBox(height: 16),
          Text(
            widget.job.description ?? 'No description provided.',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      children: [
        if (!_isJobStarted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isJobStarted = true;
                });
                // TODO: Implement actual "start job" logic (e.g., update job status, start timer)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job Started!')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Job', style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        if (_isJobStarted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to JobCompletionReportPage, passing the job details
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => JobCompletionFormPage(job: widget.job),
                ));
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('End Job & Report', style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomerContactCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Details',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildContactRow(Icons.person, widget.job.customerName ?? 'N/A', () {}), // Assuming customerName in JobModel
          _buildContactRow(Icons.phone, widget.job.customerPhone ?? 'N/A', () {
            // TODO: Implement phone call functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Calling ${widget.job.customerPhone}')),
            );
          }),
          _buildContactRow(Icons.message, 'Send Message', () {
            // TODO: Implement message functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening messaging app')),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
            if (text != 'N/A' && (icon == Icons.phone || icon == Icons.message))
              const Spacer(),
            if (text != 'N/A' && (icon == Icons.phone || icon == Icons.message))
              Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}



// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:service_provider_side/view/chat_page.dart';
// import 'job_completion_form_page.dart';

// class ActiveJobPage extends StatefulWidget {
//   const ActiveJobPage({super.key});

//   @override
//   State<ActiveJobPage> createState() => _ActiveJobPageState();
// }

// class _ActiveJobPageState extends State<ActiveJobPage> {
//   int _currentStep = 0;

//   final List<String> _steps = [
//     'Start Travel',
//     'Arrived at Location',
//     'Start Work',
//     'Complete Work',
//   ];

//   void _nextStep() {
//     if (_currentStep < _steps.length - 1) {
//       setState(() {
//         _currentStep++;
//       });
//       // You can add logic here to update the job status in Firestore
//     } else {
//       Navigator.of(context).push(MaterialPageRoute(
//       builder: (context) => const JobCompletionFormPage(),
//     ));
//       // Logic for when the final step ("Complete Work") is pressed
//       print('Job Completed! Navigating to Job Completion Report.');
//       // TODO: Navigate to the Job Completion Report Form (P8)
//     }
//   }

//   // --- UI Colors ---
//   static const Color primaryColor = Color(0xFF1A237E);
//   static const Color accentColor = Color(0xFF29B6F6);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
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
//               _buildCustomAppBar(context),
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       _buildJobInfoCard(),
//                       const SizedBox(height: 24),
//                       _buildStatusStepper(),
//                     ],
//                   ),
//                 ),
//               ),
//               _buildActionButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // --- Widget Builders ---

//   Widget _buildCustomAppBar(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // IconButton(
//           //   icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
//           //   onPressed: () => Navigator.of(context).pop(),
//           // ),
//           const Text(
//             'Active Job',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(
//               Icons.chat_bubble_outline,
//               color: Colors.white,
//               size: 26,
//             ),
//             tooltip: 'Chat with Manager',
//             onPressed: () {
//               // TODO: Navigate to Chat with Manager page (P7)
//               Navigator.of(
//                 context,
//               ).push(MaterialPageRoute(builder: (context) => const ChatPage()));
//             },
//           ),
//         ],
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
//           child: child,
//         ),
//       ),
//     );
//   }

//   Widget _buildJobInfoCard() {
//     return _buildGlassCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Plumbing Fix at Koregaon Park',
//             style: TextStyle(
//               fontSize: 22,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Client: Anjali Sharma',
//             style: TextStyle(fontSize: 16, color: Colors.white70),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               const Icon(
//                 Icons.location_on_outlined,
//                 color: Colors.white70,
//                 size: 16,
//               ),
//               const SizedBox(width: 8),
//               const Expanded(
//                 child: Text(
//                   'A-123, Rosewood Society, Koregaon Park',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//           const Divider(color: Colors.white30, height: 32),
//           Center(
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 /* Add map navigation logic */
//               },
//               icon: const Icon(Icons.navigation_outlined, color: primaryColor),
//               label: const Text('GET DIRECTIONS'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 foregroundColor: primaryColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusStepper() {
//     return _buildGlassCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Job Progress',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...List.generate(_steps.length, (index) {
//             return _buildStep(
//               title: _steps[index],
//               isActive: index <= _currentStep,
//               isFirst: index == 0,
//               isLast: index == _steps.length - 1,
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildStep({
//     required String title,
//     required bool isActive,
//     bool isFirst = false,
//     bool isLast = false,
//   }) {
//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           SizedBox(
//             width: 32,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (!isFirst)
//                   Expanded(
//                     child: Container(
//                       width: 2,
//                       color: isActive ? Colors.white : Colors.white30,
//                     ),
//                   ),
//                 Icon(
//                   isActive ? Icons.check_circle : Icons.radio_button_unchecked,
//                   color: isActive ? Colors.greenAccent : Colors.white,
//                   size: 28,
//                 ),
//                 if (!isLast)
//                   Expanded(
//                     child: Container(
//                       width: 2,
//                       color: isActive ? Colors.white : Colors.white30,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20.0),
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: isActive ? Colors.white : Colors.white70,
//                   fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: ElevatedButton(
//         onPressed: _nextStep,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.white,
//           foregroundColor: primaryColor,
//           minimumSize: const Size(double.infinity, 60),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//         ),
//         child: Text(
//           _steps[_currentStep].toUpperCase(),
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1.2,
//           ),
//         ),
//       ),
//     );
//   }
// }
