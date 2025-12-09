// screens/message_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text_field/common_text_field.dart';
import 'package:haircutmen_user_app/features/home/widget/home_custom_button.dart';
import 'package:haircutmen_user_app/features/profile/presentation/controller/contract_controller.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GetBuilder<ContractController>(
          init: ContractController(),
          builder: (controller) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(title: AppString.contact_support,),
                SizedBox(height: 30.h,),
                CommonText(
                    text: AppString.subject,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black400,
                ),
                SizedBox(height: 10.h,),
                CommonTextField(
                  controller: controller.subjectController,
                  hintText: AppString.hint_type_here,
                ),
                SizedBox(height: 20.h,),
                CommonText(
                    text: AppString.message,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black400,
                ),
                SizedBox(height: 5.h,),
                CommonTextField(
                  controller: controller.messageController,
                  hintText: AppString.hint_type_here,
                  maxLines: 5,
                ),
                Spacer(),
                CustomButton(text: AppString.submit_button, isSelected: true, onTap: (){
                  controller.sendContactData();
                })
              ],
            ),
          ),
        ),
      ),
    );
  }


}