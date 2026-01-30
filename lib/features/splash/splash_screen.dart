import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:haircutmen_user_app/utils/extensions/extension.dart';
import '../../../config/route/app_routes.dart';
import 'package:get/get.dart';
import '../../component/app_storage/app_auth_storage.dart';
import '../../component/app_storage/storage_key.dart';
import '../../component/image/common_image.dart';
import '../../services/storage/storage_services.dart';
import '../auth/sign in/presentation/controller/sign_in_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () async {
      String? savedLanguage = AppAuthStorage().getValue(StorageKey.language) ?? "en";

      print("language : $savedLanguage👌👌👌👌👌");

      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        Get.updateLocale(Locale(savedLanguage));
      }
      final isLoggedIn = LocalStorage.isLogIn;

      if (isLoggedIn) {
        bool isValidSession=await SignInController().checkProfile();

        if (isValidSession) {
          Get.offAllNamed(AppRoutes.homeNav);
        } else {
          Get.offAllNamed(AppRoutes.onboarding);
        }
      } else {
        Get.offAllNamed(AppRoutes.onboarding);
      }
      //Get.offAllNamed(AppRoutes.onboarding);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset("assets/images/logo.png",height: double.infinity,width: double.infinity,fit: BoxFit.fill,),
    );
  }
}
