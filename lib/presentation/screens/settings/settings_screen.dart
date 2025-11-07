import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../../app/themes/app_colors.dart';
import '../../../services/storage/cache_service.dart';
import '../../providers/theme_provider.dart';

/// Settings screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _cacheSize = 'Calculating...';
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
    _loadAppInfo();
  }

  Future<void> _loadCacheSize() async {
    final size = await CacheService.instance.getFormattedCacheSize();
    if (mounted) {
      setState(() {
        _cacheSize = size;
      });
    }
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.lightTextPrimary,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          _buildSection('Appearance', [
            _buildThemeTile(isDark),
          ]),
          SizedBox(height: 24.h),
          _buildSection('Storage', [
            _buildInfoTile(
              icon: Icons.storage_outlined,
              title: 'Cache Size',
              subtitle: _cacheSize,
              isDark: isDark,
            ),
            _buildActionTile(
              icon: Icons.delete_outline,
              title: 'Clear Cache',
              onTap: _clearCache,
              isDark: isDark,
            ),
          ]),
          SizedBox(height: 24.h),
          _buildSection('About', [
            _buildInfoTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: _appVersion,
              isDark: isDark,
            ),
            _buildActionTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => _showPrivacyPolicy(context),
              isDark: isDark,
            ),
            _buildActionTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => _showTermsOfService(context),
              isDark: isDark,
            ),
            _buildActionTile(
              icon: Icons.star_outline,
              title: 'Rate App',
              onTap: _rateApp,
              isDark: isDark,
            ),
            _buildActionTile(
              icon: Icons.email_outlined,
              title: 'Contact Support',
              subtitle: 'deverloper.codeink.playconsole@gmail.com',
              onTap: _contactSupport,
              isDark: isDark,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondary : AppColors.secondaryColor.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildThemeTile(bool isDark) {
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(themeModeProvider);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: 20.sp,
                color: isDark ? AppColors.textSecondary : AppColors.secondaryColor,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      themeMode == ThemeMode.light
                          ? 'Light'
                          : themeMode == ThemeMode.dark
                              ? 'Dark'
                              : 'System',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                },
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? AppColors.textSecondary : AppColors.secondaryColor.withOpacity(0.8),
                        ),
                      ),
                    ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: isDark ? AppColors.textSecondary : AppColors.secondaryColor,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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

  Future<void> _clearCache() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will clear all cached data. The app may need to re-fetch data on next use.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CacheService.instance.clearCache();
      await _loadCacheSize();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  Future<void> _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    try {
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        await _launchUrl(
          Platform.isAndroid
              ? 'https://play.google.com/store/apps/details?id=com.codeink.stsl.binmatrix'
              : 'https://apps.apple.com/app/idYOUR_APP_ID',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open app store')),
        );
      }
    }
  }

  Future<void> _contactSupport() async {
    final email = 'deverloper.codeink.playconsole@gmail.com';
    final subject = 'BinMatrix App Support';
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}',
    );
    await _launchUrl(uri.toString());
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(_privacyPolicyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text(_termsOfServiceText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static String get _privacyPolicyText => '''
PRIVACY POLICY

Last updated: December ${DateTime.now().year}

1. INFORMATION WE COLLECT

Information You Provide:
- BIN lookup history (stored locally on your device)
- Favorite BINs (stored locally on your device)
- App preferences like theme settings

Automatically Collected:
- Device information (type, OS version, identifiers)
- Usage data for analytics
- Cache data for app performance

Third-Party Services:
- Google AdMob: Device identifiers and advertising data (for free users)
- Google Play/App Store: Purchase information for subscriptions

2. HOW WE USE YOUR INFORMATION
- Provide BIN lookup services
- Remember your preferences and history
- Display relevant advertisements (free users)
- Improve app functionality
- Provide customer support

3. DATA STORAGE
All your data (history, favorites, preferences) is stored LOCALLY on your device. We do NOT transmit your BIN lookups or personal data to our servers.

Third-party services (AdMob, app stores) may collect data according to their privacy policies.

4. YOUR RIGHTS
- View and delete your lookup history
- Clear favorites and cache
- Opt-out of ads (upgrade to Pro or use device settings)
- Uninstall the app to delete all local data

5. CHILDREN'S PRIVACY
BinMatrix is not intended for children under 13. We do not knowingly collect information from children.

6. CONTACT US
Email: deverloper.codeink.playconsole@gmail.com

For the complete Privacy Policy, visit:
https://binmatrix.app/privacy
''';

  static String get _termsOfServiceText => '''
TERMS OF SERVICE

Last updated: ${DateTime.now().year}

1. ACCEPTANCE OF TERMS
By accessing and using BinMatrix, you accept and agree to be bound by the terms and provision of this agreement.

2. USE LICENSE
Permission is granted to temporarily download one copy of the materials on BinMatrix for personal, non-commercial transitory viewing only.

3. DISCLAIMER
The materials on BinMatrix are provided on an 'as is' basis. BinMatrix makes no warranties, expressed or implied.

4. LIMITATIONS
In no event shall BinMatrix or its suppliers be liable for any damages arising out of the use or inability to use the materials on BinMatrix.

5. CONTENT
All BIN data and information are provided for personal use only. Redistribution or commercial use is prohibited.

6. MODIFICATIONS
BinMatrix may revise these terms at any time without notice. By using this app, you agree to be bound by the current version of these terms.

7. CONTACT INFORMATION
For questions about these Terms, please contact us at deverloper.codeink.playconsole@gmail.com
''';
}
