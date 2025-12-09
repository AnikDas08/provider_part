import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';

class ServiceItemCard extends StatelessWidget {
  final String serviceName;
  final String duration;
  final String price;
  final VoidCallback? onTap;

  const ServiceItemCard({
    super.key,
    required this.serviceName,
    required this.duration,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.black100, width: 1),
        ),
        child: Row(
          children: [
            // Service icon
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.content_cut,
                size: 14.w,
                color: AppColors.white,
              ),
            ),

            SizedBox(width: 12.w),

            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: serviceName,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 2.h),
                  CommonText(
                    text: duration,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black600,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),

            // Price
            CommonText(
              text: price,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
