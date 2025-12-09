import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/app_storage/app_auth_storage.dart';
import 'package:haircutmen_user_app/component/app_storage/storage_key.dart';
import 'package:haircutmen_user_app/features/profile/data/profile_model.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import 'package:haircutmen_user_app/utils/helpers/other_helper.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/app_utils.dart';

class ProfileController extends GetxController {
  static ProfileController instance = Get.put(ProfileController());

  /// Language List here
  List languages = ["English", "French", "Arabic"];

  /// form key here
  final formKey = GlobalKey<FormState>();

  /// select Language here
  String selectedLanguage = "English";

  /// select image here
  String? image;

  /// edit button loading here
  bool isLoading = false;

  /// all controller here
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  var name = "".obs;
  var phone = "".obs;
  var email = "".obs;
  var location = "".obs;
  var images = "".obs;
  var id = "".obs;
  var rating = 0.0.obs;
  var review = 0.obs;
  var category= "".obs;

  ProfileData? profileData;
  bool isProfileLoading = false;
  var countrCode = "".obs;
  var fullNumber = "".obs;

  @override
  void onInit() {
    super.onInit();
    getProfile();
    getRating();
  }

  /// select image function here
  getProfileImage() async {
    image = await OtherHelper.openGalleryForProfile();
    update();
  }

  /// select language  function here
  selectLanguage(int index) {
    selectedLanguage = languages[index];
    update();
    Get.back();
  }

  Future<void> getProfile() async {
    isProfileLoading = true;
    update();
    try {
      final token = AppAuthStorage().getValue(StorageKey.token);
      final response = await ApiService.get(
        ApiEndPoint.getProvider,
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );
      if (response.statusCode == 200) {
        /*final profileModel = ProfileModel.fromJson(response.data);
        profileData = profileModel.data;*/
        /*nameController.text = profileData?.name ?? "";
        numberController.text = profileData?.contact ?? "";
        name.value = profileData?.name ?? "";
        phone.value = profileData?.contact ?? "";
        email.value = profileData?.email ?? "";
        location.value = profileData?.location ?? "";
        images.value = profileData?.image ?? "";*/


        nameController.text = response.data["data"]["user"]["name"] ?? "";
        numberController.text = response.data["data"]["user"]["contact"] ?? "";
        name.value = response.data["data"]["user"]["name"] ?? "";
        phone.value = response.data["data"]["user"]["contact"] ?? "";
        email.value = response.data["data"]["user"]["email"] ?? "";
        location.value = response.data["data"]["user"]["location"] ?? "";
        images.value = response.data["data"]["user"]["image"] ?? "";
        category.value = response.data["data"]["services"]?[0]?["category"]?["name"] ?? "";
        countrCode.value = response.data["data"]["user"]["countryCode"];
        fullNumber.value = "${countrCode.value} ${phone.value}";

        update();
      } else {
        ///rtrfgg
        //Utils.errorSnackBar(response.statusCode, response.message);
      }
    } catch (e) {
      //Utils.errorSnackBar(0, e.toString());
    }
    isProfileLoading = false;
    update();
  }

  Future<void> getRating()async{
    try {
      final token = AppAuthStorage().getValue(StorageKey.token);
      final response = await ApiService.get(
        ApiEndPoint.review,
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );
      if (response.statusCode == 200) {
        //print("rating 😍😍😍😍 "+rating.value.toString());
        var avg = response.data["data"]["averageRating"];
        var total = response.data["data"]["totalReviews"];

        rating.value = (avg ?? 0).toDouble();  // ✅ null safe + convert to double
        review.value = (total ?? 0);

        print("rating 😍😍😍😍 ${rating.value}"); // ✅ will print now
        update();
      } else {
        Get.snackbar("Error", response.message);
      }
    } catch (e) {

    }
  }

  /// update profile function here
  Future<void> editProfileRepo() async {
    if (!formKey.currentState!.validate()) return;

    if (!LocalStorage.isLogIn) return;
    isLoading = true;
    update();

    Map<String, String> body = {
      "fullName": nameController.text,
      "phone": numberController.text,
    };

    var response = await ApiService.multipart(
      ApiEndPoint.user,
      body: body,
      imagePath: image,
      imageName: "image",
    );

    if (response.statusCode == 200) {
      var data = response.data;

      LocalStorage.userId = data['data']?["_id"] ?? "";
      LocalStorage.myImage = data['data']?["image"] ?? "";
      LocalStorage.myName = data['data']?["fullName"] ?? "";
      LocalStorage.myEmail = data['data']?["email"] ?? "";

      LocalStorage.setString("userId", LocalStorage.userId);
      LocalStorage.setString("myImage", LocalStorage.myImage);
      LocalStorage.setString("myName", LocalStorage.myName);
      LocalStorage.setString("myEmail", LocalStorage.myEmail);

      Utils.successSnackBar("Successfully Profile Updated", response.message);
      Get.toNamed(AppRoutes.profile);
    } else {
      Utils.errorSnackBar(response.statusCode, response.message);
    }

    isLoading = false;
    update();
  }
}
