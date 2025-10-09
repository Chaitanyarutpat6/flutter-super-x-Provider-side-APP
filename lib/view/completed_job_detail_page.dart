import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:service_provider_side/model/job_model.dart';

class CompletedJobDetailPage extends StatelessWidget {
  // --- THIS PAGE NOW REQUIRES A JOBMODEL ---
  final JobModel job;
  const CompletedJobDetailPage({super.key, required this.job});

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
          const Text(
            'Completed Job Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
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

  Widget _buildJobSummary() {
    // Format the date for display
    final date =
        job.completionDate != null
            ? DateFormat.yMMMMd().format(job.completionDate!)
            : 'N/A';
    log("$date");
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text('Completed on $date', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          const Row(
            // Placeholder for rating
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Client Rating',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 20),
                  Icon(Icons.star, color: Colors.yellow, size: 20),
                  Icon(Icons.star, color: Colors.yellow, size: 20),
                  Icon(Icons.star, color: Colors.yellow, size: 20),
                  Icon(Icons.star_half, color: Colors.yellow, size: 20),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    final double totalPayout = job.payout + (job.materialsCost ?? 0.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Invoice Details'),
        _buildGlassCard(
          child: Column(
            children: [
              _buildInvoiceRow(
                'Service Charge',
                '₹${job.payout.toStringAsFixed(0)}',
              ),
              const Divider(color: Colors.white30, height: 20),
              // --- UPDATED: Use the dynamic materialsCost ---
              _buildInvoiceRow(
                'Materials Cost',
                '₹${job.materialsCost.toStringAsFixed(0)}',
              ),
              const Divider(color: Colors.white30, height: 20),
              // --- UPDATED: Use the calculated total ---
              _buildInvoiceRow(
                'Total Payout',
                '₹${totalPayout.toStringAsFixed(0)}',
                isTotal: true,
              ),
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
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isTotal ? Colors.greenAccent : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
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
            Expanded(
              child: _buildPhotoPlaceholder('Before', job.beforeImageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildPhotoPlaceholder('After', job.afterImageUrl)),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder(String label, String? imageUrl) {
    return _buildGlassCard(
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              image:
                  imageUrl != null
                      ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                imageUrl == null
                    ? const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white70,
                      size: 50,
                    )
                    : null,
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
