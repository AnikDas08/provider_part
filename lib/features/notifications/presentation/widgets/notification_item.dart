import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../component/text/common_text.dart';
import '../../data/model/notification_model.dart';
import '../../../../utils/extensions/extension.dart';
import '../../../../utils/extensions/date_time_extension.dart';
import 'package:intl/intl.dart';
import '../../../../utils/constants/app_colors.dart';
import '../controller/notifications_controller.dart';

class NotificationItem extends StatefulWidget {
  const NotificationItem({super.key, required this.item});

  final NotificationModel item;

  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      try {
        return DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateString).toLocal();
      } catch (e) {
        return DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Call notification tap handler from controller
        print("😍😍😍😍😍😍😍${widget.item}");
        NotificationsController.instance.onNotificationTap(widget.item);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Row(
          children: [
            /// icon or image here
            CircleAvatar(
              backgroundColor: AppColors.background,
              radius: 35.r,
              child: const ClipOval(
                child: Icon(Icons.date_range, color: AppColors.primaryColor),
              ),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Notification Title here
                      Flexible(
                        child: CommonText(
                          text: widget.item.type ?? '',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                      ),

                      /// Notification Time here
                      CommonText(
                        text: widget.item.createdAt?.isNotEmpty == true
                            ? _parseDate(widget.item.createdAt!).formatTimeAgo()
                            : 'Just now',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        textAlign: TextAlign.start,
                        color: AppColors.black,
                        maxLines: 1,
                      ),
                    ],
                  ),

                  /// Notification Message here
                  CommonText(
                    text: widget.item.title ?? '',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    maxLines: 2,
                    color: AppColors.black,
                    textAlign: TextAlign.start,
                    bottom: 10,
                    top: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}