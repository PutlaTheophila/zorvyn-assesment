import 'package:equatable/equatable.dart';

class CategorySpending extends Equatable {
  final String category;
  final double amount;
  final double percentage;

  const CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [category, amount, percentage];
}

class SpendingInsight extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double savingsRate;
  final List<CategorySpending> categoryBreakdown;
  final String topCategory;
  final double averageDailySpending;

  const SpendingInsight({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.savingsRate,
    required this.categoryBreakdown,
    required this.topCategory,
    required this.averageDailySpending,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        balance,
        savingsRate,
        categoryBreakdown,
        topCategory,
        averageDailySpending,
      ];
}
