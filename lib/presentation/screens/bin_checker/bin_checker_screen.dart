import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/themes/app_colors.dart';
import '../../providers/bin_provider.dart';
import '../../widgets/bin_info_card.dart';
import '../../widgets/loading_indicator.dart';

/// Main BIN Checker Screen
class BinCheckerScreen extends ConsumerStatefulWidget {
  const BinCheckerScreen({super.key});

  @override
  ConsumerState<BinCheckerScreen> createState() => _BinCheckerScreenState();
}

class _BinCheckerScreenState extends ConsumerState<BinCheckerScreen> {
  final TextEditingController _binController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasSearched = false;

  @override
  void dispose() {
    _binController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch() {
    final bin = _binController.text.trim();
    if (bin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a BIN number')),
      );
      return;
    }

    if (bin.length < 6 || bin.length > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('BIN must be 6-8 digits')),
      );
      return;
    }

    setState(() => _hasSearched = true);
    _focusNode.unfocus();
    ref.read(binLookupProvider.notifier).lookupBin(bin);
  }

  void _onClear() {
    _binController.clear();
    setState(() => _hasSearched = false);
    _focusNode.requestFocus();
    ref.read(binLookupProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final binState = ref.watch(binLookupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BinMatrix'),
        elevation: 0,
        actions: [
          if (_hasSearched)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _onClear,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Section
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter BIN Number',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _binController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter 6-8 digit BIN',
                      prefixIcon: const Icon(Icons.credit_card),
                      suffixIcon: _binController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _binController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => setState(() {}),
                    onSubmitted: (_) => _onSearch(),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _onSearch,
                      icon: const Icon(Icons.search),
                      label: const Text('Lookup BIN'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Results Section
            Expanded(
              child: binState.when(
                data: (binInfo) {
                  if (!_hasSearched) {
                    return _buildWelcomeView();
                  }

                  if (binInfo == null) {
                    return _buildNotFoundView();
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: BinInfoCard(binInfo: binInfo),
                  );
                },
                loading: () => const Center(child: LoadingIndicator()),
                error: (error, stack) => _buildErrorView(error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_rounded,
            size: 80.sp,
            color: AppColors.primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 24.h),
          Text(
            'Welcome to BinMatrix',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'Enter a 6-8 digit BIN number to get detailed card information',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80.sp,
            color: AppColors.error.withOpacity(0.5),
          ),
          SizedBox(height: 24.h),
          Text(
            'BIN Not Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12.h),
          Text(
            'No information found for this BIN number',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 80.sp,
            color: AppColors.error.withOpacity(0.5),
          ),
          SizedBox(height: 24.h),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12.h),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => ref.read(binLookupProvider.notifier).lookupBin(_binController.text),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

