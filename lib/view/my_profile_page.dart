///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/model/provider_model.dart';
import 'package:service_provider_side/providers/profile_provider.dart';
import 'availability_page.dart';
import 'support_center_page.dart';
import 'welcome_page.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  // --- UI Colors ---
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF29B6F6);

  @override
  Widget build(BuildContext context) {
    // Access the provider
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

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
                child: StreamBuilder<ProviderModel?>(
                  stream:
                      profileProvider
                          .providerStream, // Listen to the provider stream
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(
                        child: Text(
                          'Could not load profile.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    // We have the provider data!
                    final providerData = snapshot.data!;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileHeader(context, providerData),
                          const SizedBox(height: 24),
                          _buildSection(
                            context: context,
                            title: 'Account Settings',
                            children: [
                              _buildInfoTile(
                                Icons.person_outline,
                                'Full Name',
                                providerData.fullName,
                              ),
                              const Divider(color: Colors.white30, indent: 40),
                              InkWell(
                                onTap:
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const AvailabilityPage(),
                                      ),
                                    ),
                                child: _buildInfoTile(
                                  Icons.event_available_outlined,
                                  'My Availability',
                                  'Set working hours',
                                ),
                              ),
                              const Divider(color: Colors.white30, indent: 40),
                              InkWell(
                                onTap:
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const SupportCenterPage(),
                                      ),
                                    ),
                                child: _buildInfoTile(
                                  Icons.support_agent_outlined,
                                  'Help & Support',
                                  'Get assistance',
                                ),
                              ),
                              const Divider(color: Colors.white30, indent: 40),
                              InkWell(
                                onTap:
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const SettingsPage(),
                                      ),
                                    ),
                                child: _buildInfoTile(
                                  Icons.settings_outlined,
                                  'Settings',
                                  'Manage app preferences',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            context: context,
                            title: 'Payout Information',
                            children: [
                              _buildInfoTile(
                                Icons.account_balance_outlined,
                                'Bank Account',
                                '**** **** **** 5821',
                              ), // Placeholder
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            context: context,
                            title: 'My Certified Skills',
                            children: [
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children:
                                    providerData.certifiedSkills
                                        .map((skill) => _buildSkillChip(skill))
                                        .toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildLogoutButton(context),
                        ],
                      ),
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
            'My Profile',
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
            child: Padding(padding: const EdgeInsets.all(20.0), child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProviderModel providerData) {
    return _buildGlassCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage:
                providerData.profilePictureUrl != null
                    ? NetworkImage(providerData.profilePictureUrl!)
                    : const NetworkImage(
                      'https://picsum.photos/200',
                    ), // Placeholder
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  providerData.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Joined October 2025',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ), // Placeholder for join date
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            EditProfilePage(providerData: providerData),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        _buildGlassCard(child: Column(children: children)),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white.withOpacity(0.9),
      avatar: const Icon(Icons.check_circle, color: primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      side: BorderSide.none,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomePage()),
          (Route<dynamic> route) => false,
        );
      },
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text(
        'Logout',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        elevation: 0,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'availability_page.dart';
// import 'support_center_page.dart';
// import 'welcome_page.dart'; // Import for logout navigation
// import 'edit_profile_page.dart';
// import 'settings_page.dart'; // Import the Settings page

// class MyProfilePage extends StatelessWidget {
//   const MyProfilePage({super.key});

//   // --- UI Colors ---
//   static const Color primaryColor = Color(0xFF1A237E); // Indigo
//   static const Color accentColor = Color(0xFF29B6F6); // Light Blue

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
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildProfileHeader(context),
//                       const SizedBox(height: 24),
//                       _buildSection(
//                         context: context,
//                         title: 'Personal Details',
//                         children: [
//                           _buildInfoTile(
//                             Icons.person_outline,
//                             'Full Name',
//                             'Chaitanya Kumar',
//                           ),
//                           const Divider(color: Colors.white30, indent: 40),
//                           InkWell(
//                             onTap: () {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder:
//                                       (context) => const AvailabilityPage(),
//                                 ),
//                               );
//                             },
//                             child: _buildInfoTile(
//                               Icons.event_available_outlined,
//                               'My Availability',
//                               'Set working hours',
//                             ),
//                           ),
//                           const Divider(color: Colors.white30, indent: 40),
//                           InkWell(
//                             onTap: () {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder:
//                                       (context) => const SupportCenterPage(),
//                                 ),
//                               );
//                             },
//                             child: _buildInfoTile(
//                               Icons.support_agent_outlined,
//                               'Help & Support',
//                               'Get assistance',
//                             ),
//                           ),
//                           // --- INTEGRATION OF SETTINGS PAGE ---
//                           const Divider(color: Colors.white30, indent: 40),
//                           InkWell(
//                             onTap: () {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (context) => const SettingsPage(),
//                                 ),
//                               );
//                             },
//                             child: _buildInfoTile(
//                               Icons.settings_outlined,
//                               'Settings',
//                               'Manage app preferences',
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                       _buildSection(
//                         context: context,
//                         title: 'Payout Information',
//                         children: [
//                           _buildInfoTile(
//                             Icons.account_balance_outlined,
//                             'Bank Account',
//                             '**** **** **** 5821',
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                       _buildSection(
//                         context: context,
//                         title: 'My Certified Skills',
//                         children: [
//                           Wrap(
//                             spacing: 8.0,
//                             runSpacing: 8.0,
//                             children: [
//                               _buildSkillChip('Plumbing'),
//                               _buildSkillChip('Electrical Wiring'),
//                               _buildSkillChip('AC Repair'),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       _buildLogoutButton(context), // Pass context to the button
//                     ],
//                   ),
//                 ),
//               ),
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
//             'My Profile',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
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
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(20.0),
//             border: Border.all(color: Colors.white.withOpacity(0.3)),
//           ),
//           child: Material(
//             type: MaterialType.transparency,
//             child: Padding(padding: const EdgeInsets.all(20.0), child: child),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileHeader(BuildContext context) {
//     return _buildGlassCard(
//       child: Row(
//         children: [
//           const CircleAvatar(
//             radius: 35,
//             backgroundImage: NetworkImage('https://picsum.photos/200'),
//           ),
//           const SizedBox(width: 16),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Chaitanya Kumar',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'Joined October 2025',
//                   style: TextStyle(color: Colors.white70, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.edit_outlined, color: Colors.white),
//             onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => const EditProfilePage(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSection({
//     required BuildContext context,
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         _buildGlassCard(child: Column(children: children)),
//       ],
//     );
//   }

//   Widget _buildInfoTile(IconData icon, String title, String subtitle) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: Icon(icon, color: Colors.white70),
//       title: Text(
//         title,
//         style: const TextStyle(color: Colors.white70, fontSize: 14),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildSkillChip(String label) {
//     return Chip(
//       label: Text(
//         label,
//         style: const TextStyle(
//           color: primaryColor,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       backgroundColor: Colors.white.withOpacity(0.9),
//       avatar: const Icon(Icons.check_circle, color: primaryColor),
//       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//       side: BorderSide.none,
//     );
//   }

//   Widget _buildLogoutButton(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: () {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const WelcomePage()),
//           (Route<dynamic> route) => false,
//         );
//       },
//       icon: const Icon(Icons.logout, color: Colors.white),
//       label: const Text(
//         'Logout',
//         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.red.withOpacity(0.5),
//         elevation: 0,
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12.0),
//         ),
//       ),
//     );
//   }
// }
