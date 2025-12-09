import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import '../../../../../config/route/app_routes.dart';
import '../../../../component/app_storage/show_image_full.dart';
import '../../../../component/other_widgets/item.dart';
import '../../../../component/text/common_text.dart';
import '../controller/profile_controller.dart';
import '../../../../../utils/constants/app_string.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  CustomAppBar(title: AppString.profile,showBackButton: false,),
                  /// User Profile Image here
                  GestureDetector(
                    onTap: (){
                      if (controller.images.value != "") {
                        // Convert single image to list
                        List<String> imageList = [ApiEndPoint.socketUrl + controller.images.value];

                        showDialog(
                          context: Get.context!,
                          builder: (_) => FullScreenImageViewer(
                            images: imageList,
                          ),
                        );
                      }
                      else{
                        List<String> imageList = ["assets/images/profile_image.jpg"];

                        showDialog(
                          context: Get.context!,
                          builder: (_) => FullScreenImageViewer(
                            images: imageList,
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: Obx(
                        ()=> CircleAvatar(
                          radius: 60.r,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: controller.images.value != ""?Image.network(
                              ApiEndPoint.socketUrl + controller.images.value,
                              width: 120.w,
                              height: 120.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/profile_image.jpg",
                                  width: 120.w,
                                  height: 120.h,
                                  fit: BoxFit.cover,
                                );
                              },
                            ):Image.asset(
                              "assets/images/profile_image.jpg",
                              width: 120.w,
                              height: 120.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                        ,
                      )

                    ),
                  ),
                  SizedBox(height: 9,),
                  /// User Name here
                  Obx(
                    ()=> CommonText(
                      text: controller.name.value.toString(),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 6,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                      ()=> CommonText(
                          text: controller.category.value,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24.sp,
                      ),
                      SizedBox(width: 4.w),
                      Obx(
                        ()=> CommonText(
                          text: controller.rating.value.toString(),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      CommonText(
                        text: "(${controller.review.value})",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black200,
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  /// Edit Profile item here
                  Item(
                    image: "assets/icons/profile.svg",
                    title: AppString.personal_information,
                    onTap: () => Get.toNamed(AppRoutes.personal_information),
                  ),

                  /// Setting item here
                  Item(
                    image: "assets/icons/services_icon.svg",
                    title: AppString.service_information,
                    onTap: () => Get.toNamed(AppRoutes.service_person_screen),
                  ),

                  /// Language item here
                  Item(
                    image: "assets/icons/language_icon.svg",
                    title: AppString.language,
                    onTap: () => Get.toNamed(AppRoutes.language_screen),
                  ),

                  /// Privacy Policy item here
                  Item(
                    image: "assets/icons/setting_icon.svg",
                    title: AppString.setting,
                    onTap: () => Get.toNamed(AppRoutes.setting),
                  ),

                  /// Terms of Service item here
                  Item(
                    image: "assets/icons/contract_icon.svg",
                    title: AppString.contact_support,
                    onTap: () => Get.toNamed(AppRoutes.contract_screen),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
