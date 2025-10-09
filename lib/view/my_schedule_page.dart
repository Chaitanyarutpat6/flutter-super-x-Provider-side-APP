import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/model/job_model.dart';
import 'package:service_provider_side/providers/job_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'active_job_page.dart';

class MySchedulePage extends StatefulWidget {
  const MySchedulePage({super.key});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ValueNotifier<List<JobModel>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  // --- UI Colors ---
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF29B6F6);

  List<JobModel> _getEventsForDay(DateTime day, List<JobModel> allJobs) {
    return allJobs.where((job) => isSameDay(job.postedDate, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // This page is a content page for the main dashboard's PageView
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildListView(context), _buildCalendarView(context)],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.white,
      indicatorWeight: 3.0,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      tabs: const [Tab(text: 'List View'), Tab(text: 'Calendar View')],
    );
  }

  // --- Tab Content Builders ---

  Widget _buildListView(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    return StreamBuilder<List<JobModel>>(
      stream: jobProvider.scheduledJobsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        final jobs = snapshot.data!;
        if (jobs.isEmpty) {
          return Center(
            child: _buildGlassCard(
              child: const Text(
                'No jobs scheduled.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        // Group jobs by date
        Map<String, List<JobModel>> groupedJobs = {};
        for (var job in jobs) {
          String dateKey = DateFormat.yMMMMd().format(job.postedDate);
          if (groupedJobs[dateKey] == null) {
            groupedJobs[dateKey] = [];
          }
          groupedJobs[dateKey]!.add(job);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: groupedJobs.keys.length,
          itemBuilder: (context, index) {
            String date = groupedJobs.keys.elementAt(index);
            List<JobModel> jobsForDate = groupedJobs[date]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(date),
                ...jobsForDate.map((job) => _buildJobCard(job)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    return StreamBuilder<List<JobModel>>(
      stream: jobProvider.scheduledJobsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        final allJobs = snapshot.data!;
        _selectedEvents.value = _getEventsForDay(
          _selectedDay!,
          allJobs,
        ); // Update selected events

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildGlassCard(
                child: TableCalendar<JobModel>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: (day) => _getEventsForDay(day, allJobs),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedEvents.value = _getEventsForDay(
                        selectedDay,
                        allJobs,
                      );
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor,
                            ),
                            width: 8,
                            height: 8,
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(
                      color: accentColor.withOpacity(0.8),
                    ),
                    outsideTextStyle: const TextStyle(color: Colors.white30),
                    todayDecoration: BoxDecoration(
                      color: accentColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.white70),
                    weekdayStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<List<JobModel>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  return ListView.builder(
                    itemCount: value.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildJobCard(value[index]);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0, left: 8.0),
      child: Text(
        date,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildJobCard(JobModel job) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ActiveJobPage(job: job), ),
          );
        },
        borderRadius: BorderRadius.circular(20.0),
        child: _buildGlassCard(
          child: Row(
            children: [
              Text(
                TimeOfDay.fromDateTime(job.postedDate).format(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              const VerticalDivider(color: Colors.white30, width: 1),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.location,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
}



// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'active_job_page.dart';

// class MySchedulePage extends StatefulWidget {
//   const MySchedulePage({super.key});

//   @override
//   State<MySchedulePage> createState() => _MySchedulePageState();
// }

// class _MySchedulePageState extends State<MySchedulePage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _selectedDay = _focusedDay;
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // --- UI Colors ---
//   static const Color primaryColor = Color(0xFF1A237E);
//   static const Color accentColor = Color(0xFF29B6F6);

//   @override
//   Widget build(BuildContext context) {
//     // This page is now just a Column with the content, no Scaffold.
//     return Column(
//       children: [
//         _buildTabBar(),
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: [_buildListView(), _buildCalendarView()],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTabBar() {
//     return TabBar(
//       controller: _tabController,
//       indicatorColor: Colors.white,
//       indicatorWeight: 3.0,
//       labelColor: Colors.white,
//       unselectedLabelColor: Colors.white70,
//       labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//       tabs: const [Tab(text: 'List View'), Tab(text: 'Calendar View')],
//     );
//   }

//   // --- List View Tab ---
//   Widget _buildListView() {
//     return ListView(
//       padding: const EdgeInsets.all(16.0),
//       children: [
//         _buildDateHeader('Today, October 7'),
//         _buildJobCard(
//           '10:00 AM',
//           'Plumbing Fix at Koregaon Park',
//           'Client: Anjali Sharma',
//         ),
//         _buildJobCard(
//           '02:30 PM',
//           'AC Servicing at Baner',
//           'Client: Vikram Singh',
//         ),
//         const SizedBox(height: 16),
//         _buildDateHeader('Tomorrow, October 8'),
//         _buildJobCard(
//           '09:00 AM',
//           'Electrical Wiring Check',
//           'Client: Priya Mehta',
//         ),
//       ],
//     );
//   }

//   // --- Calendar View Tab ---
//   Widget _buildCalendarView() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: _buildGlassCard(
//         child: TableCalendar(
//           firstDay: DateTime.utc(2020, 1, 1),
//           lastDay: DateTime.utc(2030, 12, 31),
//           focusedDay: _focusedDay,
//           calendarFormat: CalendarFormat.month,
//           selectedDayPredicate: (day) {
//             return isSameDay(_selectedDay, day);
//           },
//           onDaySelected: (selectedDay, focusedDay) {
//             setState(() {
//               _selectedDay = selectedDay;
//               _focusedDay = focusedDay; // update `_focusedDay` here as well
//             });
//           },
//           // --- STYLING THE CALENDAR ---
//           headerStyle: const HeaderStyle(
//             titleCentered: true,
//             formatButtonVisible: false,
//             titleTextStyle: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//             leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
//             rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
//           ),
//           calendarStyle: CalendarStyle(
//             defaultTextStyle: const TextStyle(color: Colors.white),
//             weekendTextStyle: TextStyle(color: accentColor.withOpacity(0.8)),
//             outsideTextStyle: const TextStyle(color: Colors.white30),
//             todayDecoration: BoxDecoration(
//               color: accentColor.withOpacity(0.5),
//               shape: BoxShape.circle,
//             ),
//             selectedDecoration: const BoxDecoration(
//               color: primaryColor,
//               shape: BoxShape.circle,
//             ),
//           ),
//           daysOfWeekStyle: const DaysOfWeekStyle(
//             weekendStyle: TextStyle(color: Colors.white70),
//             weekdayStyle: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }

//   // --- Helper Widgets ---

//   Widget _buildDateHeader(String date) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
//       child: Text(
//         date,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildJobCard(String time, String title, String subtitle) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: InkWell(
//         onTap: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(builder: (context) => const ActiveJobPage()),
//           );
//         },
//         borderRadius: BorderRadius.circular(20.0),
//         child: _buildGlassCard(
//           child: Row(
//             children: [
//               Text(
//                 time,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               const VerticalDivider(color: Colors.white30, width: 1),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.white70,
//                 size: 16,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGlassCard({required Widget child}) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20.0),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//         child: Container(
//           padding: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(20.0),
//             border: Border.all(color: Colors.white.withOpacity(0.3)),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }