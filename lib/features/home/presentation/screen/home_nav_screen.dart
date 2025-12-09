import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/home_nav_controller.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/home_screen.dart';
import 'package:haircutmen_user_app/features/message/presentation/screen/chat_screen.dart';
import 'package:haircutmen_user_app/features/overview/presentation/screen/overview_screen.dart';
import 'package:haircutmen_user_app/features/scan/presentation/screen/scan_screen.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../profile/presentation/screen/profile_screen.dart';
import '../controller/home_controller.dart';

class HomeNavScreen extends StatelessWidget {
  HomeNavScreen({super.key}) {
    Get.put(HomeNavController());
  }

  final List<Map<String, String>> _navItems = [
    {"icon": "assets/icons/home.svg", "label": AppString.home},
    {"icon": "assets/icons/overview_icon.svg", "label": AppString.overview},
    {"icon": "assets/icons/scan_icon.svg", "label": AppString.qr_text},
    {"icon": "assets/icons/message_icon.svg", "label": AppString.message},
    {"icon": "assets/icons/profile.svg", "label": AppString.profile},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeNavController>();
    final homeController= Get.find<HomeController>();

    return Obx(
          () => Scaffold(
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            controller.selectedIndex.value == 0 ? HomeScreen() : Container(),
            controller.selectedIndex.value == 1 ? OverviewScreen() : Container(),
            controller.selectedIndex.value == 2 ? QRScannerScreen() : Container(),
            controller.selectedIndex.value == 3 ? ChatListScreen() : Container(),
            controller.selectedIndex.value == 4 ? ProfileScreen() : Container(),
          ],
        ),

        /// 🟢 Bottom Navigation Bar
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              currentIndex: controller.selectedIndex.value,
              onTap: controller.changeIndex,
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: Colors.black,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 10.sp,
              ),
              iconSize: 24,
              items: List.generate(_navItems.length, (index) {
                final isSelected = controller.selectedIndex.value == index;
                return BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child:
                    _navItems[index]["label"] == AppString.message
                        ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset(
                          _navItems[index]["icon"]!,
                          width: isSelected ? 28.w : 24.w,
                          height: isSelected ? 28.h : 24.h,
                          colorFilter: ColorFilter.mode(
                            isSelected ? AppColors.primaryColor : Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),

                        /// 🔴 PERFECT BADGE
                        if(homeController.message.value > 0)
                        Positioned(
                          right: -6.r,   // Proper right alignment
                          top: -8.r,     // Proper top alignment
                          child: Container(
                            padding: EdgeInsets.all(4.r), // Ensures circle shape
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: CommonText(
                              text: Get.find<HomeController>().message.value.toString(),      // dynamic value here
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                        :

                    SvgPicture.asset(
                      _navItems[index]["icon"]!,
                      width: isSelected ? 28.w : 24.w,
                      height: isSelected ? 28.h : 24.h,
                      colorFilter: ColorFilter.mode(
                        isSelected ? AppColors.primaryColor : Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  label: _navItems[index]["label"]!.tr,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
