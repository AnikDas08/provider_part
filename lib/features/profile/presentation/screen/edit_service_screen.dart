import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/component/text_field/common_text_field.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/features/profile/presentation/controller/edit_service_controller.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'dart:io';
import '../../../../../utils/constants/app_colors.dart';
import '../../../home/widget/home_custom_button.dart';

class EditServiceScreen extends StatelessWidget {
  const EditServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditServiceController>(
      init: EditServiceController(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: CustomAppBar(
                    title: AppString.edit_service_button,
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [

                          // Profile Image Section
                          //_buildProfileImageSection(controller),

                          SizedBox(height: 24.h),

                          // Form Fields
                          _buildFormSection(controller),

                          SizedBox(height: 32.h),

                          // Upload Photos Section
                          _buildUploadSection(controller),

                          SizedBox(height: 24.h),

                          // Combined Images Section (Asset + Uploaded)
                          _buildCombinedImageSection(controller),

                          SizedBox(height: 24.h),

                          // Confirm Button
                          _buildConfirmButton(controller),

                          SizedBox(height: 32.h),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImageSection(EditServiceController controller) {
    return Obx(() => Stack(
      children: [
        CircleAvatar(
          radius: 60.r,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60.r),
            child: controller.profileImage.value != null
                ? Image.file(
              controller.profileImage.value!,
              width: 120.w,
              height: 120.h,
              fit: BoxFit.cover,
            )
                : Image.asset(
              "assets/images/item_image.png",
              width: 120.w,
              height: 120.h,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: controller.handleImageUpload,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
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
    ));
  }

  Widget _buildCombinedImageSection(EditServiceController controller) {
    return Obx(() {
      List<Widget> imageWidgets = [];

      // Add asset images (from API)
      for (int i = 0; i < controller.assetImages.length; i++) {
        bool isUrl = controller.assetImages[i].startsWith('http') ||
            controller.assetImages[i].startsWith('/');

        imageWidgets.add(
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isUrl
                      ? Image.network(
                    ApiEndPoint.imageUrl+controller.assetImages[i],
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 76,
                        height: 76,
                        color: Colors.grey[300],
                        child: Icon(Icons.error),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 76,
                        height: 76,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  )
                      : Image.asset(
                    controller.assetImages[i],
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => controller.removeAssetImage(i),
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Add uploaded images (newly added)
      for (int i = 0; i < controller.uploadedImages.length; i++) {
        imageWidgets.add(
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(controller.uploadedImages[i]),
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => controller.removeWorkPhoto(i),
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            text: "${AppString.image_all} (${controller.getTotalImageCount()})",
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 12.h),
          imageWidgets.isEmpty
              ? Container(
            height: 76,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.black50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CommonText(
                text: AppString.noImageAvailable,
                fontSize: 14.sp,
                color: AppColors.black400,
                textAlign: TextAlign.center,
              ),
            ),
          )
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: imageWidgets),
          ),
        ],
      );
    });
  }

  Widget _buildFormSection(EditServiceController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About Me
        _buildFieldWithLabel(
          label: AppString.aboutMe,
          child: CommonTextField(
            controller: controller.aboutMeController,
            hintText: AppString.hint_type_here,
            maxLines: 3,
            borderColor: AppColors.black50,
            textAlign: TextAlign.start,
          ),
        ),

        SizedBox(height: 16.h),

        // Dynamic Service Section
        Obx(() => Column(
          children: [
            // Generate service pairs dynamically
            ...controller.servicePairs.asMap().entries.map((entry) {
              int index = entry.key;
              ServicePair pair = entry.value;

              return Column(
                children: [
                  // Service header with delete button (not for first service)
                  if (index > 0)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommonText(
                            text: "${AppString.service} ${index + 1}",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                            textAlign: TextAlign.start,
                          ),
                          GestureDetector(
                            onTap: () => _showDeleteConfirmationDialog(controller, index),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 16.sp,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 4.w),
                                  CommonText(
                                    text: AppString.delete_button,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Service dropdown
                  _buildFieldWithLabel(
                    label: index == 0 ? AppString.service_text : AppString.service,
                    child: _buildDropdownField(
                      controller: controller,
                      textController: pair.serviceController,
                      hintText: AppString.service_hint,
                      items: controller.serviceNames,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Service Type dropdown (depends on selected service)
                  _buildFieldWithLabel(
                    label: index == 0 ? AppString.service_type : AppString.service_type,
                    child: GetBuilder<EditServiceController>(
                      builder: (controller) => _buildDropdownField(
                        controller: controller,
                        textController: pair.serviceTypeController,
                        hintText: AppString.selectServiceType,
                        items: pair.serviceController.text.isNotEmpty
                            ? controller.getServiceTypes(pair.serviceController.text)
                            : [],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Price field
                  _buildFieldWithLabel(
                    label: index == 0 ? AppString.price_text : AppString.price_text,
                    child: CommonTextField(
                      controller: pair.priceController,
                      hintText: AppString.price_hints,
                      keyboardType: TextInputType.number,
                      height: 44,
                      borderColor: AppColors.black50,
                      textAlign: TextAlign.start,
                    ),
                  ),

                  // Divider between services (except for last one)
                  if (index < controller.servicePairs.length - 1)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Divider(color: AppColors.black50, thickness: 1),
                    ),
                ],
              );
            }),
          ],
        )),

        SizedBox(height: 16.h),

        // Add Service Button
        Align(
          alignment: Alignment.topRight,
          child: IntrinsicWidth(
            child: CustomButton(
              text: AppString.addService,
              isSelected: true,
              height: 44.h,
              onTap: controller.addService,
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Add Service Language - Multiple Selection
        _buildFieldWithLabel(
          label: AppString.add_service_language,
          child: Column(
            children: [
              // Display field showing selected languages
              GestureDetector(
                onTap: () => _showLanguageSelectionBottomSheet(controller),
                child: Container(
                  height: 44.h,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.black50),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Obx(() => CommonText(
                            text: controller.selectedLanguages.isEmpty
                                ? AppString.selectedLanguageHere
                                : controller.selectedLanguages.join(', '),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: controller.selectedLanguages.isEmpty
                                ? AppColors.textFiledColor
                                : AppColors.black,
                            textAlign: TextAlign.start,
                            maxLines: 2,
                          )),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textFiledColor,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),

              // Show selected languages as chips
              Obx(() => controller.selectedLanguages.isNotEmpty
                  ? Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 8.h),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 4.h,
                  children: controller.selectedLanguages.map((language) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CommonText(
                            text: language,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryColor,
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(width: 4.w),
                          GestureDetector(
                            onTap: () => controller.toggleLanguageSelection(language),
                            child: Icon(
                              Icons.close,
                              size: 16.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
                  : SizedBox.shrink()),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Primary Location
        _buildFieldWithLabel(
          label: AppString.primary_location_text,
          child: CommonTextField(
            height: 44,
            controller: controller.locationController,
            hintText: AppString.hint_type_here,
            borderColor: AppColors.black50,
            textAlign: TextAlign.start,
          ),
        ),

        SizedBox(height: 16.h),

        // Service Distance
        _buildFieldWithLabel(
          label: AppString.service_distance,
          child: _buildDistanceSlider(controller),
        ),

        SizedBox(height: 16.h),

       /* // Price Per Hour
        _buildFieldWithLabel(
          label: AppString.price_hours,
          child: CommonTextField(
            controller: controller.pricePerHourController,
            hintText: AppString.price_hints,
            keyboardType: TextInputType.number,
            borderColor: AppColors.black50,
            height: 44,
            textAlign: TextAlign.start,
          ),
        ),*/
      ],
    );
  }

  void _showLanguageSelectionBottomSheet(EditServiceController controller) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.black50,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              CommonText(
                text: AppString.selectedLanguageHere,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              CommonText(
                text: AppString.editLanguage,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.black400,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: controller.languages.map((language) {
                      return Obx(() => GestureDetector(
                        onTap: () => controller.toggleLanguageSelection(language),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.black50,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: CommonText(
                                  text: language,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.black,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Icon(
                                controller.isLanguageSelected(language)
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: controller.isLanguageSelected(language)
                                    ? AppColors.primaryColor
                                    : AppColors.black200,
                                size: 20.sp,
                              ),
                            ],
                          ),
                        ),
                      ));
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.r),
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: CommonText(
                        text: AppString.done,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFieldWithLabel({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: label,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }

  Widget _buildDropdownField({
    required EditServiceController controller,
    required TextEditingController textController,
    required String hintText,
    required List<String> items,
  }) {
    return GestureDetector(
      onTap: () => _showDropdownBottomSheet(controller, textController, items),
      child: Container(
        height: 44.h,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black50),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: CommonText(
                  text: textController.text.isEmpty ? hintText : textController.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: textController.text.isEmpty
                      ? AppColors.textFiledColor
                      : AppColors.black,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textFiledColor,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceSlider(EditServiceController controller) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 8.h),
          Obx(() => SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
              activeTrackColor: AppColors.primaryColor,
              inactiveTrackColor: AppColors.black50,
              thumbColor: AppColors.primaryColor,
              trackHeight: 4.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
              overlayColor: AppColors.primaryColor.withOpacity(0.2),
            ),
            child: Slider(
              value: controller.serviceDistance.value.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: controller.updateServiceDistance,
            ),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  return CommonText(
                    text: "${controller.serviceDistance.value.round()}km",
                    fontSize: 12.sp,
                    color: AppColors.black400,
                    textAlign: TextAlign.start,
                  );
                }),
                CommonText(
                  text: "100km",
                  fontSize: 12.sp,
                  color: AppColors.black400,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(EditServiceController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.add_new,
          fontSize: 14.sp,
          maxLines: 2,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 12.h),
        Obx(() => GestureDetector(
          onTap: controller.getTotalImageCount() < 10
              ? controller.handleWorkPhotosUpload
              : () {
            Get.snackbar(
              AppString.limit_reached,
              AppString.hight_flow,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          child: Container(
            width: double.infinity,
            height: 100.h,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.getTotalImageCount() < 10
                    ? AppColors.black50
                    : Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(10.r),
              color: controller.getTotalImageCount() < 10
                  ? Colors.transparent
                  : Colors.grey[100],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 24.sp,
                  color: controller.getTotalImageCount() < 10
                      ? AppColors.primaryColor
                      : Colors.grey[400],
                ),
                SizedBox(height: 8.h),
                CommonText(
                  text: controller.getTotalImageCount() < 10
                      ? AppString.upload_image_text
                      : AppString.limit_reached,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: controller.getTotalImageCount() < 10
                      ? AppColors.black100
                      : Colors.grey[400]!,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildConfirmButton(EditServiceController controller) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () {
            controller.confirmProfile();
          },
          child: Center(
            child: CommonText(
              text: AppString.submit_approve,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _showDropdownBottomSheet(
      controller,
      TextEditingController textController,
      List<String> items,
      ) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.black50,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              CommonText(
                text: AppString.selectOption,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: items.map(
                          (item) => GestureDetector(
                        onTap: () {
                          controller.selectFromDropdown(textController, item);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.black50,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: CommonText(
                            text: item,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
  void _showDeleteConfirmationDialog(EditServiceController controller, int index) {
    // Prevent deleting the first service
    if (index == 0) {
      Get.snackbar(
        AppString.info,
        AppString.service_delete_here_word,
        backgroundColor: Colors.orange[100],
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: CommonText(
          text: AppString.delete_service,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
          textAlign: TextAlign.center,
        ),
        content: CommonText(
          text: AppString.delete_here_service,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          maxLines: 2,
          color: AppColors.black400,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: CommonText(
              text: AppString.cancel_button,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.black400,
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeService(index);
            },
            child: CommonText(
              text: AppString.delete_button,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.red,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}