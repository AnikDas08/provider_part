import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';

class ServiceCategoryItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const ServiceCategoryItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColors.red50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CommonImage(
                imageSrc: icon,
                size: 24.w,
                imageColor: AppColors.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          CommonText(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
