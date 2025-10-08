import 'dart:ui';
import 'package:flutter/material.dart';

class CompletedJobDetailPage extends StatelessWidget {
  const CompletedJobDetailPage({super.key});

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
                      _buildJobSummary(),
                      const SizedBox(height: 24),
                      _buildInvoiceDetails(),
                      const SizedBox(height: 24),
                      _buildProofOfWork(),
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
          const Text('Completed Job Details', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildJobSummary() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plumbing Fix at Koregaon Park', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Completed on October 7, 2025', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Client Rating', style: TextStyle(color: Colors.white70, fontSize: 16)),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 20),
                  Icon(Icons.star, color: Colors.yellow, size: 20),
                  Icon(Icons.star, color: Colors.yellow, size: 20),
                  Icon(Icons.star, color: Colors.yellow, size: 20),
                  Icon(Icons.star, color: Colors.yellow, size: 20),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Invoice Details'),
        _buildGlassCard(
          child: Column(
            children: [
              _buildInvoiceRow('Service Charge', '₹500'),
              const Divider(color: Colors.white30, height: 20),
              _buildInvoiceRow('Materials Cost', '₹150'),
              const Divider(color: Colors.white30, height: 20),
              _buildInvoiceRow('Total Payout', '₹650', isTotal: true),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInvoiceRow(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(amount, style: TextStyle(color: isTotal ? Colors.greenAccent : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProofOfWork() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Proof of Work'),
        Row(
          children: [
            Expanded(child: _buildPhotoPlaceholder('Before')),
            const SizedBox(width: 16),
            Expanded(child: _buildPhotoPlaceholder('After')),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder(String label) {
    return _buildGlassCard(
      child: Column(
        children: [
          const Icon(Icons.image_outlined, color: Colors.white70, size: 50),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}