import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🌟 নতুন ইম্পোর্ট
import 'package:google_sign_in/google_sign_in.dart'; // 🌟 নতুন ইম্পোর্ট
import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../services/storage/storage_keys.dart';
import '../../../../../services/storage/storage_services.dart';

class SignInController extends GetxController {
  /// Sign in Button Loading variable
  bool isLoading = false;

  /// 🌟 Google Sign-In এবং Firebase-এর জন্য গেটার অবজেক্ট
  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn();

  /// email and password Controller here
  TextEditingController emailController = TextEditingController(
    text: kDebugMode ? 'developernaimul00@gmail.com' : '',
  );

  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? 'hello123' : "",
  );

  Future<bool> checkProfile() async {
    try {
      var response = await ApiService.get(
        ApiEndPoint.myProvider,
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );

      if (response.statusCode == 200) {
        return response.data['data']['aboutMe'] != null;
      }
      else if (response.statusCode == 401) {
        // Session expired → logout
        LocalStorage.isLogIn = false;
        LocalStorage.token = "";
        LocalStorage.setBool(LocalStorageKeys.isLogIn, false);
        LocalStorage.setString(LocalStorageKeys.token, "");
        return false;
      }
      else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// ১. সাধারণ ইমেইল/পাসওয়ার্ড দিয়ে লগইন (PROVIDER)
  Future<void> signInUser() async {
    isLoading = true;
    update();

    Map<String, String> body = {
      "role": "PROVIDER",
      "email": emailController.text,
      "password": passwordController.text,
    };

    var response = await ApiService.post(
      ApiEndPoint.signIn,
      body: body,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      await _handleLoginSuccessAndNavigation(response.data);
      emailController.clear();
      passwordController.clear();
    }
    else if (response.statusCode == 401) {
      LocalStorage.isLogIn = false;
      LocalStorage.token = "";
      LocalStorage.setBool(LocalStorageKeys.isLogIn, false);
      LocalStorage.setString(LocalStorageKeys.token, "");
      Get.offAllNamed(AppRoutes.onboarding);
    }
    else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }

    isLoading = false;
    update();
  }

  /// 🌟 ২. উদাহরণ অনুযায়ী তৈরি করা: Firebase Google Sign-In (PROVIDER)
  Future<void> signInWithGoogleFirebase() async {
    isLoading = true;
    update();

    try {
      // গুগলের পপআপ স্ক্রিন ওপেন করা
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isLoading = false;
        update();
        return; // ইউজার পপআপ কেটে দিলে ক্যানসেল হবে
      }

      // গুগল অ্যাকাউন্ট থেকে টোকেন নেওয়া
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // ফায়ারবেসের জন্য ক্রেডেনশিয়াল তৈরি করা
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // ফায়ারবেসে সাইন-ইন করা
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // ব্যাকএন্ডে পাঠানোর জন্য ফায়ারবেস idToken জেনারেট করা
        String? firebaseIdToken = await firebaseUser.getIdToken();

        if (firebaseIdToken == null) {
          Get.snackbar("Error", "Firebase token creation failed.");
          isLoading = false;
          update();
          return;
        }

        // 🌟 আপনার দেওয়া উদাহরণের হুবহু এপিআই বডি স্ট্রাকচার (রোল শুধুমাত্র PROVIDER)
        Map<String, String> body = {
          "role": "PROVIDER",
          "provider": "google",
          "providerUserId": firebaseIdToken,
          "name": googleUser.displayName ?? "",
          "email": firebaseUser.email ?? "",
        };

        var response = await ApiService.post(
          ApiEndPoint.signIn,
          body: body,
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          await _handleLoginSuccessAndNavigation(response.data);
        } else {
          Get.snackbar(response.statusCode.toString(), response.message);
        }
      }
    } catch (e) {
      Get.snackbar("Google Auth Failed", e.toString());
      debugPrint("=================== GOOGLE AUTH ERROR: $e ===================");
    }

    isLoading = false;
    update();
  }

  /// 🌟 ৩. উদাহরণ অনুযায়ী তৈরি করা: Firebase Apple Sign-In (PROVIDER)
  Future<void> signInWithAppleFirebase() async {
    isLoading = true;
    update();

    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      // ফায়ারবেসের মাধ্যমে অ্যাপল সাইন-ইন ট্রিগার করা
      final UserCredential userCredential = await _auth.signInWithProvider(appleProvider);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        String? firebaseIdToken = await firebaseUser.getIdToken();

        if (firebaseIdToken == null) {
          Get.snackbar("Error", "Firebase token creation failed.");
          isLoading = false;
          update();
          return;
        }

        // 🌟 আপনার দেওয়া উদাহরণের হুবহু এপিআই বডি স্ট্রাকচার (রোল শুধুমাত্র PROVIDER)
        Map<String, String> body = {
          "role": "PROVIDER",
          "provider": "apple",
          "providerUserId": firebaseIdToken,
          "name": firebaseUser.displayName ?? "",
          "email": firebaseUser.email ?? "",
        };

        var response = await ApiService.post(
          ApiEndPoint.signIn,
          body: body,
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          await _handleLoginSuccessAndNavigation(response.data);
        } else {
          Get.snackbar(response.statusCode.toString(), response.message);
        }
      }
    } catch (e) {
      debugPrint("=================== APPLE AUTH ERROR: $e ===================");
    }

    isLoading = false;
    update();
  }

  /// 🌟 ৪. সব লগইনের টোকেন ডাটা সেভ এবং স্ক্রিন ডাইভারশন হ্যান্ডেল করার কমন ফাংশন
  Future<void> _handleLoginSuccessAndNavigation(dynamic responseData) async {
    var data = responseData['data'];

    // টোকেন ও আইডি লোকাল সিস্টেমে রাইট করা
    LocalStorage.token = data["accessToken"];
    LocalStorage.userId = data["id"];
    LocalStorage.isLogIn = true;

    LocalStorage.setBool(LocalStorageKeys.isLogIn, LocalStorage.isLogIn);
    LocalStorage.setString(LocalStorageKeys.token, LocalStorage.token);
    LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId);
    print("klsdjfdkfj😍😍😍😍 ${LocalStorage.userId}");

    // আপনার প্রোভাইডার অ্যাপের প্রোফাইল চেকিং কন্ডিশন ও সঠিক স্ক্রিনে নেভিগেট করা
    if (await checkProfile() == false) {
      Get.toNamed(AppRoutes.complete_profile_screen);
    } else {
      Get.offAllNamed(AppRoutes.homeNav);
    }
  }
}