/// CalendarService - Google Calendar Integration
///
/// Fetches calendar events to determine:
/// - Current meeting status (block interventions)
/// - Free windows (opportunity for habits)
/// - Travel detection (routine disruption)
/// - Busyness score (overall day load)
///
/// Uses device_calendar package for cross-platform support.

import 'package:device_calendar/device_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/context_snapshot.dart';

class CalendarService {
  final DeviceCalendarPlugin _calendarPlugin;

  /// Cache duration for calendar context
  static const Duration _cacheDuration = Duration(minutes: 5);

  CalendarContext? _cachedContext;
  DateTime? _cacheTimestamp;

  /// Travel keywords for detection
  static const List<String> _travelKeywords = [
    'flight',
    'airport',
    'travel',
    'trip',
    'vacation',
    'hotel',
    'train',
    'conference',
    'out of office',
    'ooo',
    'pto',
    'holiday',
    'away',
  ];

  CalendarService({
    DeviceCalendarPlugin? calendarPlugin,
  }) : _calendarPlugin = calendarPlugin ?? DeviceCalendarPlugin();

  /// Get calendar context for current time
  ///
  /// Returns cached data if fresh, otherwise fetches from device.
  Future<CalendarContext?> getCalendarContext() async {
    // Check cache
    if (_cachedContext != null && _cacheTimestamp != null) {
      final age = DateTime.now().difference(_cacheTimestamp!);
      if (age < _cacheDuration) {
        return _cachedContext;
      }
    }

    try {
      final context = await _fetchCalendarContext();
      _cachedContext = context;
      _cacheTimestamp = DateTime.now();
      return context;
    } catch (e) {
      // Return null on error (graceful degradation)
      return null;
    }
  }
  
  /// Get count of events for today (for onboarding insights)
  Future<int?> getTodayEventCount() async {
    try {
      // Create a temporary context fetch to get events
      // Since _fetchCalendarContext actually does the hard work of fetching and filtering
      // We can just add eventCount to CalendarContext in the future, but for now
      // we'll do a focused fetch.
      
      var permissionsGranted = await _calendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !(permissionsGranted.data ?? false)) {
        permissionsGranted = await _calendarPlugin.requestPermissions();
        if (!(permissionsGranted.data ?? false)) return null;
      }
      
      final calendarsResult = await _calendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null) return null;
      
      final calendars = calendarsResult.data!;
      if (calendars.isEmpty) return 0;
      
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      final allEvents = <Event>[];
      for (final calendar in calendars) {
        if (calendar.id == null) continue;
        
        final eventsResult = await _calendarPlugin.retrieveEvents(
          calendar.id!,
          RetrieveEventsParams(
            startDate: todayStart,
            endDate: todayEnd,
          ),
        );
        
        if (eventsResult.isSuccess && eventsResult.data != null) {
          allEvents.addAll(eventsResult.data!);
        }
      }
      
