import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App logo widget using the BinMatrix image asset
class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final bool showText;
  
  const AppLogo({
    super.key,
    this.height,
    this.width,
    this.padding,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Image.asset(
        'assets/images/binmatrixlogo.png',
        height: height ?? 65.h,
        width: width,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image not found
          return Container(
            height: height ?? 80.h,
            width: width,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Image.asset(
              'assets/images/binmatrixlogo.png',
              height: height ?? 65.h,
              width: width,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}

