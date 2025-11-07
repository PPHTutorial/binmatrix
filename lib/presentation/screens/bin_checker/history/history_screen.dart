import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../providers/history_provider.dart';
import '../../../widgets/bin_info_card.dart';
import '../../../widgets/native_ad_widget.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (history.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(historyProvider.notifier).reload();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: history.length +
            (history.length > 3 ? ((history.length - 1) ~/ 4) : 0) +
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
              actualIndex < history.length) {
            return Column(
              children: [
                const NativeAdWidget(height: 250),
                SizedBox(height: 12.h),
                BinInfoCard(binInfo: history[actualIndex]),
              ],
            );
          }

          // Show ad at the end
          if (actualIndex == history.length) {
            return const NativeAdWidget(height: 250);
          }

          // Regular history item
          if (actualIndex < history.length) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: BinInfoCard(binInfo: history[actualIndex]),
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
            Icons.history_outlined,
            size: 64.sp,
            color:
                isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
          SizedBox(height: 20.h),
          Text(
            'No History Yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your BIN lookup history will appear here',
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
