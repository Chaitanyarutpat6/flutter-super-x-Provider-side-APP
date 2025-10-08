import 'dart:ui';
import 'package:flutter/material.dart';

class SupportCenterPage extends StatelessWidget {
  const SupportCenterPage({super.key});

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Frequently Asked Questions'),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildFaqTile('How do I update my bank account?'),
                            const Divider(color: Colors.white30),
                            _buildFaqTile('What is the commission rate?'),
                            const Divider(color: Colors.white30),
                            _buildFaqTile('How do I report an issue with a job?'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Contact Support'),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildContactTile(Icons.email_outlined, 'Email Support', 'support@priveconcierge.com'),
                            const Divider(color: Colors.white30),
                            _buildContactTile(Icons.phone_outlined, 'Call Support', '+91 99887 76655'),
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
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildFaqTile(String question) {
    return ListTile(
      title: Text(question, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
      onTap: () {},
    );
  }
  
  Widget _buildContactTile(IconData icon, String title, String subtitle) {
     return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      onTap: () {},
    );
  }
}