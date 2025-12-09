import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';

class ServiceProviderCard extends StatelessWidget {
  final String name;
  final String service;
  final String distance;
  final String rating;
  final String reviews;
  final String price;
  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const ServiceProviderCard({
    super.key,
    required this.name,
    required this.service,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.imageUrl,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  child: CommonImage(
                    imageSrc: imageUrl,
                    width: double.infinity,
                    height: 120.h,
                    fill: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 18.w,
                        color: AppColors.black600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    CommonText(
                      text: name,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                    ),

                    SizedBox(height: 4.h),

                    // Service with icon
                    Row(
                      children: [
                        Icon(
                          Icons.content_cut,
                          size: 14.w,
                          color: AppColors.black600,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: CommonText(
                            text: service,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black600,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    // Distance with icon
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.w,
                          color: AppColors.black600,
                        ),
                        SizedBox(width: 4.w),
                        CommonText(
                          text: "${AppString.distance} : $distance",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black600,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Rating and Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(Icons.star, size: 14.w, color: Colors.amber),
                            SizedBox(width: 2.w),
                            CommonText(
                              text: "$rating ($reviews)",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),

                        // Price
                        CommonText(
                          text: price,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
