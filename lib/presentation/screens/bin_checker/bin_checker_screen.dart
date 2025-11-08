import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/themes/app_colors.dart';
import '../../providers/bin_provider.dart';
import '../../widgets/bin_info_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/ad_banner_widget.dart';
import '../../widgets/native_ad_widget.dart';
import 'history/history_screen.dart';
import 'favorites/favorites_screen.dart';
import '../settings/settings_screen.dart';

/// Main BIN Checker Screen
class BinCheckerScreen extends ConsumerStatefulWidget {
  const BinCheckerScreen({super.key});

  @override
  ConsumerState<BinCheckerScreen> createState() => _BinCheckerScreenState();
}

class _BinCheckerScreenState extends ConsumerState<BinCheckerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _binController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _binController.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final bin = _binController.text.trim();
    if (bin.isEmpty) {
      _showSnackBar('Please enter a BIN number', isError: true);
      return;
    }

    if (bin.length < 6 || bin.length > 8) {
      _showSnackBar('BIN must be 6-8 digits', isError: true);
      return;
    }

    HapticFeedback.mediumImpact();
    _focusNode.unfocus();
    ref.read(binLookupProvider.notifier).lookupBin(bin);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onClear() {
    _binController.clear();
    _focusNode.requestFocus();
    ref.read(binLookupProvider.notifier).clear();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final binState = ref.watch(binLookupProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),
            // Search Section
            _buildSearchSection(context, isDark),
            // Tab Bar
            _buildTabBar(isDark),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLookupTab(binState, isDark),
                  const HistoryScreen(),
                  const FavoritesScreen(),
                ],
              ),
            ),
            // Banner Ad (bottom of screen)
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      child: Row(
        children: [
          Icon(
            Icons.credit_card_rounded,
            size: 28.sp,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BinMatrix',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'BIN Checker & Validator',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              size: 24.sp,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _binController,
              autofocus: false,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Enter 6-8 digit BIN',
                hintStyle: TextStyle(              
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 15.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primaryColor,
                  size: 22.sp,
                ),
                suffixIcon: _binController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        onPressed: _onClear,
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkCard : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkCard : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkCard : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: _onSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Icon(Icons.search, size: 22.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor:
            isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.search), text: 'Lookup'),
          Tab(icon: Icon(Icons.history), text: 'History'),
          Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
        ],
      ),
    );
  }

  Widget _buildLookupTab(AsyncValue binState, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: binState.when(
        data: (binInfo) {
          if (binInfo == null) {
            return Column(
              children: [
                _buildWelcomeView(isDark),
                SizedBox(height: 20.h),
                const NativeAdWidget(height: 250),
              ],
            );
          }
          return Column(
            children: [
              BinInfoCard(binInfo: binInfo),
              SizedBox(height: 20.h),
              const NativeAdWidget(height: 250),
            ],
          );
        },
        loading: () => SizedBox(
          height: 400.h,
          child: const Center(child: LoadingIndicator()),
        ),
        error: (error, stack) => _buildErrorView(error, isDark),
      ),
    );
  }

  Widget _buildWelcomeView(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 60.h),
        Icon(
          Icons.credit_card_rounded,
          size: 80.sp,
          color: AppColors.primaryColor.withOpacity(0.5),
        ),
        SizedBox(height: 24.h),
        Text(
          'Welcome to BinMatrix',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            'Enter a 6-8 digit BIN number to get detailed card information, bank details, and more.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: 40.h),
        _buildFeatureList(isDark),
      ],
    );
  }

  Widget _buildFeatureList(bool isDark) {
    final features = [
      {'icon': Icons.account_balance, 'title': 'Bank Information'},
      {'icon': Icons.category, 'title': 'Card Type & Level'},
      {'icon': Icons.public, 'title': 'Country & Region'},
      {'icon': Icons.phone, 'title': 'Contact Details'},
    ];

    return Column(
      children: features.map((feature) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color:
                      isDark ? AppColors.primaryColor : AppColors.primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                feature['title'] as String,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorView(Object error, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppColors.error.withOpacity(0.7),
            ),
            SizedBox(height: 20.h),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              error.toString().replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                if (_binController.text.isNotEmpty) {
                  ref
                      .read(binLookupProvider.notifier)
                      .lookupBin(_binController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
