import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final int rating;
  final String comment;
  final String avatarUrl;

  const ReviewCard({
    super.key,
    required this.name,
    required this.rating,
    required this.comment,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [
              // Avatar
              ClipOval(
                child: CommonImage(
                  imageSrc: avatarUrl,
                  size: 40.w,
                  fill: BoxFit.cover,
                ),
              ),

              SizedBox(width: 12.w),

              // Name and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: name,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          size: 16.w,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Comment
          CommonText(
            text: comment,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.black700,
            textAlign: TextAlign.left,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
