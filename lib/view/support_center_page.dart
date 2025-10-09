import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/model/faq_model.dart';
import 'package:service_provider_side/providers/support_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// class SupportCenterPage extends StatelessWidget {
//   const SupportCenterPage({super.key});

// // --- UI Colors ---
// static const Color primaryColor = Color(0xFF1A237E);
// static const Color accentColor = Color(0xFF29B6F6);

// // --- Function to launch URLs ---
// Future<void> _launchUrl(String url) async {
//   final Uri uri = Uri.parse(url);
//   if (!await launchUrl(uri)) {
//     // Could show a snackbar here if launching fails
//     throw 'Could not launch $url';
//   }
// }

// @override
// Widget build(BuildContext context) {
//   // Access the provider
//   final supportProvider = Provider.of<SupportProvider>(
//     context,
//     listen: false,
//   );
//   final faqs = supportProvider.faqs;

//   return Scaffold(
//     body: Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [primaryColor, accentColor],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: SafeArea(
//         child: Column(
//           children: [
//             _buildCustomAppBar(context),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildSectionHeader('Frequently Asked Questions'),
//                     _buildGlassCard(
//                       child: ListView.separated(
//                         itemCount: faqs.length,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         separatorBuilder:
//                             (context, index) =>
//                                 const Divider(color: Colors.white30),
//                         itemBuilder: (context, index) {
//                           return _buildFaqTile(faqs[index]);
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     _buildSectionHeader('Contact Support'),
//                     _buildGlassCard(
//                       child: Column(
//                         children: [
//                           _buildContactTile(
//                             Icons.email_outlined,
//                             'Email Support',
//                             'support@priveconcierge.com',
//                           ),
//                           const Divider(color: Colors.white30),
//                           _buildContactTile(
//                             Icons.phone_outlined,
//                             'Call Support',
//                             '+91 99887 76655',
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
class SupportCenterPage extends StatefulWidget {
  const SupportCenterPage({super.key});

  @override
  State<SupportCenterPage> createState() => _SupportCenterPageState();
}

class _SupportCenterPageState extends State<SupportCenterPage> {
  final _questionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF29B6F6);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _submitQuestion() async {
    setState(() => _isLoading = true);
    final supportProvider = Provider.of<SupportProvider>(
      context,
      listen: false,
    );

    String? result = await supportProvider.submitSupportQuestion(
      _questionController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == 'success') {
      _questionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your question has been submitted!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? 'An error occurred.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportProvider = Provider.of<SupportProvider>(
      context,
      listen: false,
    );
    final faqs = supportProvider.faqs;

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Frequently Asked Questions'),
                      _buildGlassCard(
                        child: ListView.separated(
                          itemCount: faqs.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder:
                              (context, index) =>
                                  const Divider(color: Colors.white30),
                          itemBuilder:
                              (context, index) => _buildFaqTile(faqs[index]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Ask a New Question'),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            TextField(
                              controller: _questionController,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Type your question here...',
                                hintStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _submitQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryColor,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: primaryColor,
                                      )
                                      : const Text(
                                        'SUBMIT QUESTION',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Contact Support'),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildContactTile(
                              Icons.email_outlined,
                              'Email Support',
                              'support@priveconcierge.com',
                            ),
                            const Divider(color: Colors.white30),
                            _buildContactTile(
                              Icons.phone_outlined,
                              'Call Support',
                              '+91 99887 76655',
                            ),
                          ],
                        ),
                      ),
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
            'Support Center',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: child,
            ),
          ),
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

  // --- UPDATED to use ExpansionTile ---
  Widget _buildFaqTile(FaqModel faq) {
    return ExpansionTile(
      title: Text(
        faq.question,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconColor: Colors.white70,
      collapsedIconColor: Colors.white,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          child: Text(
            faq.answer,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ),
      ],
    );
  }

  // --- UPDATED to be functional ---
  Widget _buildContactTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      onTap: () {
        if (title.contains('Email')) {
          _launchUrl('mailto:$subtitle');
        } else if (title.contains('Call')) {
          _launchUrl('tel:$subtitle');
        }
      },
    );
  }
}
