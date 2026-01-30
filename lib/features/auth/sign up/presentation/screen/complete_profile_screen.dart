import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/component/text_field/common_text_field.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/home/widget/home_custom_button.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'dart:io';
import '../../../../../utils/constants/app_colors.dart';
import '../controller/complete_profile_controller.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CompleteProfileController>(
      init: CompleteProfileController(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: CustomAppBar(
                    title: AppString.complete_profile_text,
                    onBackTap: (){
                      Get.back();
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),

                        // Profile Image Section
                        _buildProfileImageSection(controller),

                        SizedBox(height: 24.h),

                        // Form Fields
                        _buildFormSection(controller),

                        SizedBox(height: 32.h),

                        // Upload Photos Section
                        _buildUploadSection(controller),

                        SizedBox(height: 24.h),

                        // Privacy Policy Checkbox
                        _buildPrivacySection(controller),

                        SizedBox(height: 24.h),

                        // Confirm Button
                        _buildConfirmButton(controller),

                        SizedBox(height: 32.h),
                      ],
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

  Widget _buildProfileImageSection(CompleteProfileController controller) {
    return Obx(() => Stack(
      children: [
        CircleAvatar(
          radius: 60.r,
          backgroundColor: AppColors.black50, // Add background color
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60.r),
            child: controller.profileImage.value != null
                ? Image.file(
              controller.profileImage.value!,
              width: 120.w,
              height: 120.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // If file image fails, show default
                return Image.asset(
                  "assets/images/noImage.png",
                  width: 120.w,
                  height: 120.h,
                  fit: BoxFit.cover,
                );
              },
            )
                : Image.asset(
              "assets/images/noImage.png",
              width: 120.w,
              height: 120.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // If asset doesn't exist, show placeholder
                return Icon(
                  Icons.person,
                  size: 60.sp,
                  color: AppColors.black200,
                );
              },
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

  Widget _buildFormSection(CompleteProfileController controller) {
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

                  // Category dropdown
                  _buildFieldWithLabel(
                    label: index == 0 ? AppString.service : AppString.service,
                    child: Obx(() => _buildDropdownFieldWithCallback(
                      controller: controller,
                      textController: pair.serviceController,
                      hintText: AppString.service_hint,
                      items: controller.categories
                          .map((cat) => cat['name'] as String)
                          .toList(),
                      onSelected: (categoryName) {
                        final category = controller.categories.firstWhere(
                              (cat) => cat['name'] == categoryName,
                        );
                        controller.onCategorySelected(
                          index,
                          category['_id'] as String,
                          categoryName,
                        );
                      },
                    )),
                  ),

                  SizedBox(height: 16.h),

                  // SubCategory dropdown (depends on selected category)
                  _buildFieldWithLabel(
                    label: index == 0 ? AppString.service_type : AppString.service_type,
                    child: GetBuilder<CompleteProfileController>(
                      builder: (controller) {
                        final subCategories = pair.selectedCategoryId != null
                            ? controller.getSubCategoriesForCategory(pair.selectedCategoryId!)
                            : [];

                        return _buildDropdownFieldWithCallback(
                          controller: controller,
                          textController: pair.serviceTypeController,
                          hintText: AppString.select_service_type,
                          items: subCategories
                              .map((sub) => sub['subCategoryName'] as String)
                              .toList(),
                          onSelected: (subCategoryName) {
                            final subCategory = subCategories.firstWhere(
                                  (sub) => sub['subCategoryName'] == subCategoryName,
                            );
                            controller.onSubCategorySelected(
                              index,
                              subCategory['_id'] as String,
                              subCategoryName,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Price field for each service
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
                      child: Divider(
                        color: AppColors.black50,
                        thickness: 1,
                      ),
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
              text: "  ${AppString.add_service}  ",
              isSelected: true,
              height: 44.h,
              onTap: controller.addService,
            ),
          ),
        ),

        SizedBox(height: 16.h),
        //_buildServiceTable(controller),

        // REPLACE THIS SECTION: Add Service Language - Multiple Selection
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
                                ? AppString.select_language
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
          child: GetBuilder<CompleteProfileController>(
            builder: (ctrl) {
              return Column(
                children: [
                  // Location Text Field
                  CommonTextField(
                    controller: ctrl.locationController,
                    hintText: AppString.hint_type_here,
                    borderColor: AppColors.black50,
                    textAlign: TextAlign.start,
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
                        : ctrl.locationController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.black300,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        ctrl.locationController.clear();
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
        ),

        SizedBox(height: 16.h),

        // Service Distance
        _buildFieldWithLabel(
          label: AppString.service_distance,
          child: _buildDistanceSlider(controller),
        ),

        SizedBox(height: 16.h),

        // Price

        SizedBox(height: 16.h),

        // Price Per Hour
        // _buildFieldWithLabel(
        //   label: AppString.price_hours,
        //   child: CommonTextField(
        //     controller: controller.pricePerHourController,
        //     hintText: AppString.price_hints,
        //     keyboardType: TextInputType.number,
        //     borderColor: AppColors.black50,
        //     height: 44,
        //     textAlign: TextAlign.start,
        //   ),
        // ),
      ],
    );
  }

// Add this method at the end of your EditServiceScreen class
  void _showLanguageSelectionBottomSheet(CompleteProfileController controller) {
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
                text: AppString.select_language,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              CommonText(
                text: AppString.select_multiple_language,
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
                                  Icons.check_circle,
                                  color: controller.isLanguageSelected(language)?AppColors.primaryColor:AppColors.black200,
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
              // Done button
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
                        text: AppString.done_button,
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
    required CompleteProfileController controller,
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

  Widget _buildDropdownFieldWithCallback({
    required CompleteProfileController controller,
    required TextEditingController textController,
    required String hintText,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    return GestureDetector(
      onTap: () => _showDropdownBottomSheetWithCallback(
        controller,
        textController,
        items,
        onSelected,
      ),
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

  void _showDropdownBottomSheetWithCallback(
      CompleteProfileController controller,
      TextEditingController textController,
      List<String> items,
      Function(String) onSelected,
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
                text: AppString.select_option,
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
                          textController.text = item;
                          onSelected(item);
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

  Widget _buildDistanceSlider(CompleteProfileController controller) {
    return Container(
      child: Column(
        children: [
          // Current Distance Value

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
              value: controller.serviceDistance.value,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: controller.updateServiceDistance,
            ),
          )),

          // Min/Max Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () {
                     return CommonText(
                        text: "${controller.serviceDistance.value.round()}km",
                        fontSize: 12.sp,
                        color: AppColors.black400,
                        textAlign: TextAlign.start,
                      );
                    }
                ),
                CommonText(
                  text: "100km",
                  fontSize: 12.sp,
                  color: AppColors.black400,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),

          // Slider
        ],
      ),
    );
  }

  Widget _buildUploadSection(CompleteProfileController controller) {
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

        // Upload Container with Images
        Obx(() => GestureDetector(
          onTap: controller.uploadedImages.length < 10
              ? controller.handleWorkPhotosUpload
              : null,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 90.h,
            ),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.black50,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: controller.uploadedImages.isEmpty
                ? // Show upload prompt when no images
            SizedBox(
              height: 66.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 32.sp,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(height: 8.h),
                  CommonText(
                    text: AppString.upload_image_text,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black100,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : // Show uploaded images
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with count and upload button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(
                      text: "${AppString.uploaded_images} (${controller.uploadedImages.length}/10)",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black400,
                      textAlign: TextAlign.start,
                    ),
                    if (controller.uploadedImages.length < 10)
                      GestureDetector(
                        onTap: controller.handleWorkPhotosUpload,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              CommonText(
                                text: AppString.add_button,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Images Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 1,
                  ),
                  itemCount: controller.uploadedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.black50),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.file(
                              File(controller.uploadedImages[index]),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => controller.removeWorkPhoto(index),
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
                    );
                  },
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildPrivacySection(CompleteProfileController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Checkbox(
          value: controller.isPrivacyAccepted.value,
          onChanged: (value) => controller.togglePrivacyAcceptance(),
          activeColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        )),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 14.h),
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                text: AppString.continue_by,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.black400,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: AppString.privacy_policy_text,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.toNamed(AppRoutes.privacyPolicy);// or Navigator.push(...)
                      },
                  ),
                  TextSpan(text: " ${AppString.and_text} "),
                  TextSpan(
                    text: AppString.term_condition_text,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.toNamed(AppRoutes.termsOfServices); // or Navigator.push(...)
                      },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(CompleteProfileController controller) {
    return Obx(() => Container(
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
          onTap: () async {
            // 1️⃣ Check if profile image is selected and needs upload

            // 2️⃣ Then confirm profile normally
            controller.confirmProfile();

          },
          child: Center(
            child: controller.isUploadingImage.value
                ? CircularProgressIndicator(
              color: Colors.white,
            )
                : CommonText(
              text: AppString.submit_for_button,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
  }


  void _showDropdownBottomSheet(
      CompleteProfileController controller,
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
                text: AppString.select_option,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ...items.map(
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
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
  /*Widget _buildServiceTable(CompleteProfileController controller) {
    return Obx(() => controller.servicePairs.isEmpty
        ? SizedBox.shrink()
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),

        // Table Header
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
            border: Border.all(color: AppColors.black50),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CommonText(
                    text: "Service",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 1,
                  height: 20.h,
                  color: AppColors.black50,
                ),
                Expanded(
                  flex: 2,
                  child: CommonText(
                    text: "Service Type",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 1,
                  height: 20.h,
                  color: AppColors.black50,
                ),
                Expanded(
                  flex: 1,
                  child: CommonText(
                    text: "Price",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 1,
                  height: 20.h,
                  color: AppColors.black50,
                ),
                Expanded(
                  flex: 1,
                  child: CommonText(
                    text: "Action",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Table Rows
        ...controller.servicePairs.asMap().entries.map((entry) {
          int index = entry.key;
          ServicePair pair = entry.value;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: AppColors.black50),
                right: BorderSide(color: AppColors.black50),
                bottom: BorderSide(color: AppColors.black50),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              child: Row(
                children: [
                  // Service Name
                  Expanded(
                    flex: 2,
                    child: CommonText(
                      text: pair.serviceController.text.isEmpty
                          ? "-"
                          : pair.serviceController.text,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: pair.serviceController.text.isEmpty
                          ? AppColors.textFiledColor
                          : AppColors.black,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 30.h,
                    color: AppColors.black50,
                  ),

                  // Service Type
                  Expanded(
                    flex: 2,
                    child: CommonText(
                      text: pair.serviceTypeController.text.isEmpty
                          ? "-"
                          : pair.serviceTypeController.text,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: pair.serviceTypeController.text.isEmpty
                          ? AppColors.textFiledColor
                          : AppColors.black,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 30.h,
                    color: AppColors.black50,
                  ),

                  // Price
                  Expanded(
                    flex: 1,
                    child: CommonText(
                      text: pair.priceController.text.isEmpty
                          ? "-"
                          : "${pair.priceController.text}RSD",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: pair.priceController.text.isEmpty
                          ? AppColors.textFiledColor
                          : AppColors.black,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 30.h,
                    color: AppColors.black50,
                  ),

                  // Action Buttons
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Edit Button
                        GestureDetector(
                          onTap: () => controller.editService(index),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 16.sp,
                              color: Colors.green,
                            ),
                          ),
                        ),

                        SizedBox(width: 8.w),

                        // Delete Button
                        GestureDetector(
                          onTap: () => _showDeleteConfirmationDialog(controller, index),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Icon(
                              Icons.delete,
                              size: 16.sp,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    ),
    );
  }*/

// Add this method for delete confirmation dialog
  void _showDeleteConfirmationDialog(CompleteProfileController controller, int index) {
    // Prevent deleting the first service
    if (index == 0) {
      Get.snackbar(
        AppString.info,
        AppString.service_delete_here_word,
        backgroundColor: Colors.orange[100],
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
          color: AppColors.black400,
          maxLines: 2,
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
              controller.deleteService(index);
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