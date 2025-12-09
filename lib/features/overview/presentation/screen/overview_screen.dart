import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../utils/constants/app_colors.dart';
import '../controller/overview_controller.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OverviewController>(
      init: OverviewController(),
      builder: (controller) {
        return SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                // TABLE CALENDAR IMPLEMENTATION
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  //djslkjfkds
                  //dfdf
                  //dfdsfds
                  //dfdfdf
                  child: Obx(() => TableCalendar<Event>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: controller.focusedDay.value,
                    selectedDayPredicate: (day) {
                      // Only show selected color if selectedDay is not null
                      if (controller.selectedDay.value == null) {
                        return false;
                      }
                      return isSameDay(controller.selectedDay.value, day);
                    },
                    calendarFormat: CalendarFormat.week,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    onDaySelected: controller.onDaySelected,
                    onPageChanged: (focusedDay) {
                      controller.focusedDay.value = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(fontSize: 14.sp),
                      weekendTextStyle: TextStyle(fontSize: 14.sp),
                      selectedTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronVisible: true,
                      rightChevronVisible: true,
                      titleTextStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor
                      ),
                    ),
                  )),
                ),

                SizedBox(height: 16.h),

                // Tab Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(() => GestureDetector(
                          onTap: () => controller.changeTab(0),
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 0
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                  color: controller.selectedTab.value == 0
                                      ? AppColors.primaryColor
                                      : AppColors.primaryColor,
                                  width: 1
                              ),
                            ),
                            child: Center(
                              child: CommonText(
                                text: AppString.overview_button,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: controller.selectedTab.value == 0
                                    ? Colors.white
                                    : AppColors.primaryColor,
                              ),
                            ),
                          ),
                        )),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Obx(() => GestureDetector(
                          onTap: () => controller.changeTab(1),
                          child: Container(
                            height: 38.h,
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 1
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                  color: controller.selectedTab.value == 1
                                      ? AppColors.primaryColor
                                      : AppColors.primaryColor,
                                  width: 1
                              ),
                            ),
                            child: Center(
                              child: CommonText(
                                text: AppString.working_button,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: controller.selectedTab.value == 1
                                    ? Colors.white
                                    : AppColors.primaryColor,
                              ),
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                ),

                // Content based on selected tab
                Expanded(
                  child: Obx(() {
                    if (controller.selectedTab.value == 0) {
                      // My Overview Tab Content
                      return Column(
                        children: [
                          // Dropdown Filters
                          SizedBox(height: 36.h,),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showMonthPicker(context, controller),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Obx(() => CommonText(
                                            text: controller.selectedMonth.value.isEmpty
                                                ? AppString.months
                                                : controller.selectedMonth.value,
                                            fontSize: 14.sp,
                                            color: controller.selectedMonth.value.isEmpty
                                                ? Colors.grey[500]!
                                                : Colors.grey[600]!,
                                            fontWeight: controller.selectedMonth.value.isEmpty
                                                ? FontWeight.w400
                                                : FontWeight.w500,
                                          )),
                                          Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showYearPicker(context, controller),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Obx(() => CommonText(
                                            text: controller.selectedYear.value,
                                            fontSize: 14.sp,
                                            color: Colors.grey[600]!,
                                          )),
                                          Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Statistics
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  text: AppString.statistics,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800]!,
                                ),
                                SizedBox(height: 20.h),
                                _buildStatRow(AppString.successful_booking, controller.successfulBooking.value.toString()),
                                SizedBox(height: 16.h),
                                _buildStatRow(AppString.cancel_booking, controller.canceledBooking.value.toString()),
                                SizedBox(height: 16.h),
                                _buildStatRow(AppString.total_amount, '${controller.totalMoneyEarned.value} RSD'),
                              ],
                            )),
                          ),
                        ],
                      );
                    } else {
                      // Working Time Tab Content - DYNAMIC ORDERING
                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Obx(() {
                            // Force rebuild when selectedDay changes
                            controller.selectedDay.value;
                            List<String> orderedDays = controller.getOrderedDays();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Build working day cards in dynamic order
                                ...orderedDays.map((day) => _buildWorkingDayCard(day, controller)),
                                SizedBox(height: 20.h),
                              ],
                            );
                          }),
                        ),
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: CommonText(
            text: title,
            textAlign: TextAlign.start,
            fontSize: 12.sp,
            color: AppColors.black400,
            fontWeight: FontWeight.w400,
          ),
        ),
        CommonText(
          text: ': $value',
          fontSize: 12.sp,
          color: AppColors.black400,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }

  Widget _buildWorkingDayCard(String day, OverviewController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 18.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                text: day,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black400,
              ),
              // Use Obx to make switch reactive
              SizedBox(
                height: 40,
                child: Transform.scale(
                  scale:0.8,
                  child: Obx(() => Switch(
                    value: controller.workingDays[day] ?? false,
                    onChanged: (val) {
                      controller.toggleDay(day, val);
                    },
                    activeThumbColor: AppColors.primaryColor,
                    activeTrackColor: AppColors.red100,
                    inactiveThumbColor: AppColors.gray,
                    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    thumbIcon: WidgetStateProperty.all(
                      Icon(
                        Icons.circle,
                        size: 40,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )),
                ),
              ),
            ],
          ),
          // Show time input when day is working
          Obx(() {
            bool isWorking = controller.workingDays[day] ?? false;
            if (isWorking) {
              return Column(
                children: [
                  SizedBox(height: 8.h,),
                  GestureDetector(
                    onTap: () => _showTimeDialog(Get.context!, controller, day),
                    child: Container(
                      height: 34.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommonText(
                            text: controller.getWorkingTime(day),
                            fontSize: 14.sp,
                            color: Colors.grey[600]!,
                          ),
                          Icon(Icons.timer_outlined, size: 18.sp, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return SizedBox(height: 0);
            }
          })
        ],
      ),
    );
  }

  void _showTimeDialog(BuildContext context, OverviewController controller, String day) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          contentPadding: EdgeInsets.all(24.w),
          content: SizedBox(
            width: 300.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Start Time Dropdown
                Obx(() {
                  String startTimeText = controller.getStartTime(day);
                  bool isPlaceholder = startTimeText == AppString.start_time;

                  return GestureDetector(
                    onTap: () {
                      controller.showStartTimePicker(day);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.workingTimes[day]!['start']!.isEmpty ? AppString.select_start_time : startTimeText,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isPlaceholder ? Colors.grey[500]! : Colors.black87,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 20.sp),
                        ],
                      ),
                    ),
                  );
                }),

                SizedBox(height: 16.h),

                // End Time Dropdown
                Obx(() {
                  String endTimeText = controller.getEndTime(day);
                  bool isPlaceholder = endTimeText == AppString.end_time;

                  return GestureDetector(
                    onTap: () {
                      controller.showEndTimePicker(day);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.workingTimes[day]!['end']!.isEmpty ? AppString.select_end_time : endTimeText,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isPlaceholder ? Colors.grey[500]! : Colors.black87,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 20.sp),
                        ],
                      ),
                    ),
                  );
                }),

                SizedBox(height: 24.h),

                // Submit Button with API Call
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                      Navigator.of(context).pop();
                      // Call the API to create schedule
                      await controller.createSchedule(day);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : CommonText(
                      text: AppString.save_button_text,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMonthPicker(BuildContext context, OverviewController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CommonText(text: AppString.select_month, fontSize: 18.sp, fontWeight: FontWeight.w600),
          content: SizedBox(
            width: double.minPositive,
            child: ListView(
              shrinkWrap: true,
              children: [
                // Add "No Month" option at the top
                ListTile(
                  leading: Obx(() => Icon(
                    controller.selectedMonth.value.isEmpty
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: controller.selectedMonth.value.isEmpty
                        ? AppColors.primaryColor
                        : Colors.grey,
                  )),
                  title: CommonText(
                    text: AppString.allMonthYear,
                    fontSize: 16.sp,
                    fontWeight: controller.selectedMonth.value.isEmpty
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  onTap: () {
                    controller.changeMonth(''); // Empty string = no month selected
                    Navigator.of(context).pop();
                  },
                ),
                Divider(),
                // Month options
                ...List.generate(12, (index) {
                  const months = [
                    AppString.january_text, AppString.february_text, AppString.march_text,
                    AppString.april_text, AppString.may_text, AppString.june_text,
                    AppString.july_text, AppString.august_text, AppString.september_text,
                    AppString.october_text, AppString.november_text, AppString.december_text
                  ];
                  return ListTile(
                    leading: Obx(() => Icon(
                      controller.selectedMonth.value == months[index]
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: controller.selectedMonth.value == months[index]
                          ? AppColors.primaryColor
                          : Colors.grey,
                    )),
                    title: CommonText(
                      text: months[index],
                      fontSize: 16.sp,
                      fontWeight: controller.selectedMonth.value == months[index]
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    onTap: () {
                      controller.changeMonth(months[index]);
                      Navigator.of(context).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showYearPicker(BuildContext context, OverviewController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CommonText(text: AppString.selected_year, fontSize: 18.sp, fontWeight: FontWeight.w600),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                int year = DateTime.now().year - 5 + index;
                return ListTile(
                  title: CommonText(text: year.toString(), fontSize: 16.sp),
                  onTap: () {
                    controller.changeYear(year.toString());
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// Event class for table_calendar
class Event {
  final String title;
  Event(this.title);

  @override
  String toString() => title;
}