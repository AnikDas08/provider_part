import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/services/api/api_service.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';

import '../../../../utils/constants/app_string.dart';

class OverviewController extends GetxController {
  // Tabs
  var selectedTab = 0.obs;

  // Selected month and year from dropdown
  var selectedMonth = ''.obs;
  var selectedYear = ''.obs;

  // Calendar state
  var focusedDay = DateTime.now().obs;
  var selectedDay = Rxn<DateTime>();

  // Working day toggles - ALL FALSE by default
  var workingDays = <String, bool>{
    AppString.saturday_text: false,
    AppString.sunday_text: false,
    AppString.monday_text: false,
    AppString.tuesday_text: false,
    AppString.wednesday_text: false,
    AppString.thursday_text: false,
    AppString.friday_text: false,
  }.obs;

  // Working times for each day - Empty by default
  var workingTimes = <String, Map<String, String>>{
    AppString.monday_text: {AppString.start_text: "", AppString.end_text: ""},
    AppString.tuesday_text: {AppString.start_text: "", AppString.end_text: ""},
    AppString.wednesday_text: {AppString.start_text: "", AppString.end_text: ""},
    AppString.thursday_text: {AppString.start_text: "", AppString.end_text: ""},
    AppString.friday_text: {AppString.start_text: "", AppString.end_text: ""},
    AppString.saturday_text: {AppString.start_text: "", AppString.end_text: ""},
    AppString.sunday_text: {AppString.start_text: "", AppString.end_text: ""},
  }.obs;

  // Store fetched schedules
  var scheduleList = <Map<String, dynamic>>[].obs;

  // Statistics
  var successfulBooking = 0.obs;
  var canceledBooking = 0.obs;
  var totalMoneyEarned = 0.obs;

  // Loading state
  var isLoading = false.obs;
  var isOverviewLoading = false.obs;

  // Time options for dropdown
  final List<String> timeOptions = [
    "00:00", "01:00", "02:00",
    "03:00", "04:00", "05:00",
    "06:00",  "07:00",  "08:00",
    "09:00",  "10:00",  "11:00",
    "12:00",  "13:00",  "14:00",
    "15:00", "16:00",  "17:00",
    "18:00", "19:00",  "20:00",
    "21:00", "22:00", "23:00",
  ];

  @override
  void onInit() {
    super.onInit();
    selectedDay.value = DateTime.now();

    // Set initial month and year
    final now = DateTime.now();
    selectedMonth.value = _monthName(now.month);
    selectedYear.value = now.year.toString();

    // Initialize working times for all days
    workingTimes[AppString.monday_text] = {AppString.start_text: "", AppString.end_text: ""};
    workingTimes[AppString.tuesday_text] = {AppString.start_text: "", AppString.end_text: ""};
    workingTimes[AppString.wednesday_text] = {AppString.start_text: "", AppString.end_text: ""};
    workingTimes[AppString.thursday_text] = {AppString.start_text: "", AppString.end_text: ""};
    workingTimes[AppString.friday_text] = {AppString.start_text: "", AppString.end_text: ""};
    workingTimes[AppString.saturday_text] = {AppString.start_text: "", AppString.end_text: ""};
    workingTimes[AppString.sunday_text] = {AppString.start_text: "", AppString.end_text: ""};

    // Fetch schedules on init
    fetchSchedules();

    // Fetch booking overview on init
    fetchBookingOverview();
  }

  // Tab change
  void changeTab(int index) {
    selectedTab.value = index;
  }

  // Day selected in TableCalendar - with toggle support
  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    // Check if clicking the SAME day that's currently selected - toggle it off
    if (selectedDay.value != null &&
        selectedDay.value!.year == selectedDate.year &&
        selectedDay.value!.month == selectedDate.month &&
        selectedDay.value!.day == selectedDate.day) {
      // Unselect the day
      selectedDay.value = null;
      print("📅 Day unselected - fetching monthly/yearly overview");
    } else {
      // Select the new day (or select a day if none was selected)
      selectedDay.value = selectedDate;
      print("📅 Day selected: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}");
    }

    focusedDay.value = focusedDate;

    // Force refresh to update UI
    update();

    // Fetch schedules for the new selected week
    fetchSchedules();

