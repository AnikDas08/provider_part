import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../component/image/common_image.dart';
import '../../../../utils/constants/app_colors.dart';

class WorkPhotoGrid extends StatelessWidget {
  final List<String> photos;
  final VoidCallback? onViewAll;

  const WorkPhotoGrid({super.key, required this.photos, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1,
      ),
      itemCount: photos.length > 4 ? 4 : photos.length,
      itemBuilder: (context, index) {
        if (index == 3 && photos.length > 4) {
          // Show "View All" overlay on the 4th item
          return _buildViewAllItem(photos[index]);
        }
        return _buildPhotoItem(photos[index]);
      },
    );
  }

  Widget _buildPhotoItem(String photoUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: CommonImage(
          imageSrc: photoUrl,
          width: double.infinity,
          height: double.infinity,
          fill: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildViewAllItem(String photoUrl) {
    return GestureDetector(
      onTap: onViewAll,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Stack(
            children: [
              CommonImage(
                imageSrc: photoUrl,
                width: double.infinity,
                height: double.infinity,
                fill: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library,
                        color: AppColors.white,
                        size: 24.w,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "+${photos.length - 3}",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
