import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/bin_info.dart';
import '../../app/themes/app_colors.dart';

/// Card widget to display BIN information
class BinInfoCard extends StatelessWidget {
  final BinInfo binInfo;

  const BinInfoCard({
    super.key,
    required this.binInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Card with Brand
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.getBrandColor(binInfo.brand),
                  AppColors.getBrandColor(binInfo.brand).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      binInfo.brandIcon,
                      style: TextStyle(fontSize: 48.sp),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () => _shareBinInfo(context),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  binInfo.brand,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'BIN: ${binInfo.bin}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Information Cards
        _buildInfoSection(context, [
          _InfoItem(
            icon: Icons.account_balance,
            label: 'Bank',
            value: binInfo.bank.isNotEmpty ? binInfo.bank : 'N/A',
            iconColor: AppColors.primaryColor,
          ),
          _InfoItem(
            icon: Icons.category,
            label: 'Type',
            value: binInfo.type,
            iconColor: AppColors.getTypeColor(binInfo.type),
          ),
          _InfoItem(
            icon: Icons.star,
            label: 'Level',
            value: binInfo.formattedLevel,
            iconColor: AppColors.secondaryColor,
          ),
          _InfoItem(
            icon: Icons.public,
            label: 'Country',
            value: binInfo.country,
            iconColor: AppColors.info,
          ),
          if (binInfo.phone.isNotEmpty)
            _InfoItem(
              icon: Icons.phone,
              label: 'Phone',
              value: binInfo.phone,
              iconColor: AppColors.success,
              isTappable: true,
              onTap: () => _callPhone(context, binInfo.phone),
            ),
          if (binInfo.website.isNotEmpty)
            _InfoItem(
              icon: Icons.language,
              label: 'Website',
              value: binInfo.website,
              iconColor: AppColors.info,
              isTappable: true,
              onTap: () => _openWebsite(context, binInfo.website),
            ),
        ]),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, List<_InfoItem> items) {
    return Column(
      children: items.map((item) => _buildInfoTile(context, item)).toList(),
    );
  }

  Widget _buildInfoTile(BuildContext context, _InfoItem item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: item.isTappable ? item.onTap : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: item.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  item.icon,
                  color: item.iconColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 12.sp,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (item.isTappable)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
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
Level: ${binInfo.level}
Country: ${binInfo.country}
''';

    Share.share(text, subject: 'BIN Information - ${binInfo.bin}');
  }

  void _callPhone(BuildContext context, String phone) {
    // Implement phone call functionality
    // url_launcher can be used here
  }

  void _openWebsite(BuildContext context, String website) {
    // Implement website opening functionality
    // url_launcher can be used here
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final bool isTappable;
  final VoidCallback? onTap;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.isTappable = false,
    this.onTap,
  });
}

