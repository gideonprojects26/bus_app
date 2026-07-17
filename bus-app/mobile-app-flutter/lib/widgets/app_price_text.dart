import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// Consistent, prominent price display used wherever a total is the
// primary thing the person should notice on screen (Booking summary,
// Payment screens, Receipt) — deliberately larger and bolder than
// surrounding text so it reads as "the number that matters."
class AppPriceText extends StatelessWidget {
  final String currency;
  final double amount;
  final bool isLocal;
  final double fontSize;

  const AppPriceText({
    super.key,
    required this.currency,
    required this.amount,
    required this.isLocal,
    this.fontSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$currency ',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: fontSize * 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: amount.toStringAsFixed(isLocal ? 0 : 2),
            style: TextStyle(
              color: AppColors.yellow,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}