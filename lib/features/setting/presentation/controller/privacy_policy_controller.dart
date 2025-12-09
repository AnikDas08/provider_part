import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/setting/data/model/privacy_policy_model.dart';
import '../../../../services/api/api_service.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/enum/enum.dart';

class PrivacyPolicyController extends GetxController {
  /// Api status check here
  Status status = Status.completed;

  ///  HTML model initialize here
  PrivacyPolicyModel data = PrivacyPolicyModel.fromJson({});

  /// Privacy Policy Controller instance create here
  static PrivacyPolicyController get instance =>
      Get.put(PrivacyPolicyController());

  /// Privacy Policy Api call here
  getPrivacyPolicyRepo() async {
    status = Status.loading;
    update();

    var response = await ApiService.get(ApiEndPoint.privacyPolicy);

    if (response.statusCode == 200) {
      data = PrivacyPolicyModel.fromJson(response.data['data']);
      print("dkljkldjfkdf 😍😍😍😍");
      status = Status.completed;
      update();
    } else {
      Utils.errorSnackBar(response.statusCode, response.message);
      status = Status.error;
      update();
    }
  }

  /// Controller on Init here
  @override
  void onInit() {
    getPrivacyPolicyRepo();
    super.onInit();
  }
}
