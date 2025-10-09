import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/view/main_dashboard_page.dart';
import 'package:service_provider_side/model/job_model.dart';
import 'package:service_provider_side/providers/job_provider.dart';
import 'package:service_provider_side/providers/storage_provider.dart';

class JobCompletionFormPage extends StatefulWidget {
  final JobModel job;
  const JobCompletionFormPage({super.key, required this.job});

  @override
  State<JobCompletionFormPage> createState() => _JobCompletionFormPageState();
}

class _JobCompletionFormPageState extends State<JobCompletionFormPage> {
  final _notesController = TextEditingController();
  final _materialsCostController = TextEditingController();
  bool _isLoading = false;

  XFile? _beforeImage;
  XFile? _afterImage;
  final ImagePicker _picker = ImagePicker();

  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF29B6F6);

  Future<void> _pickImage({required bool isBefore}) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        if (isBefore) {
          _beforeImage = pickedFile;
        } else {
          _afterImage = pickedFile;
        }
      });
    }
  }

  Future<void> _submitReport() async {
    setState(() => _isLoading = true);

    final storageProvider = Provider.of<StorageProvider>(
      context,
      listen: false,
    );
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    String? beforeImageUrl;
    String? afterImageUrl;

    // Upload before image if selected
    if (_beforeImage != null) {
      beforeImageUrl = await storageProvider.uploadImage(
        _beforeImage!,
        'jobs/${widget.job.id}',
        'before_photo',
      );
    }

    // Upload after image if selected
    if (_afterImage != null) {
      afterImageUrl = await storageProvider.uploadImage(
        _afterImage!,
        'jobs/${widget.job.id}',
        'after_photo',
      );
    }

    // Update the job document in Firestore
    String? result = await jobProvider.completeJob(
      jobId: widget.job.id,
      reportNotes: _notesController.text,
      materialsCost: double.tryParse(_materialsCostController.text) ?? 0.0,
      beforeImageUrl: beforeImageUrl,
      afterImageUrl: afterImageUrl,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == 'success') {
      Navigator.of(context).popUntil((route) => route.isFirst);
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
                  child: _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upload Proof of Work',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPhotoUploaders(),
                        const SizedBox(height: 24),
                        _buildTextFormField(
                          controller: _notesController,
                          labelText: 'Notes on Work Done',
                          icon: Icons.notes_outlined,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _materialsCostController,
                          labelText: 'Cost of Materials Used (₹)',
                          icon: Icons.currency_rupee_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Job Completion Report',
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

  Widget _buildPhotoUploaders() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildPhotoPlaceholder(
          'Upload "Before" Photo',
          Icons.camera_alt_outlined,
          _beforeImage,
          isBefore: true,
        ),
        _buildPhotoPlaceholder(
          'Upload "After" Photo',
          Icons.check_circle_outline,
          _afterImage,
          isBefore: false,
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder(
    String text,
    IconData icon,
    XFile? image, {
    required bool isBefore,
  }) {
    return GestureDetector(
      onTap: () => _pickImage(isBefore: isBefore),
      child: Column(
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
              image:
                  image != null
                      ? DecorationImage(
                        image: FileImage(File(image.path)),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                image == null
                    ? Icon(icon, color: Colors.white70, size: 40)
                    : null,
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: primaryColor)
                : const Text(
                  'SUBMIT REPORT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
      ),
    );
  }
}
