import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/setting/data/model/tearm_condition_model.dart';
import '../../../../services/api/api_service.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/enum/enum.dart';

class TermsOfServicesController extends GetxController {
  /// Api status check here
  Status status = Status.completed;

  ///  HTML model initialize here
  TearmConditionModel data = TearmConditionModel.fromJson({});

  /// Terms of services Controller instance create here
  static TermsOfServicesController get instance =>
      Get.put(TermsOfServicesController());

  ///  Terms of services Api call here
  geTermsOfServicesRepo() async {
    status = Status.loading;
    update();

    var response = await ApiService.get(ApiEndPoint.termsCondition);

    if (response.statusCode == 200) {
      data = TearmConditionModel.fromJson(response.data['data']);

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
    geTermsOfServicesRepo();
    super.onInit();
  }
}
