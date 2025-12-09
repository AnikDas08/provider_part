import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../../utils/app_bar/custom_appbars.dart';
import '../../../../utils/constants/app_string.dart';
import '../../../home/widget/home_custom_button.dart';
import '../controller/scan_controller.dart';

class QRScannerScreen extends StatelessWidget {
  final QRScannerController controller = Get.put(QRScannerController());

  QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.r),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(title: AppString.scan,showBackButton: false,),
              SizedBox(height: 12.h),
              CommonText(
                text: AppString.qr_details,
                fontSize: 14.sp,
                maxLines: 2,
                fontWeight: FontWeight.w500,
                color: AppColors.black400,
              ),
              SizedBox(height: 20.h),

              // QR Scanner View
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Obx(() {
                      return controller.isScanning.value
                          ? QRView(
                        key: controller.qrKey,
                        onQRViewCreated: controller.onQRViewCreated,
                        overlay: QrScannerOverlayShape(
                          borderColor: Colors.white,
                          borderRadius: 20,
                          borderLength: 30,
                          borderWidth: 8,
                          cutOutSize: MediaQuery.of(context).size.width * 0.7,
                        ),
                      )
                          : Center(
                        child: Text(
                          AppString.pauseScan,
                          style: TextStyle(fontSize: 16.sp, color: Colors.black54),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Scan Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                width: 217.w,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    // You can add manual trigger functionality here
                    controller.resumeScanning();
                    //controller.showSuccessDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/scan_icon.svg', // Add your scan icon asset
                        height: 20.h,
                        width: 20.w,
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 20,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        AppString.scan,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    height: 2.h,
                    width: 158.w,
                    color: AppColors.black50,
                  ),
                  SizedBox(width: 10,),
                  CommonText(
                    text: AppString.or,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black400,
                  ),
                  SizedBox(width: 10,),
                  Container(
                    height: 2,
                    width: 158,
                    color: AppColors.black50,
                  ),
                ],
              ),

              const SizedBox(height: 20),
              /*CustomButton(
                  text: AppString.barcode_text,
                  height: 44,
                  isSelected: false,
                  onTap: (){

                  }),*/
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.red300),
                ),
                child: TextField(
                  controller: controller.barController,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                  ),
                  decoration: InputDecoration(
                    hintText: AppString.userId,
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.red100,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Confirm Button
              /*Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle confirm action
                    if (controller.scannedData.value.isNotEmpty) {
                      // Process the scanned data
                      print('Confirmed data: ${controller.scannedData.value}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: CommonText(text: "Scan")
                ),
              ),*/
              CustomButton(
                  text: AppString.confirm_button,
                  isSelected: true,
                  onTap: () {
                    // Call the confirmManualId method instead of confirmDialog
                    controller.confirmManualId();
                  }
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

