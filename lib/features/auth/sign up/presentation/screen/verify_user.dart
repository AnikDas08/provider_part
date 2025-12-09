import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/extensions/extension.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../controller/sign_up_controller.dart';
import '../../../../../../utils/constants/app_colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../../../utils/constants/app_string.dart';

class VerifyUser extends StatefulWidget {
  const VerifyUser({super.key});

  @override
  State<VerifyUser> createState() => _VerifyUserState();
}

class _VerifyUserState extends State<VerifyUser> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    //SignUpController.instance.startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SignUpController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
            child: SafeArea(
              child: Column(
                children: [
                  /// Logo text here
                  CustomAppBar(title: "",),
                  const CommonText(
                    text: AppString.logoText,
                    fontSize: 24,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    bottom: 20,
                  ).center,

                  SizedBox(height: 100.h,),
                  /// Verify User Container here
                  Center(
                    child: Container(
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
                              text: AppString.otpTitle,
                              fontSize: 18,
                              bottom: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),

                            /// instruction how to get OTP
                            Center(
                              child: CommonText(
                                text:
                                    "${AppString.codeHasBeenSendTo} ${controller.emailController.text}",
                                fontSize: 14,
                                bottom: 20,
                                maxLines: 2,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            /// OTP Filed here
                            Flexible(
                              flex: 0,
                              child: PinCodeTextField(
                                controller: controller.otpController,
                                autoDisposeControllers: false,
                                cursorColor: AppColors.primaryColor,
                                appContext: (context),
                                autoFocus: true,
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(4.r),
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
                                validator: (value) {
                                  if (value != null && value.length == 6) {
                                    return null;
                                  } else {
                                    return AppString.otpIsInValid;
                                  }
                                },
                              ),
                            ),

                            /// Resent OTP or show Timer
                            /*GestureDetector(
                              onTap:
                                  controller.time == '00:00'
                                      ? () {
                                        controller.startTimer();
                                        controller.signUpUser();
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  20.height,
                  CommonButton(
                    titleText: AppString.resend_otp,
                    isLoading: controller.isLoadingWork,
                    buttonColor: AppColors.transparent,
                    buttonWidth: MediaQuery.of(context).size.width * 0.6,
                    borderColor: AppColors.primaryColor,
                    titleColor: AppColors.primaryColor,
                    onTap: () {
                      controller.resetOpt();
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
