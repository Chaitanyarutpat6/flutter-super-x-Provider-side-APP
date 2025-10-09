import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_side/model/provider_model.dart';
import 'package:service_provider_side/providers/profile_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class AvailabilityPage extends StatefulWidget {
  const AvailabilityPage({super.key});

  @override
  State<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF29B6F6);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

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
                  child: Column(
                    children: [
                      // This StreamBuilder handles the calendar and blocked dates
                      StreamBuilder<Set<DateTime>>(
                        stream: profileProvider.blockedDatesStream,
                        builder: (context, snapshot) {
                          final blockedDays = snapshot.data ?? {};
                          return _buildCalendarSection(profileProvider, blockedDays);
                        },
                      ),
                      const SizedBox(height: 24),
                      // This StreamBuilder handles the weekly time slots
                      StreamBuilder<ProviderModel?>(
                        stream: profileProvider.providerStream,
                        builder: (context, snapshot) {
                           final availability = snapshot.data?.weeklyAvailability ?? {};
                           return _buildTimeSlotsSection(availability);
                        }
                      ),
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
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28), onPressed: () => Navigator.of(context).pop()),
          const SizedBox(width: 8),
          const Text('My Availability', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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

  Widget _buildCalendarSection(ProfileProvider profileProvider, Set<DateTime> blockedDays) {
    return _buildGlassCard(
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          // Call the provider to toggle the date's blocked status
          profileProvider.toggleBlockedDate(selectedDay);
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            // Check if the day is in the blocked set
            if (blockedDays.any((d) => isSameDay(d, day))) {
              return Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Colors.redAccent, decoration: TextDecoration.lineThrough),
                ),
              );
            }
            return null;
          },
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: const TextStyle(color: Colors.white),
          weekendTextStyle: TextStyle(color: accentColor.withOpacity(0.8)),
          outsideTextStyle: const TextStyle(color: Colors.white30),
          todayDecoration: BoxDecoration(color: accentColor.withOpacity(0.5), shape: BoxShape.circle),
          selectedDecoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekendStyle: TextStyle(color: Colors.white70),
          weekdayStyle: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTimeSlotsSection(Map<String, dynamic> availability) {
    // A default schedule in case nothing is set in the database yet
    final defaultSchedule = {
      'Monday - Friday': '9:00 AM - 5:00 PM',
      'Saturday': '10:00 AM - 2:00 PM',
      'Sunday': 'Unavailable',
    };
    final schedule = availability.isNotEmpty ? availability : defaultSchedule;

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Weekly Hours', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...schedule.entries.map((entry) {
            return _buildTimeSlotRow(entry.key, entry.value.toString());
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeSlotRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(time, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}