import 'package:flutter/material.dart';
import 'package:service_provider_side/view/dashboard_content.dart';
import 'package:service_provider_side/view/my_schedule_page.dart';
import 'package:service_provider_side/view/placeholder_page.dart';
import 'package:service_provider_side/view/job_history_page.dart';
import 'package:service_provider_side/view/earnings_dashboard_page.dart';
import 'package:service_provider_side/view/notifications_page.dart';
import 'package:service_provider_side/view/my_profile_page.dart';
import 'package:service_provider_side/view/main_dashboard_page.dart';

// You will need to create this file and move your dashboard UI into it.
// class DashboardContent extends StatelessWidget {
//   const DashboardContent({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text('Dashboard Content', style: TextStyle(color: Colors.white)));
//   }
// }

class MainDashboardPage extends StatefulWidget {
  // The static route name is crucial
  static const String routeName = '/dashboard';

  const MainDashboardPage({super.key});

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<String> _pageTitles = [
    'Dashboard',
    'My Schedule',
    'Job History',
    'Earnings',
  ];

  final List<Widget> _pages = [
    const DashboardContent(),
    const MySchedulePage(),
    const JobHistoryPage(),
    const EarningsDashboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF29B6F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            _pageTitles[_currentIndex],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          // This automatically hides the back button when it's not needed
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MyProfilePage(),
                    ),
                  ),
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap:
              (index) => _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              ),
          backgroundColor: Colors.black.withOpacity(0.3),
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.lightBlue[100],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_outlined),
              label: 'Earnings',
            ),
          ],
        ),
      ),
    );
  }
}
