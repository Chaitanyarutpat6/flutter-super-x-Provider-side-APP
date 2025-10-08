import 'dart:ui';
import 'package:flutter/material.dart';

class PayoutHistoryPage extends StatelessWidget {
  const PayoutHistoryPage({super.key});

  // Dummy data for payout history
  final List<Map<String, String>> payoutHistory = const [
    {'id': '#P5821', 'date': 'October 1, 2025', 'amount': '₹5,500', 'status': 'Completed'},
    {'id': '#P5799', 'date': 'September 25, 2025', 'amount': '₹4,800', 'status': 'Completed'},
    {'id': '#P5780', 'date': 'September 18, 2025', 'amount': '₹6,200', 'status': 'Completed'},
    {'id': '#P5765', 'date': 'September 11, 2025', 'amount': '₹4,500', 'status': 'Completed'},
    {'id': '#P5750', 'date': 'September 4, 2025', 'amount': '₹5,100', 'status': 'Completed'},
  ];

  // --- UI Colors ---
  static const Color primaryColor = Color(0xFF1A237E); // Indigo
  static const Color accentColor = Color(0xFF29B6F6); // Light Blue

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
                  itemCount: payoutHistory.length,
                  itemBuilder: (context, index) {
                    final payout = payoutHistory[index];
                    return _buildHistoryCard(
                      id: payout['id']!,
                      date: payout['date']!,
                      amount: payout['amount']!,
                      status: payout['status']!,
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
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Payout History',
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
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHistoryCard({required String id, required String date, required String amount, required String status}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: _buildGlassCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(id, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(date, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(status, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}