    // Fetch booking overview for the selected day (or month/year if day unselected)
    fetchBookingOverview();
  }

  // Change month from dropdown - with support for empty (all months)
  void changeMonth(String month) {
    selectedMonth.value = month;

    // If month is selected (not empty), update focusedDay
    if (month.isNotEmpty) {
      int monthIndex = _monthIndex(month);
      focusedDay.value = DateTime(focusedDay.value.year, monthIndex, 1);
    }

    // Fetch booking overview for the selected month (or yearly if empty)
    fetchBookingOverview();
  }

  // Change year from dropdown
  void changeYear(String year) {
    selectedYear.value = year;

    // Update focusedDay to selected year, keeping the month
    focusedDay.value = DateTime(int.parse(year), focusedDay.value.month, 1);

    // Fetch booking overview for the selected year
    fetchBookingOverview();
  }

  // Top month name for display
  String get currentMonth => selectedMonth.value;

  // Fetch Booking Overview API
  Future<void> fetchBookingOverview() async {
    try {
      isOverviewLoading.value = true;

      // Build query parameters based on selected date, month, and year
      String queryParams = _buildOverviewQueryParams();

      String url = "${ApiEndPoint.baseUrl}/booking/overview$queryParams";

      print("📊 Fetching booking overview: $url");

      final response = await ApiService.get(
        url,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          // Update statistics from API response
          successfulBooking.value = data['data']['totalCompleted'] ?? 0;
          canceledBooking.value = data['data']['totalCanceled'] ?? 0;
          totalMoneyEarned.value = data['data']['totalEarned'] ?? 0;

          print("✅ Booking Overview - Completed: ${successfulBooking.value}, Canceled: ${canceledBooking.value}, Earned: ${totalMoneyEarned.value}");
        }
      } else {
        print("⚠️ Failed to fetch booking overview. Status: ${response.statusCode}");
        _resetOverviewStats();
      }

    } catch (e) {
      print("❌ Error fetching booking overview: $e");
      _resetOverviewStats();
    } finally {
      isOverviewLoading.value = false;
    }
  }

  // Build query parameters for overview API
  String _buildOverviewQueryParams() {
    List<String> params = [];

    // Add day parameter ONLY if a specific day is selected
    if (selectedDay.value != null) {
      params.add("day=${selectedDay.value!.day}");
      print("📅 Including day: ${selectedDay.value!.day}");
    } else {
      print("📅 No day selected - getting monthly/yearly data");
    }

    // Add month parameter ONLY if month is not empty
    if (selectedMonth.value.isNotEmpty) {
      int monthIndex = _monthIndex(selectedMonth.value);
      params.add("month=$monthIndex");
      print("📅 Including month: $monthIndex");
    } else {
      print("📅 No month selected - getting yearly data");
    }

    // Add year parameter from selected year
    params.add("year=${selectedYear.value}");
    print("📅 Including year: ${selectedYear.value}");

    return params.isEmpty ? "" : "?${params.join('&')}";
  }

  // Reset overview statistics
  void _resetOverviewStats() {
    successfulBooking.value = 0;
    canceledBooking.value = 0;
    totalMoneyEarned.value = 0;
  }

  // Get ordered list of days starting from selected date (ONLY NEXT 7 DAYS INCLUDING SELECTED)
  List<String> getOrderedDays() {
    // Get the selected date or use today
    DateTime baseDate = selectedDay.value ?? DateTime.now();

    // Day names in order matching DateTime.weekday
    // DateTime.weekday: Monday = 1, Tuesday = 2, ..., Sunday = 7
    const allDays = [
      AppString.monday_text,    // index 0 = Monday (weekday 1)
      AppString.tuesday_text,   // index 1 = Tuesday (weekday 2)
      AppString.wednesday_text, // index 2 = Wednesday (weekday 3)
      AppString.thursday_text,  // index 3 = Thursday (weekday 4)
      AppString.friday_text,    // index 4 = Friday (weekday 5)
      AppString.saturday_text,  // index 5 = Saturday (weekday 6)
      AppString.sunday_text,    // index 6 = Sunday (weekday 7)
    ];

    // Get the weekday of the selected date (1 = Monday, 7 = Sunday)
    // Convert to 0-6 index (0 = Monday, 6 = Sunday)
    int startIndex = baseDate.weekday - 1;

    // Create ordered list starting from selected day (next 7 days including today)
    List<String> orderedDays = [];
    for (int i = 0; i < 7; i++) {
      int dayIndex = (startIndex + i) % 7;
      orderedDays.add(allDays[dayIndex]);
    }

    return orderedDays;
  }

  // Get the actual date for a specific day name based on selected date
  DateTime getDateForDay(String dayName) {
    DateTime baseDate = selectedDay.value ?? DateTime.now();

    // Map day names to weekday numbers (1 = Monday, 7 = Sunday)
    const dayToWeekday = {
      AppString.monday_text: 1,
      AppString.tuesday_text: 2,
      AppString.wednesday_text: 3,
      AppString.thursday_text: 4,
      AppString.friday_text: 5,
      AppString.saturday_text: 6,
      AppString.sunday_text: 7,
    };

    int selectedWeekday = baseDate.weekday;
    int targetWeekday = dayToWeekday[dayName]!;

    // Calculate days to add (0-6) - ALWAYS FORWARD
    // This ensures we only get future dates from the selected date
    int daysToAdd = (targetWeekday - selectedWeekday + 7) % 7;

    return baseDate.add(Duration(days: daysToAdd));
  }

  void toggleDay(String day, bool value) async {
    // Check if there's a schedule for this day FIRST
    DateTime dayDate = getDateForDay(day);
    String dateStr = _formatDateForComparison(dayDate);

    // Find schedule for this specific date
    var schedule = scheduleList.firstWhereOrNull((s) {
      String scheduleDateStr = _formatDateForComparison(DateTime.parse(s['date']));
      return scheduleDateStr == dateStr;
    });

    // If schedule exists, hit the API to update isActive
    if (schedule != null && schedule['_id'] != null) {
      String scheduleId = schedule['_id'];

      // Update UI optimistically
      workingDays[day] = value;
      workingDays.refresh();

      try {
        print("🔄 Updating isActive for schedule $scheduleId to: $value");
        print("📍 Switch: ${value ? 'ON (Open)' : 'OFF (Closed)'}");

        final response = await ApiService.patch(
          "${ApiEndPoint.scheduleProvider}/$scheduleId",
          body: {
            "isActive": value,
          },
          header: {
            "Authorization": "Bearer ${LocalStorage.token}",
          },
        );

        if (response.statusCode == 200) {
          print("✅ Schedule isActive updated to: $value");
          Get.snackbar(
            AppString.successful,
            value ? 'Schedule opened for $day' : 'Schedule closed for $day',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        } else {
          // Revert UI on failure
          workingDays[day] = !value;
          workingDays.refresh();

          Get.snackbar(
            AppString.error,
            AppString.failed_schedule,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        // Revert UI on error
        workingDays[day] = !value;
        workingDays.refresh();

        print("❌ Error updating schedule: $e");
        Get.snackbar(
          AppString.error,
          AppString.failed_schedule,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      // No schedule exists - just update UI (no API call)
      workingDays[day] = value;
      workingDays.refresh();
      print("ℹ️ No schedule exists for $day - toggle is UI only");
    }
  }

  void _applySchedulesToWeek() {
    DateTime baseDate = selectedDay.value ?? DateTime.now();
    DateTime startDate = DateTime(baseDate.year, baseDate.month, baseDate.day);

    workingDays.updateAll((key, value) => false);
    workingTimes.updateAll((key, value) => {"start": "", "end": ""});

    print("🔍 Applying schedules for next 7 days starting from: ${_formatDateForComparison(startDate)}");

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String dateStr = _formatDateForComparison(currentDate);
      String dayName = _getDayNameFromWeekday(currentDate.weekday);

      // ✅ Compare using UTC date directly (since we store same calendar date in UTC)
      var schedule = scheduleList.firstWhereOrNull((s) {
        DateTime scheduleDateUtc = DateTime.parse(s['date']).toUtc();
        // Extract just the date part from UTC (year-month-day)
        String scheduleDateStr = "${scheduleDateUtc.year}-${scheduleDateUtc.month.toString().padLeft(2, '0')}-${scheduleDateUtc.day.toString().padLeft(2, '0')}";
        return scheduleDateStr == dateStr;
      });

      if (schedule != null) {
        // Parse UTC time and convert to LOCAL time for display
        DateTime startTimeUtc = DateTime.parse(schedule['startTime']);
        DateTime endTimeUtc = DateTime.parse(schedule['endTime']);

        DateTime startTimeLocal = startTimeUtc.toLocal();
        DateTime endTimeLocal = endTimeUtc.toLocal();

        String startTimeStr = "${startTimeLocal.hour.toString().padLeft(2, '0')}:${startTimeLocal.minute.toString().padLeft(2, '0')}";
        String endTimeStr = "${endTimeLocal.hour.toString().padLeft(2, '0')}:${endTimeLocal.minute.toString().padLeft(2, '0')}";

        bool isActive = schedule['isActive'] ?? false;
        workingDays[dayName] = isActive;

        workingTimes[dayName] = {
          "start": startTimeStr,
          "end": endTimeStr,
        };

        print("✅ Applied schedule for $dayName ($dateStr): $startTimeStr - $endTimeStr (Local) | isActive: $isActive");
      } else {
        workingDays[dayName] = false;
        workingTimes[dayName] = {"start": "", "end": ""};
        print("❌ No schedule for $dayName ($dateStr)");
      }
    }

    workingDays.refresh();
    workingTimes.refresh();
  }

  String _formatDateForComparison(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Get formatted working time for display
  String getWorkingTime(String day) {
    if (workingTimes.containsKey(day)) {
      final times = workingTimes[day]!;
      String start = times['start'] ?? "";
      String end = times['end'] ?? "";

      // If both are empty, show "Select Schedule"
      if (start.isEmpty && end.isEmpty) {
        return "Select Schedule";
      }
      // If one is empty, still show "Select Schedule"
      if (start.isEmpty || end.isEmpty) {
        return "Select Schedule";
      }
      // Both are filled, show the time range
      return "$start - $end";
    }
    return "Select Schedule";
  }

  // Get start time for a specific day
  String getStartTime(String day) {
    final times = workingTimes[day]!;
    String start = times['start'] ?? "";
    if (workingTimes.containsKey(day)) {
      return workingTimes[day]!['start'] ?? "07:00";
    }
    if (start=="") {
      return "Select start time";
    }
    return "07:00";
  }

  // Get end time for a specific day
  String getEndTime(String day) {
    final times = workingTimes[day]!;
    String end = times['end'] ?? "Select Start Time";
    if (workingTimes.containsKey(day)) {
      return workingTimes[day]!['end'] ?? "22:00";
    }
    if (end.isEmpty) {
      return "Select end Time";
    }
    return "22:00";
  }

  // Update start time for a specific day
  void updateStartTime(String day, String startTime) {
    if (!workingTimes.containsKey(day)) {
      workingTimes[day] = {"start": "07:00", "end": "22:00"};
    }
    workingTimes[day]!['start'] = startTime;
    workingTimes.refresh();
  }

  // Update end time for a specific day
  void updateEndTime(String day, String endTime) {
    if (!workingTimes.containsKey(day)) {
      workingTimes[day] = {"start": "07:00", "end": "22:00"};
    }
    workingTimes[day]!['end'] = endTime;
    workingTimes.refresh();
  }

  // Update working time for a specific day
  void updateWorkingTime(String day, String startTime, String endTime) {
    if (!workingTimes.containsKey(day)) {
      workingTimes[day] = {};
    }
    workingTimes[day]!['start'] = startTime;
    workingTimes[day]!['end'] = endTime;
    workingTimes.refresh();
  }

  // Show start time picker
  void showStartTimePicker(String day) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppString.start_time, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.minPositive,
          height: 300,
          child: ListView.builder(
            itemCount: timeOptions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(timeOptions[index]),
                onTap: () {
                  updateStartTime(day, timeOptions[index]);
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Show end time picker
  void showEndTimePicker(String day) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppString.end_time, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.minPositive,
          height: 300,
          child: ListView.builder(
            itemCount: timeOptions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(timeOptions[index]),
                onTap: () {
                  updateEndTime(day, timeOptions[index]);
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Fetch schedules from API - FETCHES FOR NEXT 7 DAYS FROM SELECTED DATE
  Future<void> fetchSchedules() async {
    try {
      isLoading.value = true;

      // Get the selected date or use today
      DateTime baseDate = selectedDay.value ?? DateTime.now();

      // Normalize to start of day
      DateTime startDate = DateTime(baseDate.year, baseDate.month, baseDate.day);

      // Format start date in UTC ISO format
      DateTime startDateUtc = DateTime.utc(startDate.year, startDate.month, startDate.day);
      String formattedDate = startDateUtc.toIso8601String();

      // Build URL with date query parameter
      String url = "${ApiEndPoint.scheduleProvider}?date=$formattedDate";

      print("📥 Fetching schedules starting from date: $formattedDate");
      print("🔗 URL: $url");

      final response = await ApiService.get(
        url,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          scheduleList.value = List<Map<String, dynamic>>.from(data['data']);

          print("✅ Fetched ${scheduleList.length} schedules");

          // Apply schedules to the next 7 days from selected date
          _applySchedulesToWeek();
        }
      } else {
        print("⚠️ Failed to fetch schedules. Status: ${response.statusCode}");
        // Reset UI when no schedules found
        _resetScheduleUI();
      }

    } catch (e) {
      print("❌ Error fetching schedules: $e");
      _resetScheduleUI();
    } finally {
      isLoading.value = false;
    }
  }

  // Reset schedule UI when no data
  void _resetScheduleUI() {
    workingDays.updateAll((key, value) => false);
    workingTimes.updateAll((key, value) => {"start": "", "end": ""});
    workingDays.refresh();
    workingTimes.refresh();
  }

  // Helper: Get day name from weekday number
  String _getDayNameFromWeekday(int weekday) {
    const dayNames = {
      1: AppString.monday_text,
      2: AppString.tuesday_text,
      3: AppString.wednesday_text,
      4: AppString.thursday_text,
      5: AppString.friday_text,
      6: AppString.saturday_text,
      7: AppString.sunday_text,
    };
    return dayNames[weekday]!;
  }

  // Create Schedule API Call - WITH CORRECT DATE FOR EACH DAY
  Future<void> createSchedule(String day) async {
    if (!workingTimes.containsKey(day)) {
      Get.snackbar(
        AppString.error,
        AppString.working_time,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    String startTime = workingTimes[day]!['start'] ?? "";
    String endTime = workingTimes[day]!['end'] ?? "";

    if (startTime.isEmpty || endTime.isEmpty) {
      Get.snackbar(
        AppString.error,
        AppString.start_time_end_time,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Get the LOCAL date for this day
    DateTime scheduleDate = getDateForDay(day);

    List<String> startParts = startTime.split(':');
    List<String> endParts = endTime.split(':');

    // Create LOCAL DateTime (user's selected time)
    DateTime startDateTimeLocal = DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );

    DateTime endDateTimeLocal = DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    // Handle case where end time is past midnight (next day)
    if (endDateTimeLocal.isBefore(startDateTimeLocal) ||
        endDateTimeLocal.isAtSameMomentAs(startDateTimeLocal)) {
      endDateTimeLocal = endDateTimeLocal.add(Duration(days: 1));
    }

    // Convert Local to UTC for API
    DateTime startDateTimeUtc = startDateTimeLocal.toUtc();
    DateTime endDateTimeUtc = endDateTimeLocal.toUtc();

    // ✅ FIX: Create date as UTC with SAME calendar date (not converted from local)
    // This ensures Dec 7 local = Dec 7 in UTC date field
    DateTime scheduleDateUtc = DateTime.utc(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      0, 0, 0, // midnight UTC
    );

    Map<String, dynamic> body = {
      "date": scheduleDateUtc.toIso8601String(),  // Will be 2025-12-07T00:00:00.000Z
      "startTime": startDateTimeUtc.toIso8601String(),
      "endTime": endDateTimeUtc.toIso8601String(),
      "duration": 60,
    };

    try {
      isLoading.value = true;

      print("📅 Creating schedule for $day");
      print("📅 Local Date: ${scheduleDate.year}-${scheduleDate.month.toString().padLeft(2, '0')}-${scheduleDate.day.toString().padLeft(2, '0')}");
      print("📅 Date (UTC): ${scheduleDateUtc.toIso8601String()}");
      print("⏰ Local Time: $startTime - $endTime");
      print("⏰ Start UTC: ${startDateTimeUtc.toIso8601String()}");
      print("⏰ End UTC: ${endDateTimeUtc.toIso8601String()}");

      final response = await ApiService.post(
        ApiEndPoint.scheduleProvider,
        body: body,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if(response.statusCode == 200) {
        print("✅ Schedule created successfully!");
        Get.snackbar(
          AppString.successful,
          'Schedule created for $day on ${scheduleDate.toString().split(' ')[0]}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await fetchSchedules();
        workingTimes.refresh();
      } else {
        Get.snackbar(
          AppString.error,
          '${AppString.failed_schedule}:${response.message}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      Get.snackbar(
        AppString.error,
        '${AppString.failed_schedule}: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper: month number → month name
  String _monthName(int month) {
    const months = [
      AppString.january_text, AppString.february_text, AppString.march_text, AppString.april_text, AppString.may_text,
      AppString.june_text, AppString.july_text, AppString.august_text, AppString.september_text, AppString.october_text, AppString.november_text, AppString.december_text
    ];
    return months[month - 1];
  }

  // Helper: month name → month number
  int _monthIndex(String month) {
    const months = [
      AppString.january_text, AppString.february_text, AppString.march_text, AppString.april_text, AppString.may_text,
      AppString.june_text, AppString.july_text, AppString.august_text, AppString.september_text,
      AppString.october_text, AppString.november_text, AppString.december_text
    ];
    return months.indexOf(month) + 1;
  }
}