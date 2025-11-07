import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../providers/favorites_provider.dart';
import '../../../widgets/bin_info_card.dart';
import '../../../widgets/native_ad_widget.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (favorites.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(favoritesProvider.notifier).reload();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: favorites.length +
            (favorites.length > 3 ? ((favorites.length - 1) ~/ 4) : 0) +
            1,
        itemBuilder: (context, index) {
          // Calculate how many ads should appear before this index
          int adsBefore = 0;
          for (int i = 4; i <= index; i += 4) {
            if (i <= index) adsBefore++;
          }

          int actualIndex = index - adsBefore;

          // Show native ad after every 4 items (after index 3, 7, 11, etc.)
          if (actualIndex > 0 &&
              actualIndex % 4 == 0 &&
              actualIndex < favorites.length) {
            return Column(
              children: [
                const NativeAdWidget(height: 250),
                SizedBox(height: 12.h),
                BinInfoCard(binInfo: favorites[actualIndex]),
              ],
            );
          }

          // Show ad at the end
          if (actualIndex == favorites.length) {
            return const NativeAdWidget(height: 250);
          }

          // Regular favorite item
          if (actualIndex < favorites.length) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: BinInfoCard(binInfo: favorites[actualIndex]),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64.sp,
            color:
                isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
          SizedBox(height: 20.h),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the heart icon to add BINs to favorites',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
