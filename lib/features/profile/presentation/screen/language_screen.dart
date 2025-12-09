import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_string.dart';
import '../../data/language_model.dart';
import '../controller/language_controller.dart';

class LanguageSelectionScreen extends StatelessWidget {
  LanguageSelectionScreen({super.key});

  final LanguageController controller = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(title: AppString.language,),
              SizedBox(height: 20.h),
          
              // Language List
              Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.languages.length,
                itemBuilder: (context, index) {
                  final language = controller.languages[index];
                  return _buildLanguageItem(language);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(Language language) {
    return Obx(() => Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 8.h,
        ),
        leading: Container(
          width: 32.w,
          height: 24.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: Colors.grey[200],
          ),
          child: Center(
            child: Image.asset(language.flagAsset)
          ),
        ),
        title: CommonText(
          text: language.name,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          textAlign: TextAlign.left,
        ),
        trailing: GestureDetector(
          onTap: () => controller.selectLanguage(language.code),
          child: Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: controller.isSelected(language.code)
                    ? AppColors.primaryColor
                    : AppColors.primaryColor,
                width: 2,
              ),
              color: controller.isSelected(language.code)
                  ? AppColors.primaryColor
                  : Colors.transparent,
            ),
            child: controller.isSelected(language.code)
                ? Icon(
              Icons.check,
              size: 16.sp,
              color: Colors.white,
            )
                : null,
          ),
        ),
        onTap: () => controller.selectLanguage(language.code),
      ),
    ));
  }
}

// GetView alternative implementation
class LanguageSelectionGetView extends GetView<LanguageController> {
  const LanguageSelectionGetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const CommonText(
          text: AppString.language,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE91E63),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),

            // Language List
            Obx(() => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.languages.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final language = controller.languages[index];
                return _buildLanguageItem(language);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(Language language) {
    return Obx(() => InkWell(
      onTap: () => controller.selectLanguage(language.code),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Flag container
            Container(
              width: 32.w,
              height: 24.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: Colors.grey[200],
              ),
              child: Center(
                child: CommonText(
                  text: language.flagAsset,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            SizedBox(width: 16.w),

            // Language name
            Expanded(
              child: CommonText(
                text: language.name,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                textAlign: TextAlign.left,
              ),
            ),

            // Selection radio button
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: controller.isSelected(language.code)
                      ? const Color(0xFFE91E63)
                      : Colors.grey[400]!,
                  width: 2,
                ),
                color: controller.isSelected(language.code)
                    ? const Color(0xFFE91E63)
                    : Colors.transparent,
              ),
              child: controller.isSelected(language.code)
                  ? Icon(
                Icons.check,
                size: 16.sp,
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    ));
  }
}