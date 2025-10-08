import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/providers/authentication_provider.dart';
import 'package:service_provider_side/view/forgot_password_page.dart';
import 'package:service_provider_side/view/main_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // State for loading indicator
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF29B6F6);

  // --- UPDATED FIREBASE LOGIN LOGIC ---
  Future<void> _login() async {
    setState(() => _isLoading = true);

    // Access the AuthenticationProvider
    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );

    // Call the login method from the provider
    String? result = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return; // Check if the widget is still in the tree

    if (result == 'success') {
      // Navigate to the dashboard on successful login
      Navigator.of(context).pushReplacementNamed(MainDashboardPage.routeName);
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? 'An unknown error occurred.'),
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildGlassmorphismCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphismCard() {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shield_outlined, size: 60, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Provider Portal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 32),
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
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed:
                      () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                // Disable button while loading
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                // Show a loading spinner or text
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: primaryColor,
                          ),
                        )
                        : const Text(
                          'SIGN IN',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
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
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
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
}

// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:service_provider_side/view/forgot_password_page.dart';
// import 'package:service_provider_side/view/main_dashboard_page.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isPasswordVisible = false;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   static const Color primaryColor = Color(0xFF1A237E);
//   static const Color accentColor = Color(0xFF29B6F6);

//   void _login() {
//     final email = _emailController.text;
//     final password = _passwordController.text;

//     if (email.isNotEmpty && password.isNotEmpty) {
//       // This is the only navigation call that should exist.
//       Navigator.of(context).pushReplacementNamed(MainDashboardPage.routeName);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill in both fields.'), backgroundColor: Colors.red),
//       );
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
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: _buildGlassmorphismCard(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGlassmorphismCard() {
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
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Icon(Icons.shield_outlined, size: 60, color: Colors.white),
//               const SizedBox(height: 16),
//               const Text('Provider Portal', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white, letterSpacing: 1.2)),
//               const SizedBox(height: 32),
//               _buildTextFormField(controller: _emailController, labelText: 'Email Address', icon: Icons.email_outlined),
//               const SizedBox(height: 16),
//               _buildTextFormField(
//                 controller: _passwordController,
//                 labelText: 'Password',
//                 icon: Icons.lock_outline,
//                 obscureText: !_isPasswordVisible,
//                 suffixIcon: IconButton(
//                   icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
//                   onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _login,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: primaryColor,
//                   padding: const EdgeInsets.symmetric(vertical: 16.0),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//                 ),
//                 child: const Text('SIGN IN', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 16)),
//               ),
//               const SizedBox(height: 16),
//               TextButton(
//                 onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPasswordPage())),
//                 child: const Text('Forgot Password?', style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w500)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextFormField({required TextEditingController controller, required String labelText, required IconData icon, bool obscureText = false, Widget? suffixIcon}) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: labelText,
//         labelStyle: const TextStyle(color: Colors.white70),
//         prefixIcon: Icon(icon, color: Colors.white70),
//         suffixIcon: suffixIcon,
//         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
//         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.white)),
//       ),
//     );
//   }
// }
