import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/auth/sign%20up/presentation/screen/complete_profile_screen.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/canceldetails_screen.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/viewdetails_pending.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/viewdetailse_upcomming.dart';
import 'package:haircutmen_user_app/features/overview/presentation/screen/overview_screen.dart';
import 'package:haircutmen_user_app/features/profile/presentation/screen/contracts_screen.dart';
import 'package:haircutmen_user_app/features/profile/presentation/screen/edit_service_screen.dart';
import 'package:haircutmen_user_app/features/profile/presentation/screen/language_screen.dart';
import 'package:haircutmen_user_app/features/profile/presentation/screen/person_service_screen.dart';
import 'package:haircutmen_user_app/features/profile/presentation/screen/personal_information.dart';
import 'package:haircutmen_user_app/features/setting/presentation/screen/privacy_policy_screen.dart';
import 'package:haircutmen_user_app/features/setting/presentation/screen/service_provider_policy.dart';
import '../../features/auth/change_password/presentation/screen/change_password_screen.dart';
import '../../features/auth/forgot password/presentation/screen/create_password.dart';
import '../../features/auth/forgot password/presentation/screen/forgot_password.dart';
import '../../features/auth/forgot password/presentation/screen/verify_screen.dart';
import '../../features/auth/sign in/presentation/screen/sign_in_screen.dart';
import '../../features/auth/sign up/presentation/screen/sign_up_screen.dart';
import '../../features/auth/sign up/presentation/screen/verify_user.dart';
import '../../features/message/presentation/screen/chat_screen.dart';
import '../../features/message/presentation/screen/message_screen.dart';
import '../../features/notifications/presentation/screen/notifications_screen.dart';
import '../../features/onboarding_screen/onboarding_screen.dart';
import '../../features/profile/presentation/screen/edit_profile.dart';
import '../../features/profile/presentation/screen/profile_screen.dart';
import '../../features/setting/presentation/screen/setting_screen.dart';
import '../../features/setting/presentation/screen/terms_of_services_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/home/presentation/screen/home_screen.dart';
import '../../features/home/presentation/screen/home_nav_screen.dart';
import '../../features/scan/presentation/screen/scan_screen.dart';
import '../../features/favorite/presentation/screen/favorite_screen.dart';

class AppRoutes {
  static const String test = "/test_screen.dart";
  static const String splash = "/splash_screen.dart";
  static const String onboarding = "/onboarding_screen.dart";
  static const String signUp = "/sign_up_screen.dart";
  static const String verifyUser = "/verify_user.dart";
  static const String signIn = "/sign_in_screen.dart";
  static const String forgotPassword = "/forgot_password.dart";
  static const String verifyEmail = "/verify_screen.dart";
  static const String createPassword = "/create_password.dart";
  static const String changePassword = "/change_password_screen.dart";
  static const String notifications = "/notifications_screen.dart";
  static const String chat = "/chat_screen.dart";
  static const String message = "/message_screen.dart";
  static const String profile = "/profile_screen.dart";
  static const String editProfile = "/edit_profile.dart";
  static const String privacyPolicy = "/privacy_policy_screen.dart";
  static const String termsOfServices = "/terms_of_services_screen.dart";
  static const String setting = "/setting_screen.dart";
  static const String home = "/home_screen.dart";
  static const String homeNav = "/home_nav_screen.dart";
  static const String appointment = "/appointment_screen.dart";
  static const String scan = "/scan_screen.dart";
  static const String favorite = "/favorite_screen.dart";
  static const String upcomingdetail_sscreen = "/upcomingdetail_sscreen";
  static const String view_detail_pending = "/view_detail_pending";
  static const String canceldetails_screen = "/canceldetails_screen";
  static const String complete_profile_screen = "/complete_profile_screen";
  static const String personal_information = "/personal_information";
  static const String service_person_screen = "/service_person_screen";
  static const String language_screen = "/language_screen";
  static const String edit_service_screen = "/edit_service_screen";
  static const String contract_screen = "/contract_screen";
  static const String service_provider_policy = "/service_provider_policy";

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: signUp, page: () => SignUpScreen()),
    GetPage(name: verifyUser, page: () => const VerifyUser()),
    GetPage(name: signIn, page: () => SignInScreen()),
    GetPage(name: forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: verifyEmail, page: () => const VerifyScreen()),
    GetPage(name: createPassword, page: () => CreatePassword()),
    GetPage(name: changePassword, page: () => ChangePasswordScreen()),
    GetPage(name: notifications, page: () => const NotificationScreen()),
    GetPage(name: chat, page: () =>  ChatListScreen()),
    GetPage(name: message, page: () => MessageScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: editProfile, page: () => EditProfile()),
    GetPage(name: privacyPolicy, page: () => PrivacyPolicyScreen()),
    GetPage(name: termsOfServices, page: () => TermsOfServicesScreen()),
    GetPage(name: setting, page: () => const SettingScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: homeNav, page: () => HomeNavScreen()),
    GetPage(name: appointment, page: () => const OverviewScreen()),
    GetPage(name: scan, page: () => QRScannerScreen()),
    GetPage(name: favorite, page: () => const FavoriteScreen()),
    GetPage(name: upcomingdetail_sscreen, page: () => const ViewDetailsUpcoming()),
    GetPage(name: view_detail_pending, page: () => const ViewDetailsPending()),
    GetPage(name: canceldetails_screen, page: () => const CanceldetailsScreen()),
    GetPage(name: complete_profile_screen, page: () => const CompleteProfileScreen()),
    GetPage(name: personal_information, page: () => const PersonalInformationScreen()),
    GetPage(name: service_person_screen, page: () =>  ServiceProfileScreen()),
    GetPage(name: language_screen, page: () =>  LanguageSelectionScreen()),
    GetPage(name: edit_service_screen, page: () =>  EditServiceScreen()),
    GetPage(name: contract_screen, page: () =>  ContractsScreen()),
    GetPage(name: service_provider_policy, page: () =>  ServiceProviderPolicy()),
  ];
}
