import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/extensions/extension.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../component/text_field/common_text_field.dart';
import '../controller/change_password_controller.dart';
import '../../../../../../utils/constants/app_colors.dart';
import '../../../../../../utils/constants/app_string.dart';
import '../../../../../utils/helpers/other_helper.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ChangePasswordController>(
        builder: (controller) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomAppBar(title: AppString.change_password,),
                    Column(
                      children: [
                        SizedBox(height: 100.h,),
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: AppColors.black50),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x408E8E8E),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Form(
                              key: controller.formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Logo text here
                                  const CommonText(
                                    text: AppString.change_password,
                                    fontSize: 18,
                
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w500,
                                    maxLines: 2,
                                    bottom: 20,
                                  ).center,
                
                                  /// current Password section
                                  CommonText(
                                      text: AppString.old_password,
                                    bottom: 8,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  CommonTextField(
                                    controller: controller.currentPasswordController,
                                    hintText: AppString.old_password_hint,
                                    hintTextColor: AppColors.black200,
                                    validator: OtherHelper.passwordValidator,
                                    isPassword: true,
                                    //prefixIcon: Icon(Icons.lock, size: 20.sp),
                                  ),
                
                                  /// New Password section
                                  const CommonText(
                                    text: AppString.new_passowrd_text,
                                    bottom: 8,
                                    top: 16,
                                  ),
                                  CommonTextField(
                                    controller: controller.newPasswordController,
                                    hintText: AppString.hint_new_password,
                                    validator: OtherHelper.passwordValidator,
                                    isPassword: true,
                                    //prefixIcon: Icon(Icons.lock, size: 20.sp),
                                  ),
                
                                  /// confirm Password section
                                  const CommonText(
                                    text: AppString.confirm_password_text,
                                    bottom: 8,
                                    top: 16,
                                  ),
                                  CommonTextField(
                                    controller: controller.confirmPasswordController,
                                    hintText: AppString.hint_confirm_password,
                                    validator:
                                        (value) => OtherHelper.confirmPasswordValidator(
                                          value,
                                          controller.newPasswordController,
                                        ),
                                    isPassword: true,
                                    //prefixIcon: Icon(Icons.lock, size: 20.sp),
                                  ),
                                  20.height,
                
                                  /// submit Button
                                  CommonButton(
                                    titleText: AppString.confirm_button,
                                    isLoading: controller.isLoading,
                                    onTap: (){
                                    controller.changePasswordRepo();
                
                                    }
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
