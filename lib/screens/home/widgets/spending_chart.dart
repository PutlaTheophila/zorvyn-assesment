import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../models/transaction.dart' as model;
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class SpendingChart extends StatelessWidget {
  final List<model.Transaction> transactions;

  const SpendingChart({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final categoryData = _getCategoryData();

    if (categoryData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 48,
                color: AppColors.adaptiveSecondaryText(context).withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No expense data available',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.adaptiveSecondaryText(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort categories by amount (highest first) and take top 5
    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(5).toList();
    final totalAmount = categoryData.values.fold(0.0, (sum, amount) => sum + amount);

    return Column(
      children: [
        ...topCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final categoryEntry = entry.value;
          final categoryName = categoryEntry.key;
          final amount = categoryEntry.value;
          final percentage = (amount / totalAmount * 100);
          final categoryInfo = _getCategoryInfo(categoryName);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    // Lottie Icon
                    Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (categoryInfo['color'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Lottie.asset(
                        categoryInfo['lottie'] as String,
                        fit: BoxFit.contain,
                        repeat: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Category name and bar
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                categoryName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.adaptiveText(context),
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(amount),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: categoryInfo['color'] as Color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 6,
                              backgroundColor: AppColors.adaptiveDivider(context).withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                categoryInfo['color'] as Color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${percentage.toStringAsFixed(1)}% of total spending',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.adaptiveSecondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (index < topCategories.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.dividerColor.withValues(alpha: 0.5),
                ),
            ],
          );
        }),
      ],
    );
  }

  Map<String, double> _getCategoryData() {
    final expenses = transactions.where(
      (t) => t.type == model.TransactionType.expense,
    );

    if (expenses.isEmpty) return {};

    final categoryTotals = <String, double>{};

    for (final transaction in expenses) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryTotals;
  }

  Map<String, dynamic> _getCategoryInfo(String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('food') || categoryLower.contains('dining') || categoryLower.contains('restaurant')) {
      return {
        'lottie': 'assets/lotties/Food Carousel.json',
        'color': const Color(0xFFFF9066),
      };
    } else if (categoryLower.contains('shopping') || categoryLower.contains('retail') || categoryLower.contains('grocery')) {
      return {
        'lottie': 'assets/lotties/shopping cart.json',
        'color': const Color(0xFF9B88FF),
      };
    } else if (categoryLower.contains('transport') || categoryLower.contains('travel') || categoryLower.contains('car')) {
      return {
        'lottie': 'assets/lotties/Red Car Drive.json',
        'color': const Color(0xFF4ADE80),
      };
    } else if (categoryLower.contains('entertainment') || categoryLower.contains('fun') || categoryLower.contains('movie')) {
      return {
        'lottie': 'assets/lotties/Watch a movie with popcorn.json',
        'color': const Color(0xFFFF6B9D),
      };
    } else if (categoryLower.contains('health') || categoryLower.contains('medical')) {
      return {
        'lottie': 'assets/lotties/Budget Tracker.json',
        'color': const Color(0xFFFF5757),
      };
    } else if (categoryLower.contains('utilities') || categoryLower.contains('bills')) {
      return {
        'lottie': 'assets/lotties/Budget Tracker.json',
        'color': const Color(0xFFFFB74D),
      };
    } else if (categoryLower.contains('education') || categoryLower.contains('learning')) {
      return {
        'lottie': 'assets/lotties/Budget Tracker.json',
        'color': const Color(0xFF6C63FF),
      };
    } else if (categoryLower.contains('investment') || categoryLower.contains('savings')) {
      return {
        'lottie': 'assets/lotties/piggybank.json',
        'color': const Color(0xFF00BFA6),
      };
    }

    return {
      'lottie': 'assets/lotties/Budget Tracker.json',
      'color': AppColors.primary,
    };
  }
}

