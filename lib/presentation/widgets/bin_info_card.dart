import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/bin_info.dart';
import '../../app/themes/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/favorites_provider.dart';

/// Clean, minimal card widget to display BIN information
class BinInfoCard extends ConsumerWidget {
  final BinInfo binInfo;

  const BinInfoCard({
    super.key,
    required this.binInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFavorite = ref.watch(isFavoriteProvider(binInfo.bin));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Clean Header Card
        _buildHeaderCard(context, isDark, isFavorite, ref),
        SizedBox(height: 12.h),
        // Information Section
        _buildInfoSection(context, isDark),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isDark, bool isFavorite, WidgetRef ref) {
    final brandColor = AppColors.getBrandColor(binInfo.brand);
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          left: BorderSide(color: brandColor, width: 4),
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: brandColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.credit_card_rounded,
                  color: brandColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      binInfo.brand,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'BIN: ${binInfo.bin}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.error : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                      size: 22.sp,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(favoritesProvider.notifier).toggleFavorite(binInfo);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share_outlined,
                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      size: 22.sp,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _shareBinInfo(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildInfoRow(
          context,
          icon: Icons.account_balance_outlined,
          label: 'Bank',
          value: binInfo.bank.isNotEmpty ? binInfo.bank : 'N/A',
          isDark: isDark,
        ),
        SizedBox(height: 8.h),
        _buildInfoRow(
          context,
          icon: Icons.category_outlined,
          label: 'Type',
          value: binInfo.type.isNotEmpty ? binInfo.type : 'N/A',
          valueColor: AppColors.getTypeColor(binInfo.type),
          isDark: isDark,
        ),
        SizedBox(height: 8.h),
        _buildInfoRow(
          context,
          icon: Icons.star_outline,
          label: 'Level',
          value: binInfo.formattedLevel,
          isDark: isDark,
        ),
        SizedBox(height: 8.h),
        _buildInfoRow(
          context,
          icon: Icons.public_outlined,
          label: 'Country',
          value: binInfo.country.isNotEmpty ? binInfo.country : 'N/A',
          isDark: isDark,
        ),
        if (binInfo.phone.isNotEmpty) ...[
          SizedBox(height: 8.h),
          _buildInfoRow(
            context,
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: binInfo.phone,
            isTappable: true,
            onTap: () => _callPhone(context, binInfo.phone),
            isDark: isDark,
          ),
        ],
        if (binInfo.website.isNotEmpty) ...[
          SizedBox(height: 8.h),
          _buildInfoRow(
            context,
            icon: Icons.language_outlined,
            label: 'Website',
            value: binInfo.website,
            isTappable: true,
            onTap: () => _openWebsite(context, binInfo.website),
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isTappable = false,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isTappable ? onTap : null,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isDark ? AppColors.darkCard : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: isDark ? AppColors.textSecondary : AppColors.secondaryColor.withOpacity(0.7),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? AppColors.textSecondary : AppColors.secondaryColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: valueColor ?? (isDark ? Colors.white : AppColors.lightTextPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              if (isTappable)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: isDark ? AppColors.textSecondary : AppColors.secondaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareBinInfo(BuildContext context) {
    final text = '''
BinMatrix - BIN Information

BIN: ${binInfo.bin}
Brand: ${binInfo.brand}
Bank: ${binInfo.bank}
Type: ${binInfo.type}
Level: ${binInfo.formattedLevel}
Country: ${binInfo.country}
${binInfo.phone.isNotEmpty ? 'Phone: ${binInfo.phone}' : ''}
${binInfo.website.isNotEmpty ? 'Website: ${binInfo.website}' : ''}

Checked with BinMatrix App!
''';

    Share.share(text, subject: 'BIN Information - ${binInfo.bin}');
  }

  Future<void> _callPhone(BuildContext context, String phone) async {
    try {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot make phone call to $phone')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _openWebsite(BuildContext context, String website) async {
    try {
      String url = website.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot open website: $website')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
