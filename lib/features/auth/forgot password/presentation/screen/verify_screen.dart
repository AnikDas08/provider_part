import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/extensions/extension.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../controller/forget_password_controller.dart';
import '../../../../../../utils/constants/app_colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../../../utils/constants/app_string.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final formKey = GlobalKey<FormState>();

  /// init State here
  @override
  void initState() {
    ForgetPasswordController.instance.startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// App Bar Section
      appBar: AppBar(),

      /// Body Section
      body: GetBuilder<ForgetPasswordController>(
        builder:
            (controller) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
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

                  /// Verify User Container here
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
                        children: [
                          /// OTP Title here
                          CommonText(
                            text: AppString.verify_email_text,
                            fontSize: 18,
                            bottom: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryColor,
                          ),

                          /// instruction how to get OTP
                          Center(
                            child: CommonText(
                              text:
                                  AppString.verify_email_details,
                              fontSize: 12,
                              bottom: 20,
                              maxLines: 2,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black300,
                            ),
                          ),

                          /// OTP Filed here
                          Flexible(
                            flex: 0,
                            child: PinCodeTextField(
                              controller: controller.otpController,
                              validator: (value) {
                                if (value != null && value.length == 6) {
                                  return null;
                                } else {
                                  return AppString.otpIsInValid;
                                }
                              },
                              autoDisposeControllers: false,
                              cursorColor: AppColors.primaryColor,
                              appContext: (context),
                              autoFocus: true,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(8),
                                fieldHeight: 60.h,
                                fieldWidth: 60.w,
                                activeFillColor: AppColors.transparent,
                                selectedFillColor: AppColors.transparent,
                                inactiveFillColor: AppColors.transparent,
                                borderWidth: 0.5.w,
                                selectedColor: AppColors.black50,
                                activeColor: AppColors.black50,
                                inactiveColor: AppColors.black50,
                              ),
                              length: 6,
                              keyboardType: TextInputType.number,
                              autovalidateMode: AutovalidateMode.disabled,
                              enableActiveFill: true,
                            ),
                          ),

                          /// Resent OTP or show Timer
                          /*GestureDetector(
                            onTap:
                                controller.time == '00:00'
                                    ? () {
                                      controller.startTimer();
                                      controller.forgotPasswordRepo();
                                    }
                                    : () {},
                            child: CommonText(
                              text:
                                  controller.time == '00:00'
                                      ? AppString.resendCode
                                      : "${AppString.resendCodeIn} ${controller.time} ${AppString.minute}",
                              fontSize: 14,
                              bottom: 20,
                              fontWeight: FontWeight.w400,
                            ),
                          ),*/

                          ///  Submit Button here
                          CommonButton(
                            titleText: AppString.continues,
                            isLoading: controller.isLoadingVerify,
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                controller.verifyOtpRepo();
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  CommonButton(
                    titleText: AppString.resend_otp,
                    isLoading: controller.isLoadingWork,
                    buttonColor: AppColors.transparent,
                    borderColor: AppColors.primaryColor,
                    titleColor: AppColors.primaryColor,
                    buttonWidth: MediaQuery.of(context).size.width * 0.6,
                    onTap: () {
                      controller.resetButton();
                    },
                  )
                ],
              ),
            ),
      ),
    );
  }
}
