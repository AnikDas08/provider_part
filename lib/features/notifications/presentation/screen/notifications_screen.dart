import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';

import '../../../../component/other_widgets/common_loader.dart';
import '../../../../component/other_widgets/no_data.dart';
import '../../../../utils/app_bar/custom_appbars.dart';
import '../../../home/presentation/controller/home_controller.dart';
import '../../data/model/notification_model.dart';
import '../controller/notifications_controller.dart';
import '../widgets/notification_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.find<HomeController>().countNotification();
        Get.back();
        return true;
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            appBar: CustomAppBar(
              title: AppString.notifications,
              onBackTap: () {
                Get.find<HomeController>().countNotification();
                Get.back();
              },
            ),

            body: GetBuilder<NotificationsController>(
              builder: (controller) {
                return controller.isLoading
                    ? const CommonLoader()
                    : controller.notifications.isEmpty
                    ? const NoData()
                    : ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.sp,
                    vertical: 10.sp,
                  ),
                  itemCount: controller.isLoadingMore
                      ? controller.notifications.length + 1
                      : controller.notifications.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index > controller.notifications.length) {
                      return CommonLoader(size: 40, strokeWidth: 2);
                    }
                    NotificationModel item =
                    controller.notifications[index];

                    return NotificationItem(item: item);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
