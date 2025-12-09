import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/home/widget/home_custom_button.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';

import '../../../../component/app_storage/show_image_full.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../utils/constants/app_string.dart';
import '../controller/profile_controller.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:GetBuilder<ProfileController>(
        init: ProfileController(),
        builder: (controller) => Container(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar(title: AppString.personal_information,),
                  SizedBox(height: 30,),
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
                        List<String> imageList=["assets/images/profile_image.jpg"];
                        showDialog(
                            context: Get.context!,
                            builder: (_)=>FullScreenImageViewer(
                                images: imageList
                            )
                        );
                      }
                    },
                    child: Center(
                      child: Obx(
                        ()=> CircleAvatar(
                          radius: 60.sp,
                          backgroundColor: Colors.transparent,
                          backgroundImage: controller.images.value == ""
                              ? const AssetImage("assets/images/profile_image.jpg") as ImageProvider
                              : NetworkImage(ApiEndPoint.socketUrl + controller.images.value),
                        ),
                      ),
                      ),
                  ),
                  SizedBox(height: 26,),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14),
                    constraints: BoxConstraints(),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ]
                    ),
                    child: Obx(
                      ()=> Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InformationRow(title: AppString.full_name,value: controller.name.value.toString(),),
                          SizedBox(height: 12),
                          InformationRow(title: AppString.email,value: controller.email.value,),
                          SizedBox(height: 12),
                          InformationRow(title: AppString.contact,value: controller.fullNumber.value,),
                          SizedBox(height: 12),
                          InformationRow(title: AppString.location,value: controller.location.value,),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h,),
                  CustomButton
                    (text: AppString.edit_profile_button,
                      isSelected: true,
                      onTap: (){
                      Get.toNamed(AppRoutes.editProfile);
                      })
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}

class InformationRow extends StatelessWidget {
  String title;
  String value;

  InformationRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 100,
          child: CommonText(
              text: title,
            fontSize: 14,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.w400,
            color: AppColors.black400,
          ),
        ),
        Expanded(
          child: CommonText(
            text: ": $value",
            fontSize: 14,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.w400,
            color: AppColors.black400,
          ),
        ),
      ],
    );
  }
}
