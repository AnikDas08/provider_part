import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/setting/presentation/controller/service_provider_controller.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import '../../../../utils/constants/app_string.dart';

class ServiceProviderPolicy extends StatelessWidget {
  const ServiceProviderPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// Body Section stats here
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GetBuilder<ServiceProviderController>(
              init:ServiceProviderController(),
              builder: (controller)=> Column(
                children: [
                  CustomAppBar(title: AppString.service_provider_policy,),
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
