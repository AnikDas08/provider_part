import 'package:flutter/material.dart';
import '../../../../../../config/route/app_routes.dart';
import '../../../../../../utils/extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../component/text_field/common_text_field.dart';
import '../../../../../utils/app_bar/custom_appbars.dart';
import '../controller/sign_in_controller.dart';

import '../../../../../../utils/constants/app_colors.dart';
import '../../../../../../utils/constants/app_string.dart';
import '../../../../../../utils/helpers/other_helper.dart';
import '../widgets/do_not_account.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Scaffold(
      /// App Bar Sections Starts here

      /// Body Sections Starts here
      body: GetBuilder<SignInController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SafeArea(
              child: Column(
                children: [
                  CustomAppBar(showMessage: false,onBackTap: () => Get.offAllNamed(AppRoutes.onboarding)),

                  /// Logo text here
                  const CommonText(
                    text: AppString.onboarding_text,
                    fontSize: 24,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    bottom: 20,
                  ).center,

                  /// Log In Container here
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Log In Instruction here
                          const CommonText(
                            text: AppString.login_text,
                            fontSize: 18,
                            bottom: 20,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ).center,

                          /// Account Email Input here
                          const CommonText(
                            text: AppString.email_text,
                            bottom: 8,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black400,
                          ),
                          CommonTextField(
                            controller: controller.emailController,
                            hintText: AppString.hint_email_text,
                            hintTextColor: AppColors.black100,
                            validator: OtherHelper.emailValidator,
                          ),

                          /// Account Password Input here
                          const CommonText(
                            text: AppString.password_text,
                            bottom: 8,
                            top: 24,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black400,
                          ),
                          CommonTextField(
                            controller: controller.passwordController,
                            isPassword: true,
                            hintText: AppString.hint_password_text,
                            hintTextColor: AppColors.black100,
                            validator: OtherHelper.passwordValidator,
                          ),

                          /// Forget Password Button here
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap:
                                  () => Get.toNamed(AppRoutes.forgotPassword),
                              child: const CommonText(
                                text: AppString.forget_password_text,
                                top: 10,
                                bottom: 30,
                                color: AppColors.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          /// Submit Button here
                          CommonButton(
                            titleText: AppString.login_text,
                            isLoading: controller.isLoading,
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                controller.signInUser();
                              }
                            },
                          ),
                          30.height,

                          /// Account Creating Instruction here
                          const DoNotHaveAccount().center,
                        ],
                      ),
                    ),
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
