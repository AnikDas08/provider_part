import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/setting/presentation/controller/service_provider_controller.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';

class ServiceProviderPolicy extends StatelessWidget {
  const ServiceProviderPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50,
        title: Text(AppString.service_provider_policy.tr,selectionColor: AppColors.primaryColor,),
        leading: GestureDetector(
          onTap: () => Get.back(), // 👈 Default is Get.back()
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: Colors.black, size: 24),
          ),
        ),
      ),
      /// Body Section stats here
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GetBuilder<ServiceProviderController>(
              init:ServiceProviderController(),
              builder: (controller)=> Column(
                children: [
                  //CustomAppBar(title: AppString.service_provider_policy,),
                  SizedBox(height: 20,),
                  Html(
                    data: controller.data.content,
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}
