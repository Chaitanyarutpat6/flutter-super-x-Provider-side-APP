import 'dart:ui';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  // Dummy data for notifications
  final List<Map<String, dynamic>> notifications = const [
    {
      'icon': Icons.work_outline,
      'color': Colors.blue,
      'title': 'New Job Opportunity!',
      'subtitle': 'A new plumbing job is available in Koregaon Park.',
      'time': '5m ago'
    },
    {
      'icon': Icons.check_circle_outline,
      'color': Colors.green,
      'title': 'Job #J782 Completed',
      'subtitle': 'You have successfully completed the AC repair job.',
      'time': '2h ago'
    },
    {
      'icon': Icons.account_balance_wallet_outlined,
      'color': Colors.purple,
      'title': 'Payout Processed',
      'subtitle': 'A payout of ₹5,500 has been sent to your account.',
      'time': '1d ago'
    },
     {
      'icon': Icons.chat_bubble_outline,
      'color': Colors.orange,
      'title': 'New Message from Manager',
      'subtitle': 'Please check your chat for an update on the client request.',
      'time': '2d ago'
    },
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(
                      icon: notification['icon'],
                      color: notification['color'],
                      title: notification['title'],
                      subtitle: notification['subtitle'],
                      time: notification['time'],
                    );
                  },
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Text(
            'Notifications',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          // A spacer to balance the back button
          const SizedBox(width: 48),
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

  Widget _buildNotificationCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: _buildGlassCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.8),
              radius: 24,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(time, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}