      return allEvents.length;
    } catch (_) {
      return null;
    }
  }

  /// Fetch calendar data from device
  Future<CalendarContext?> _fetchCalendarContext() async {
    // Request permissions
    var permissionsGranted = await _calendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !(permissionsGranted.data ?? false)) {
      permissionsGranted = await _calendarPlugin.requestPermissions();
      if (!(permissionsGranted.data ?? false)) {
        return null; // No permission
      }
    }

    // Get calendars
    final calendarsResult = await _calendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      return null;
    }

    final calendars = calendarsResult.data!;
    if (calendars.isEmpty) return null;

    // Define time range (today + next 3 days for travel detection)
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final rangeEnd = todayStart.add(const Duration(days: 4));

    // Fetch events from all calendars
    final allEvents = <Event>[];
    for (final calendar in calendars) {
      if (calendar.id == null) continue;

      final eventsResult = await _calendarPlugin.retrieveEvents(
        calendar.id!,
        RetrieveEventsParams(
          startDate: todayStart,
          endDate: rangeEnd,
        ),
      );

      if (eventsResult.isSuccess && eventsResult.data != null) {
        allEvents.addAll(eventsResult.data!);
      }
    }

    // Sort by start time
    allEvents.sort((a, b) =>
        (a.start ?? now).compareTo(b.start ?? now));

    // Analyze events
    return _analyzeEvents(allEvents, now);
  }

  /// Analyze events to build CalendarContext
  CalendarContext _analyzeEvents(List<Event> events, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final todayEnd = today.add(const Duration(days: 1));

    // Filter to today's events
    final todayEvents = events.where((e) {
      final start = e.start;
      if (start == null) return false;
      return start.isAfter(today) && start.isBefore(todayEnd);
    }).toList();

    // Check if currently in meeting
    bool isInMeeting = false;
    String? currentEventTitle;
    for (final event in todayEvents) {
      final start = event.start;
      final end = event.end;
      if (start != null && end != null) {
        if (now.isAfter(start) && now.isBefore(end)) {
          isInMeeting = true;
          currentEventTitle = event.title;
          break;
        }
      }
    }

    // Calculate minutes to next meeting
    int? minutesToNextMeeting;
    for (final event in todayEvents) {
      final start = event.start;
      if (start != null && start.isAfter(now)) {
        minutesToNextMeeting = start.difference(now).inMinutes;
        break;
      }
    }

    // Calculate free window (time until next meeting or end of day)
    int? freeWindowMinutes;
    if (!isInMeeting) {
      if (minutesToNextMeeting != null) {
        freeWindowMinutes = minutesToNextMeeting;
      } else {
        // No more meetings today
        freeWindowMinutes = todayEnd.difference(now).inMinutes;
      }
    }

    // Calculate busyness score (meeting hours / working hours)
    final busynessScore = _calculateBusyness(todayEvents, now);

    // Detect travel
    final (isTravelDay, isMultiDayTrip, tripDaysRemaining) =
        _detectTravel(events, now);

    return CalendarContext(
      busynessScore: busynessScore,
      freeWindowMinutes: freeWindowMinutes,
      minutesToNextMeeting: minutesToNextMeeting,
      isInMeeting: isInMeeting,
      currentEventTitle: currentEventTitle,
      capturedAt: now,
      isTravelDay: isTravelDay,
      isMultiDayTrip: isMultiDayTrip,
      tripDaysRemaining: tripDaysRemaining,
    );
  }

  /// Calculate busyness score (0.0 - 1.0)
  double _calculateBusyness(List<Event> todayEvents, DateTime now) {
    // Assume 8 working hours (9am - 5pm)
    const workingMinutes = 8 * 60;

    var meetingMinutes = 0;
    for (final event in todayEvents) {
      final start = event.start;
      final end = event.end;
      if (start != null && end != null) {
        final duration = end.difference(start).inMinutes;
        meetingMinutes += duration;
      }
    }

    return (meetingMinutes / workingMinutes).clamp(0.0, 1.0);
  }

  /// Detect travel from event titles
  (bool, bool, int?) _detectTravel(List<Event> events, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    bool isTravelToday = false;
    DateTime? tripEndDate;

    for (final event in events) {
      final title = event.title?.toLowerCase() ?? '';
      final isTravel = _travelKeywords.any((kw) => title.contains(kw));

      if (!isTravel) continue;

      final eventDate = event.start;
      if (eventDate == null) continue;

      final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

      // Check if travel is today
      if (eventDay == today) {
        isTravelToday = true;
      }

      // Track trip end date
      final endDate = event.end;
      if (endDate != null) {
        if (tripEndDate == null || endDate.isAfter(tripEndDate)) {
          tripEndDate = endDate;
        }
      }
    }

    // Calculate multi-day trip
    bool isMultiDayTrip = false;
    int? tripDaysRemaining;

    if (tripEndDate != null) {
      final tripEnd = DateTime(tripEndDate.year, tripEndDate.month, tripEndDate.day);
      final daysUntilEnd = tripEnd.difference(today).inDays;

      if (daysUntilEnd > 0) {
        isMultiDayTrip = true;
        tripDaysRemaining = daysUntilEnd;
      }
    }

    return (isTravelToday, isMultiDayTrip, tripDaysRemaining);
  }

  /// Check if user has calendar permission
  Future<bool> hasPermission() async {
    final result = await _calendarPlugin.hasPermissions();
    return result.isSuccess && (result.data ?? false);
  }

  /// Request calendar permission
  Future<bool> requestPermission() async {
    final result = await _calendarPlugin.requestPermissions();
    return result.isSuccess && (result.data ?? false);
  }

  /// Clear cache
  void clearCache() {
    _cachedContext = null;
    _cacheTimestamp = null;
  }
}
