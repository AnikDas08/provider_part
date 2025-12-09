import 'package:get/get.dart';

class HomeNavController extends GetxController {
  RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final argIndex = Get.arguments?['index'];
    if (argIndex != null) {
      selectedIndex.value = argIndex;
    }
  }

  void changeIndex(int index) {
    if (index == selectedIndex.value) return; // Prevent rebuilding if same index
    selectedIndex.value = index;
  }
}
