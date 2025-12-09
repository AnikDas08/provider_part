// home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../../widget/home_custom_button.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                // Header with profile and online status
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Profile Image
                      Obx(
                            () => CircleAvatar(
                              radius: 24.r,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: controller.image.value != ""
                                    ? Image.network(
                                  ApiEndPoint.socketUrl + controller.image.value,
                                  width: 48.w,
                                  height: 48.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/images/profile_image.jpg",
                                      width: 48.w,
                                      height: 48.h,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ):
                                Image.asset(
                                  "assets/images/profile_image.jpg",
                                  width: 48.w,
                                  height: 48.h,
                                  fit: BoxFit.cover,
                                )
                              ),
                            )
                      ),
                      SizedBox(width: 12.w),
                      // Profile Info
                      Expanded(
                        child: Obx(
                              () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                text: controller.name.value,
                                fontSize: 12.sp,
                                color: Colors.grey[600]!,
                              ),
                              CommonText(
                                text: AppString.welcome_text,
                                fontSize: 16.sp,
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Online Status Toggle
                      Row(
                        children: [
                          CommonText(
                            text: AppString.online_voew,
                            fontSize: 12.sp,
                            color: controller.isOnline ? AppColors.primaryColor : Colors.grey[600]!,
                          ),
                          SizedBox(width: 4.w),
                          Switch(
                            value: controller.isOnline,
                            onChanged: (val) => controller.onlineStatus(),
                            activeThumbColor: AppColors.primaryColor,
                            activeTrackColor: AppColors.primaryColor.withOpacity(0.3),
                            inactiveThumbColor: Colors.grey[400],
                            inactiveTrackColor: Colors.grey[300],
                            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.notifications);
                          Get.find<HomeController>().countNotification();
                        },
                        child: Obx(
                              () => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: AppColors.black300,
                                size: 24.sp,
                              ),
                              if (controller.notificationCount.value > 0)
                                Positioned(
                                  right: -4.w,
                                  top: -4.h,
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.background,
                                        width: 1.5.w,
                                      ),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 16.w,
                                      minHeight: 16.h,
                                    ),
                                    child: Center(
                                      child: Text(
                                        controller.notificationCount.value.toString(),
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w600,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )

                      ),
                    ],
                  ),
                ),

                // Calendar
                Container(
                  margin: EdgeInsets.all(16.w),
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
                  child: Opacity(
                    opacity: controller.selectedFilter != 0 ? 0.5 : 1.0, // Gray out when not Upcoming
                    child: IgnorePointer(
                      ignoring: controller.selectedFilter != 0, // Disable interaction when not Upcoming
                      child: TableCalendar<Event>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: controller.focusedDay,
                        selectedDayPredicate: (day) {
                          // Only show selection for Upcoming filter
                          if (controller.selectedFilter != 0) {
                            return false;
                          }
                          return isSameDay(controller.selectedDay, day);
                        },
                        calendarFormat: CalendarFormat.week,
                        startingDayOfWeek: StartingDayOfWeek.sunday,
                        onDaySelected: controller.selectedFilter == 0
                            ? controller.onDaySelected
                            : null, // Disable callback when not Upcoming
                        onPageChanged: (focusedDay) {
                          if (controller.selectedFilter == 0) {
                            controller.onPageChanged(focusedDay);
                          }
                        },
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          selectedDecoration: BoxDecoration(
                            color: controller.selectedFilter == 0
                                ? AppColors.primaryColor
                                : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: controller.selectedFilter == 0
                                ? AppColors.primaryColor.withOpacity(0.5)
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: TextStyle(
                            fontSize: 14.sp,
                            color: controller.selectedFilter != 0
                                ? Colors.grey.shade400
                                : Colors.black,
                          ),
                          weekendTextStyle: TextStyle(
                            fontSize: 14.sp,
                            color: controller.selectedFilter != 0
                                ? Colors.grey.shade400
                                : Colors.black,
                          ),
                          selectedTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          leftChevronVisible: controller.selectedFilter == 0,
                          rightChevronVisible: controller.selectedFilter == 0,
                          titleTextStyle: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: controller.selectedFilter == 0
                                ? AppColors.primaryColor
                                : Colors.grey.shade400,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: controller.selectedFilter == 0
                                ? AppColors.primaryColor
                                : Colors.grey.shade400,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: controller.selectedFilter == 0
                                ? AppColors.primaryColor
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Filter Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppString.upcoming_button,
                          fontSize: 12,
                          height: 34,
                          isSelected: controller.selectedFilter == 0,
                          onTap: () => controller.changeFilter(0),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomButton(
                          text: AppString.pending_button,
                          fontSize: 12,
                          height: 34,
                          isSelected: controller.selectedFilter == 1,
                          onTap: () => controller.changeFilter(1),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomButton(
                          text: AppString.Cancel_button,
                          fontSize: 12,
                          height: 34,
                          isSelected: controller.selectedFilter == 2,
                          onTap: () => controller.changeFilter(2),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),


                SizedBox(height: 8.h),

                // Booking List with Loading State and Pagination
                Expanded(
                  child: controller.isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                      : controller.getFilteredBookings().isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        CommonText(
                          text: AppString.nobookingfound,
                          fontSize: 16.sp,
                          color: Colors.grey[600]!,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  )
                      : RefreshIndicator(
                    onRefresh: controller.refreshBookings,
                    color: AppColors.primaryColor,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: controller.scrollController, // Important for pagination!
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: controller.getFilteredBookings().length +
                          (controller.isLoadingMore ? 1 : 0), // Add 1 for loading indicator
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end
                        if (index == controller.getFilteredBookings().length) {
                          return _buildLoadingIndicator();
                        }

                        final booking = controller.getFilteredBookings()[index];
                        return _buildBookingCard(booking, controller);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Loading indicator widget for pagination
  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          CommonText(
            text: 'Loading more...',
            fontSize: 12.sp,
            color: AppColors.black300,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, HomeController controller) {
    return GestureDetector(
      onTap: () {
        if (controller.selectedFilter == 0) {
          Get.toNamed(
            AppRoutes.upcomingdetail_sscreen,
            arguments: {'bookingId': controller.getFullBookingId(booking)},
          );
        } else if (controller.selectedFilter == 1) {
          Get.toNamed(
            AppRoutes.view_detail_pending,
            arguments: {'bookingId': controller.getFullBookingId(booking)},
          );
        } else {
          Get.toNamed(
            AppRoutes.canceldetails_screen,
            arguments: {'bookingId': controller.getFullBookingId(booking)},
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 76.w,
              height: 87.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.zero,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: controller.getUserImage(booking).startsWith('http') ||
                    controller.getUserImage(booking).startsWith('/')
                    ? Image.network(
                  ApiEndPoint.imageUrl + controller.getUserImage(booking),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/noImage.png",
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
                  "assets/images/noImage.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(width: 12.w),
            // Booking Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: controller.getUserName(booking),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black400,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/propetion_icon.svg",
                        width: 16.w,
                        height: 16.h,
                        color: AppColors.black400,
                      ),
                      SizedBox(width: 4.w),
                      CommonText(
                        text: controller.getServiceNames(booking),
                        fontSize: 14.sp,
                        color: AppColors.black400,
                        fontWeight: FontWeight.w400,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/day_icon.svg",
                        width: 16.w,
                        height: 16.h,
                        color: AppColors.black200,
                      ),
                      SizedBox(width: 4.w),
                      CommonText(
                        text: controller.getFormattedDate(booking),
                        fontSize: 12.sp,
                        color: AppColors.black200,
                        fontWeight: FontWeight.w400,
                      ),
                      SizedBox(width: 12.w),
                      SvgPicture.asset(
                        "assets/icons/time_icon.svg",
                        width: 16.w,
                        height: 16.h,
                        color: AppColors.black200,
                      ),
                      SizedBox(width: 4.w),
                      CommonText(
                        text: controller.getFormattedTime(booking),
                        fontSize: 12.sp,
                        color: AppColors.black200,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      CommonText(
                        text: '${AppString.bookingid} ${controller.getBookingId(booking)}',
                        fontSize: 12.sp,
                        color: AppColors.black300,
                        fontWeight: FontWeight.w400,
                      ),
                      SizedBox(width: 12.w),
                    ],
                  ),
                ],
              ),
            ),
            // View Button
            CustomButton(
              text: AppString.view_button,
              isSelected: true,
              onTap: () => controller.viewBookingDetails(booking),
              isSmall: true,
              height: 24,
            ),
          ],
        ),
      ),
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