import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import '../../../../../../utils/extensions/extension.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../component/text_field/common_text_field.dart';
import '../controller/forget_password_controller.dart';
import '../../../../../../utils/constants/app_string.dart';
import '../../../../../../utils/helpers/other_helper.dart';

class CreatePassword extends StatelessWidget {
  CreatePassword({super.key});
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// App Bar Section starts here
      appBar: AppBar(),

      /// Body Section starts here
      body: GetBuilder<ForgetPasswordController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              children: [
                /// Logo text here
                const CommonText(
                  text: AppString.onboarding_text,
                  fontSize: 24,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  bottom: 20,
                ).center,

                /// Create Password Container here
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
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
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// OTP Title here
                        CommonText(
                          text: AppString.create_password_text,
                          fontSize: 18,
                          bottom: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                        ).center,

                        /// subtitle here
                        CommonText(
                          text: AppString.create_password_details_text,
                          fontSize: 12,
                          bottom: 20,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black300,
                          maxLines: 5,
                        ).center,

                        /// New Password here
                        CommonText(
                          text: AppString.new_passowrd_text,
                          fontSize: 14,
                          bottom: 8,
                          fontWeight: FontWeight.w400,
                        ),
                        CommonTextField(
                          controller: controller.passwordController,
                          hintText: AppString.hint_new_password,
                          isPassword: true,
                          validator: OtherHelper.passwordValidator,
                          hintTextColor: AppColors.black100,
                        ),
                        10.height,

                        /// Confirm Password here
                        CommonText(
                          text: AppString.confirm_password_text,
                          fontSize: 14,
                          bottom: 8,
                          fontWeight: FontWeight.w400,
                        ),
                        CommonTextField(
                          controller: controller.confirmPasswordController,
                          hintText: AppString.hint_confirm_password,
                          validator:
                              (value) => OtherHelper.confirmPasswordValidator(
                                value,
                                controller.passwordController,
                              ),
                          isPassword: true,
                        ),
                        20.height,

                        /// Submit Button here
                        CommonButton(
                          titleText: AppString.confirm_button,
                          titleSize: 18.sp,
                          isLoading: controller.isLoadingReset,
                          onTap: () {
                           controller.resetPasswordRepo();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
