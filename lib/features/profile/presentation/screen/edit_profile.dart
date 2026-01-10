import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/component/text_field/common_text_field.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';

import '../../../../utils/app_bar/custom_appbars.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../../../home/widget/home_custom_button.dart';
import '../controller/edit_profile_controller.dart';

class EditProfile extends StatelessWidget {
  EditProfile({super.key});
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      init: EditProfileController(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: controller.isProfileLoading
                ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomAppBar(
                      title: AppString.edit_profile_button,
                    ),
                    SizedBox(height: 20),
                    Obx(
                          () => Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: controller.profileImage.value != null
                                  ? Image.file(
                                controller.profileImage.value!,
                                width: 120.w,
                                height: 120.h,
                                fit: BoxFit.cover,
                              )
                                  : controller.profileData?.image != null
                                  ? Image.network(
                                ApiEndPoint.socketUrl +
                                    controller
                                        .profileData!.image!,
                                width: 120.w,
                                height: 120.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error,
                                    stackTrace) {
                                  return Image.asset(
                                    "assets/images/profile_image.jpg",
                                    width: 120.w,
                                    height: 120.h,
                                    fit: BoxFit.cover,
                                  );
                                },
                                loadingBuilder: (context, child,
                                    loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                    child:
                                    CircularProgressIndicator(
                                      value: loadingProgress
                                          .expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          loadingProgress
                                              .expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              )
                                  : Image.asset(
                                "assets/images/profile_image.jpg",
                                width: 120.w,
                                height: 120.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  controller.handleImageUpload();
                                },
                                child: SvgPicture.asset(
                                  "assets/icons/take_image.svg",
                                  width: 20.w,
                                  height: 20.h,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14),
                      constraints: BoxConstraints(),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CommonText(
                              text: AppString.edit_now,
                              fontSize: 18.sp,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(height: 12),
                          EditPersonal(
                            title: AppString.full_name,
                            controller: controller.nameController,
                          ),
                          SizedBox(height: 12),
                          // Phone number with country code picker
                          _buildPhoneNumberField(controller, context),
                          SizedBox(height: 12),
                          _buildLocationField(controller),
                          SizedBox(height: 20.h),
                          controller.isLoading
                              ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          )
                              : CustomButton(
                            text: AppString.submit_for_button,
                            isSelected: true,
                            onTap: () {
                              controller.editProfileRepo();
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Phone number field with country code picker
  Widget _buildPhoneNumberField(
      EditProfileController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.contact_number_text,
          fontSize: 14.sp,
          textAlign: TextAlign.left,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
        ),
        SizedBox(height: 6),
        Container(
          height: 50.h,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.black100, width: 1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            children: [
              // Country Code Picker with Flag
              InkWell(
                onTap: () {
                  controller.openCountryPicker(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      Obx(
                            () => Text(
                          controller.countryFlag.value,
                          style: TextStyle(fontSize: 24.sp),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Obx(
                            () => Text(
                          controller.countryCode.value,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black400,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.black300,
                        size: 24.sp,
                      ),
                    ],
                  ),
                ),
              ),
              // Divider
              Container(
                height: 50.h,
                width: 1,
                color: AppColors.black100,
              ),
              // Phone Number TextField
              Expanded(
                child: TextField(
                  controller: controller.numberController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.black400,
                  ),
                  decoration: InputDecoration(
                    hintText: AppString.hint_phone_number,
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.black200,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // Replace the EditPersonal widget for location with this:

  Widget _buildLocationField(EditProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.location_text,
          fontSize: 14.sp,
          textAlign: TextAlign.left,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
        ),
        SizedBox(height: 6),

        GetBuilder<EditProfileController>(
          builder: (ctrl) {
            return Column(
              children: [
                // Location Text Field
                CommonTextField(
                  controller: ctrl.primaryLocationController,
                  maxLines: 2,
                  hintTextColor: AppColors.black400,
                  onChanged: ctrl.onLocationChanged,
                  suffixIcon: ctrl.isLocationLoading
                      ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )
                      : ctrl.primaryLocationController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.black300,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      ctrl.primaryLocationController.clear();
                      ctrl.clearLocationSuggestions();
                    },
                  )
                      : null,
                ),

                // Location Suggestions Dropdown
                if (ctrl.locationSuggestions.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.black100),
                      borderRadius: BorderRadius.circular(4.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxHeight: 200.h,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: ctrl.locationSuggestions.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppColors.black100,
                      ),
                      itemBuilder: (context, index) {
                        final location = ctrl.locationSuggestions[index];
                        return InkWell(
                          onTap: () {
                            ctrl.selectLocation(location);
                            FocusScope.of(context).unfocus();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppColors.primaryColor,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CommonText(
                                        text: location.shortName,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.black400,
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                      ),
                                      if (location.displayName != location.shortName)
                                        CommonText(
                                          text: location.displayName,
                                          fontSize: 12,
                                          color: AppColors.black200,
                                          textAlign: TextAlign.left,
                                          maxLines: 2,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }


// Then in your build method, replace this line:
// EditPersonal(
//   title: AppString.location_text,
//   controller: controller.primaryLocationController,
// ),

// With:
// _buildLocationField(controller),
}

class EditPersonal extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  const EditPersonal({
    super.key,
    required this.title,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: title,
          fontSize: 14.sp,
          textAlign: TextAlign.left,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
        ),
        SizedBox(height: 6),
        CommonTextField(
          controller: controller,
          maxLines: 1,
          hintTextColor: AppColors.black400,
        )
      ],
    );
  }
}