import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/auth/sign%20up/presentation/controller/complete_profile_controller.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/service_details_controller.dart';
import 'package:haircutmen_user_app/features/message/presentation/controller/message_controller.dart';
import 'package:haircutmen_user_app/features/overview/presentation/controller/overview_controller.dart';
import 'package:haircutmen_user_app/features/profile/presentation/controller/edit_profile_controller.dart';

import '../../features/auth/change_password/presentation/controller/change_password_controller.dart';
import '../../features/auth/forgot password/presentation/controller/forget_password_controller.dart';
import '../../features/auth/sign in/presentation/controller/sign_in_controller.dart';
import '../../features/auth/sign up/presentation/controller/sign_up_controller.dart';
import '../../features/message/presentation/controller/chat_controller.dart';
import '../../features/notifications/presentation/controller/notifications_controller.dart';
import '../../features/profile/presentation/controller/profile_controller.dart';
import '../../features/setting/presentation/controller/privacy_policy_controller.dart';
import '../../features/setting/presentation/controller/setting_controller.dart';
import '../../features/setting/presentation/controller/terms_of_services_controller.dart';
import '../../features/home/presentation/controller/home_controller.dart';
import '../../features/home/presentation/controller/home_nav_controller.dart';
import '../../features/scan/presentation/controller/scan_controller.dart';
import '../../features/favorite/presentation/controller/favorite_controller.dart';

class DependencyInjection extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpController(), fenix: true);
    Get.lazyPut(() => SignInController(), fenix: true);
    Get.lazyPut(() => ForgetPasswordController(), fenix: true);
    Get.lazyPut(() => ChangePasswordController(), fenix: true);
    Get.lazyPut(() => NotificationsController(), fenix: true);
    Get.lazyPut(() => ChatControllers(), fenix: true);
    Get.lazyPut(() => MessageController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => SettingController(), fenix: true);
    Get.lazyPut(() => PrivacyPolicyController(), fenix: true);
    Get.lazyPut(() => TermsOfServicesController(), fenix: true);
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => EditProfileController(), fenix: true);
    Get.lazyPut(() => HomeNavController(), fenix: true);
    Get.lazyPut(() => OverviewController(), fenix: true);
    Get.lazyPut(() => QRScannerController(), fenix: true);
    Get.lazyPut(() => FavoriteController(), fenix: true);
    Get.lazyPut(() => ServiceDetailsController(), fenix: true);
    Get.lazyPut(() => CompleteProfileController(), fenix: true);
  }
}
