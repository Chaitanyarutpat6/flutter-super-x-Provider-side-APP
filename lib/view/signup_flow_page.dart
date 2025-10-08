import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/providers/authentication_provider.dart';

class SignupFlowPage extends StatefulWidget {
  const SignupFlowPage({super.key});

  @override
  State<SignupFlowPage> createState() => _SignupFlowPageState();
}

class _SignupFlowPageState extends State<SignupFlowPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _skillController = TextEditingController();
  final _experienceController = TextEditingController();

  XFile? _aadharImage;
  XFile? _licenseImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _skillController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF29B6F6);

  Future<void> _pickImage({required bool isAadhar}) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        if (isAadhar) {
          _aadharImage = pickedFile;
        } else {
          _licenseImage = pickedFile;
        }
      });
    }
  }

  // --- THIS IS THE CORRECTED SUBMIT FUNCTION ---
  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );

    // Now we pass the selected images to the signUp method
    String? result = await authProvider.signUp(
      fullName: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      aadharImage: _aadharImage,
      licenseImage: _licenseImage,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Application submitted! You will be notified upon approval.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? 'An unknown error occurred.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _submitForm();
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
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentPage >= index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged:
                      (index) => setState(() => _currentPage = index),
                  children: [
                    _buildStep(
                      title: 'Personal Details',
                      subtitle: 'Create your account to get started.',
                      formFields: [
                        _buildTextFormField(
                          controller: _nameController,
                          labelText: 'Full Name',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _passwordController,
                          labelText: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _phoneController,
                          labelText: 'Phone Number',
                          icon: Icons.phone_outlined,
                        ),
                      ],
                    ),
                    _buildStep(
                      title: 'Professional Credentials',
                      subtitle: 'Tell us about your skills and experience.',
                      formFields: [
                        _buildTextFormField(
                          controller: _skillController,
                          labelText: 'Primary Skill (e.g., Plumber)',
                          icon: Icons.build_circle_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _experienceController,
                          labelText: 'Years of Experience',
                          icon: Icons.star_outline,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    _buildStep(
                      title: 'Document Verification',
                      subtitle: 'Upload your documents for verification.',
                      formFields: [
                        _buildUploadButton(
                          documentName: 'Upload ID Proof (Aadhaar)',
                          isAadhar: true,
                        ),
                        const SizedBox(height: 16),
                        _buildUploadButton(
                          documentName: 'Upload Professional License',
                          isAadhar: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _nextPage,
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
                          ? const CircularProgressIndicator(color: primaryColor)
                          : Text(
                            _currentPage == 2 ? 'FINISH & SUBMIT' : 'NEXT',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildStep({
    required String title,
    required String subtitle,
    required List<Widget> formFields,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ClipRRect(
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
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                ...formFields,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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

  Widget _buildUploadButton({
    required String documentName,
    required bool isAadhar,
  }) {
    final XFile? image = isAadhar ? _aadharImage : _licenseImage;
    final bool isSelected = image != null;

    return OutlinedButton.icon(
      onPressed: () => _pickImage(isAadhar: isAadhar),
      icon: Icon(
        isSelected ? Icons.check_circle : Icons.upload_file,
        color: isSelected ? Colors.greenAccent : Colors.white70,
      ),
      label: Text(
        isSelected ? image.name : documentName,
        style: TextStyle(color: isSelected ? Colors.white : Colors.white70),
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.white.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // Import image_picker
// import 'package:provider/provider.dart';
// import 'package:service_provider_side/providers/authentication_provider.dart';

// class SignupFlowPage extends StatefulWidget {
//   const SignupFlowPage({super.key});

//   @override
//   State<SignupFlowPage> createState() => _SignupFlowPageState();
// }

// class _SignupFlowPageState extends State<SignupFlowPage> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   bool _isLoading = false;

//   // Controllers for form fields
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _skillController = TextEditingController();
//   final _experienceController = TextEditingController();

//   // --- State variables to hold the selected image files ---
//   XFile? _aadharImage;
//   XFile? _licenseImage;
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _phoneController.dispose();
//     _skillController.dispose();
//     _experienceController.dispose();
//     super.dispose();
//   }

//   static const Color primaryColor = Color(0xFF1A237E);
//   static const Color accentColor = Color(0xFF29B6F6);

//   // --- NEW: Function to pick an image from the gallery ---
//   Future<void> _pickImage({required bool isAadhar}) async {
//     final XFile? pickedFile = await _picker.pickImage(
//       source: ImageSource.gallery,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         if (isAadhar) {
//           _aadharImage = pickedFile;
//         } else {
//           _licenseImage = pickedFile;
//         }
//       });
//     }
//   }

//   Future<void> _submitForm() async {
//     // TODO: In a future step, we will add logic here to upload _aadharImage and _licenseImage to Firebase Storage.
//     setState(() => _isLoading = true);

//     final authProvider = Provider.of<AuthenticationProvider>(
//       context,
//       listen: false,
//     );

//     String? result = await authProvider.signUp(
//       fullName: _nameController.text,
//       email: _emailController.text,
//       password: _passwordController.text,
//       phone: _phoneController.text,
//     );

//     setState(() => _isLoading = false);

//     if (!mounted) return;

//     if (result == 'success') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Application submitted! You will be notified upon approval.',
//           ),
//           backgroundColor: Colors.green,
//         ),
//       );
//       Navigator.of(context).pop();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(result ?? 'An unknown error occurred.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void _nextPage() {
//     if (_currentPage < 2) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeIn,
//       );
//     } else {
//       _submitForm();
//     }
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
//               Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(3, (index) {
//                     return Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                       width: 12,
//                       height: 12,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color:
//                             _currentPage >= index
//                                 ? Colors.white
//                                 : Colors.white.withOpacity(0.5),
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//               Expanded(
//                 child: PageView(
//                   controller: _pageController,
//                   onPageChanged:
//                       (index) => setState(() => _currentPage = index),
//                   children: [
//                     _buildStep(
//                       title: 'Personal Details',
//                       subtitle: 'Create your account to get started.',
//                       formFields: [
//                         _buildTextFormField(
//                           controller: _nameController,
//                           labelText: 'Full Name',
//                           icon: Icons.person_outline,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextFormField(
//                           controller: _emailController,
//                           labelText: 'Email Address',
//                           icon: Icons.email_outlined,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextFormField(
//                           controller: _passwordController,
//                           labelText: 'Password',
//                           icon: Icons.lock_outline,
//                           obscureText: true,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextFormField(
//                           controller: _phoneController,
//                           labelText: 'Phone Number',
//                           icon: Icons.phone_outlined,
//                         ),
//                       ],
//                     ),
//                     _buildStep(
//                       title: 'Professional Credentials',
//                       subtitle: 'Tell us about your skills and experience.',
//                       formFields: [
//                         _buildTextFormField(
//                           controller: _skillController,
//                           labelText: 'Primary Skill (e.g., Plumber)',
//                           icon: Icons.build_circle_outlined,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextFormField(
//                           controller: _experienceController,
//                           labelText: 'Years of Experience',
//                           icon: Icons.star_outline,
//                           keyboardType: TextInputType.number,
//                         ),
//                       ],
//                     ),
//                     _buildStep(
//                       title: 'Document Verification',
//                       subtitle: 'Upload your documents for verification.',
//                       formFields: [
//                         _buildUploadButton(
//                           documentName: 'Upload ID Proof (Aadhaar)',
//                           isAadhar: true,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildUploadButton(
//                           documentName: 'Upload Professional License',
//                           isAadhar: false,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _nextPage,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: primaryColor,
//                     minimumSize: const Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                   ),
//                   child:
//                       _isLoading
//                           ? const CircularProgressIndicator(color: primaryColor)
//                           : Text(
//                             _currentPage == 2 ? 'FINISH & SUBMIT' : 'NEXT',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // --- HELPER WIDGETS ---

//   Widget _buildStep({
//     required String title,
//     required String subtitle,
//     required List<Widget> formFields,
//   }) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20.0),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//           child: Container(
//             padding: const EdgeInsets.all(24.0),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20.0),
//               border: Border.all(color: Colors.white.withOpacity(0.3)),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   subtitle,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 16, color: Colors.white70),
//                 ),
//                 const SizedBox(height: 32),
//                 ...formFields,
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextFormField({
//     required TextEditingController controller,
//     required String labelText,
//     required IconData icon,
//     bool obscureText = false,
//     TextInputType? keyboardType,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
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

//   Widget _buildUploadButton({
//     required String documentName,
//     required bool isAadhar,
//   }) {
//     final XFile? image = isAadhar ? _aadharImage : _licenseImage;
//     final bool isSelected = image != null;

//     return OutlinedButton.icon(
//       onPressed: () => _pickImage(isAadhar: isAadhar),
//       icon: Icon(
//         isSelected ? Icons.check_circle : Icons.upload_file,
//         color: isSelected ? Colors.greenAccent : Colors.white70,
//       ),
//       label: Text(
//         isSelected ? image.name : documentName,
//         style: TextStyle(color: isSelected ? Colors.white : Colors.white70),
//         overflow: TextOverflow.ellipsis,
//       ),
//       style: OutlinedButton.styleFrom(
//         minimumSize: const Size(double.infinity, 50),
//         side: BorderSide(color: Colors.white.withOpacity(0.5)),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12.0),
//         ),
//       ),
//     );
//   }
// }
