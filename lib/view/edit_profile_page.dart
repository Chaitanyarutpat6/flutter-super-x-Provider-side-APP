import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/model/provider_model.dart';
import 'package:service_provider_side/providers/profile_provider.dart';
import 'package:service_provider_side/providers/storage_provider.dart';

class EditProfilePage extends StatefulWidget {
  final ProviderModel providerData;
  const EditProfilePage({super.key, required this.providerData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with current data
    _nameController = TextEditingController(text: widget.providerData.fullName);
    _phoneController = TextEditingController(text: widget.providerData.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF29B6F6);

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final storageProvider = Provider.of<StorageProvider>(context, listen: false);

    String? newImageUrl;

    // 1. Upload new profile image if one was selected
    if (_profileImage != null) {
      newImageUrl = await storageProvider.uploadImage(
        _profileImage!,
        'providers/${widget.providerData.uid}', // folder path
        'profile_picture', // file name
      );
    }

    // 2. Update the profile data in Firestore
    String? result = await profileProvider.updateProfile(
      fullName: _nameController.text,
      phone: _phoneController.text,
      newProfilePictureUrl: newImageUrl, // Pass the new URL, or null if no change
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ?? 'An error occurred.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [primaryColor, accentColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                      children: [
                        _buildProfilePictureEditor(),
                        const SizedBox(height: 32),
                        _buildTextFormField(controller: _nameController, labelText: 'Full Name', icon: Icons.person_outline),
                        const SizedBox(height: 20),
                        _buildTextFormField(controller: _phoneController, labelText: 'Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                      ],
                    ),
                  ),
                ),
              ),
              _buildSaveButton(),
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
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28), onPressed: () => Navigator.of(context).pop()),
          const SizedBox(width: 8),
          const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
          padding: const EdgeInsets.all(24.0),
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

  Widget _buildProfilePictureEditor() {
    ImageProvider backgroundImage;
    if (_profileImage != null) {
      backgroundImage = FileImage(File(_profileImage!.path));
    } else if (widget.providerData.profilePictureUrl != null) {
      backgroundImage = NetworkImage(widget.providerData.profilePictureUrl!);
    } else {
      backgroundImage = const NetworkImage('https://picsum.photos/200'); // Default placeholder
    }

    return Stack(
      children: [
        CircleAvatar(radius: 60, backgroundImage: backgroundImage),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: primaryColor),
              onPressed: _pickImage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String labelText, required IconData icon, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.white)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        ),
        child: _isLoading
          ? const CircularProgressIndicator(color: primaryColor)
          : const Text('SAVE CHANGES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }
}










////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'dart:ui';
// import 'package:flutter/material.dart';

// class EditProfilePage extends StatefulWidget {
//   const EditProfilePage({super.key});

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   final _nameController = TextEditingController(text: 'Chaitanya Kumar');
//   final _phoneController = TextEditingController(text: '+91 98765 43210');

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   // --- UI Colors ---
//   static const Color primaryColor = Color(0xFF1A237E); // Indigo
//   static const Color accentColor = Color(0xFF29B6F6); // Light Blue

//   void _saveProfile() {
//     print('Saving changes...');
//     Navigator.of(context).pop(); // Go back to the profile page
//   }

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
//                   child: _buildGlassCard(
//                     child: Column(
//                       children: [
//                         _buildProfilePictureEditor(),
//                         const SizedBox(height: 32),
//                         _buildTextFormField(
//                           controller: _nameController,
//                           labelText: 'Full Name',
//                           icon: Icons.person_outline,
//                         ),
//                         const SizedBox(height: 20),
//                         _buildTextFormField(
//                           controller: _phoneController,
//                           labelText: 'Phone Number',
//                           icon: Icons.phone_outlined,
//                           keyboardType: TextInputType.phone,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               _buildSaveButton(),
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
//         children: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           const SizedBox(width: 8),
//           const Text(
//             'Edit Profile',
//             style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
//           padding: const EdgeInsets.all(24.0),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(20.0),
//             border: Border.all(color: Colors.white.withOpacity(0.3)),
//           ),
//           child: Material(
//             type: MaterialType.transparency,
//             child: child,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfilePictureEditor() {
//     return Stack(
//       children: [
//         const CircleAvatar(
//           radius: 60,
//           backgroundImage: NetworkImage('https://picsum.photos/200'),
//         ),
//         Positioned(
//           bottom: 0,
//           right: 0,
//           child: CircleAvatar(
//             radius: 22,
//             backgroundColor: Colors.white,
//             child: IconButton(
//               icon: const Icon(Icons.camera_alt_outlined, color: primaryColor),
//               onPressed: () { /* Add image picking logic */ },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextFormField({
//     required TextEditingController controller,
//     required String labelText,
//     required IconData icon,
//     TextInputType? keyboardType,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: labelText,
//         labelStyle: const TextStyle(color: Colors.white70),
//         prefixIcon: Icon(icon, color: Colors.white70),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.0),
//           borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.0),
//           borderSide: const BorderSide(color: Colors.white),
//         ),
//       ),
//     );
//   }

//   Widget _buildSaveButton() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: ElevatedButton(
//         onPressed: _saveProfile,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.white,
//           foregroundColor: primaryColor,
//           minimumSize: const Size(double.infinity, 60),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
//         ),
//         child: const Text(
//           'SAVE CHANGES',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
//         ),
//       ),
//     );
//   }
// }