import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/transaction.dart' as model;
import '../../core/utils/currency_formatter.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriod = 1; // 0: Day, 1: Week, 2: Month, 3: Year
  int _selectedType = 0; // 0: All, 1: Expenses, 2: Income

  List<model.Transaction> _filterTransactionsByPeriod(List<model.Transaction> transactions) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 0: // Day
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 1: // Week
        startDate = DateTime(now.year, now.month, now.day - now.weekday + 1);
        break;
      case 2: // Month
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 3: // Year
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day - 7);
    }

    return transactions.where((t) => !t.date.isBefore(startDate)).toList();
  }

  List<Map<String, dynamic>> _getCategoryTotalsList(List<model.Transaction> transactions, model.TransactionType type) {
    final categoryTotals = <String, double>{};
    for (final transaction in transactions) {
      if (transaction.type == type) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    final categories = <Map<String, dynamic>>[];
    categoryTotals.forEach((name, amount) {
      String lottie = '';
      IconData icon = Icons.category_outlined;
      switch (name.toLowerCase()) {
        case 'food & dining':
        case 'restaurant':
          lottie = 'assets/lotties/Food Carousel.json';
          break;
        case 'education':
          icon = Icons.school_outlined;
          break;
        case 'entertainment':
          lottie = 'assets/lotties/Watch a movie with popcorn.json';
          break;
        case 'healthcare':
        case 'medicine':
          icon = Icons.medical_services_outlined;
          break;
        case 'shopping':
          lottie = 'assets/lotties/shopping cart.json';
          break;
        case 'transportation':
          lottie = 'assets/lotties/Red Car Drive.json';
          break;
        case 'grocery':
          lottie = 'assets/lotties/Grocery Lottie JSON animation.json';
          break;
        default:
          icon = Icons.category_outlined;
      }

      categories.add({
        'name': name,
        'amount': amount,
        'icon': icon,
        'lottie': lottie,
      });
    });

    categories.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
    return categories.take(4).toList();
  }

  List<double> _getChartData(List<model.Transaction> transactions, int period) {
    final now = DateTime.now();
    switch (period) {
      case 0: // Day
        final hourlyData = List<double>.filled(24, 0.0);
        for (var transaction in transactions) {
          final isToday = transaction.date.year == now.year &&
              transaction.date.month == now.month &&
              transaction.date.day == now.day;
          if (isToday) hourlyData[transaction.date.hour] += transaction.amount;
        }
        return hourlyData;
      case 1: // Week
        final weekData = List<double>.filled(7, 0.0);
        for (var transaction in transactions) {
          if (transaction.date.weekday >= 1 && transaction.date.weekday <= 7) {
            weekData[transaction.date.weekday - 1] += transaction.amount;
          }
        }
        return weekData;
      case 2: // Month
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final monthData = List<double>.filled(daysInMonth, 0.0);
        for (var transaction in transactions) {
          if (transaction.date.year == now.year && transaction.date.month == now.month) {
            if (transaction.date.day >= 1 && transaction.date.day <= daysInMonth) {
              monthData[transaction.date.day - 1] += transaction.amount;
            }
          }
        }
        return monthData;
      case 3: // Year
        final yearData = List<double>.filled(12, 0.0);
        for (var transaction in transactions) {
          if (transaction.date.year == now.year) {
            yearData[transaction.date.month - 1] += transaction.amount;
          }
        }
        return yearData;
      default:
        return List<double>.filled(7, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.adaptiveBackground(context),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Statistics',
          style: TextStyle(
            color: AppColors.adaptiveText(context),
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) return const Center(child: CircularProgressIndicator());
          if (state is TransactionError) return Center(child: Text('Error: ${state.message}'));

          if (state is TransactionLoaded) {
            if (state.transactions.isEmpty) {
              return const EmptyState(
                icon: Icons.insights,
                title: 'Not enough data',
                description: 'Add more transactions to see insights',
                lottiePath: 'assets/lotties/Budget Tracker.json',
              );
            }

            var baseTransactions = _filterTransactionsByPeriod(state.transactions);
            var filteredTransactions = baseTransactions;
            if (_selectedType == 1) {
              filteredTransactions = baseTransactions.where((t) => t.type == model.TransactionType.expense).toList();
            } else if (_selectedType == 2) {
              filteredTransactions = baseTransactions.where((t) => t.type == model.TransactionType.income).toList();
            }

            final periodTotalExpenses = baseTransactions
                .where((t) => t.type == model.TransactionType.expense)
                .fold(0.0, (sum, t) => sum + t.amount);
            final periodTotalIncome = baseTransactions
                .where((t) => t.type == model.TransactionType.income)
                .fold(0.0, (sum, t) => sum + t.amount);

            double displayAmount = periodTotalIncome - periodTotalExpenses;
            if (_selectedType == 1) displayAmount = periodTotalExpenses;
            if (_selectedType == 2) displayAmount = periodTotalIncome;

            final expenseTransactions = filteredTransactions.where((t) => t.type == model.TransactionType.expense).toList();
            final incomeTransactions = filteredTransactions.where((t) => t.type == model.TransactionType.income).toList();
            final expenseChartData = _getChartData(expenseTransactions, _selectedPeriod);
            final incomeChartData = _getChartData(incomeTransactions, _selectedPeriod);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodTabs(),
                  const SizedBox(height: 16),
                  _buildTypeSelector(),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryCard(
                        _selectedType == 0 ? 'Net Balance' : (_selectedType == 1 ? 'Total Expenses' : 'Total Income'),
                        displayAmount,
                        _selectedType,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.adaptiveDivider(context)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.file_download_outlined, size: 16, color: AppColors.adaptiveSecondaryText(context)),
                            const SizedBox(width: 4),
                            Text('PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.adaptiveSecondaryText(context))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildBarChart(expenseChartData, incomeChartData),
                  const SizedBox(height: 40),

                  if (_selectedType == 0 || _selectedType == 1) ...[
                    _buildCategoryGrid('Expenses Breakdown', filteredTransactions, model.TransactionType.expense),
                    const SizedBox(height: 32),
                  ],
                  if (_selectedType == 0 || _selectedType == 2) ...[
                    _buildCategoryGrid('Income Breakdown', filteredTransactions, model.TransactionType.income),
                  ],
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPeriodTabs() {
    final periods = ['Day', 'Week', 'Month', 'Year'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.adaptiveFieldBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.adaptiveCard(context) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    periods[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.adaptiveText(context) : AppColors.adaptiveSecondaryText(context),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      {'name': 'All', 'icon': Icons.account_balance_wallet_outlined},
      {
        'name': 'Expenses',
        'iconWidget': Transform.rotate(
          angle: 3.14159,
          child: SvgPicture.asset(
            'assets/svg/arrow-up-svgrepo-com.svg',
            width: 16,
            height: 16,
          ),
        ),
      },
      {
        'name': 'Income',
        'iconWidget': SvgPicture.asset(
          'assets/svg/arrow-up-svgrepo-com.svg',
          width: 16,
          height: 16,
        ),
      },
    ];

    Color getBaseColor(int index) {
      if (index == 1) return AppColors.error;
      if (index == 2) return AppColors.income;
      return AppColors.darkText;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(types.length, (index) {
          final isSelected = _selectedType == index;
          final baseColor = getBaseColor(index);
          final bgColor = isSelected ? baseColor : baseColor.withValues(alpha: 0.08);
          final textColor = isSelected ? Colors.white : baseColor;

          return Padding(
            padding: EdgeInsets.only(right: index < types.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? baseColor : Colors.transparent,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(color: baseColor.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4))
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    if (types[index].containsKey('iconWidget'))
                      Center(
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                          child: types[index]['iconWidget'] as Widget,
                        ),
                      )
                    else
                      Icon(
                        types[index]['icon'] as IconData,
                        size: 16,
                        color: textColor,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      types[index]['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBarChart(List<double> expenseData, List<double> incomeData) {
    if ((expenseData.isEmpty && incomeData.isEmpty) || 
        (expenseData.every((e) => e == 0) && incomeData.every((i) => i == 0))) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.adaptiveFieldBackground(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart_outlined, size: 48, color: AppColors.adaptiveSecondaryText(context).withValues(alpha: 0.2)),
              SizedBox(height: 12),
              Text('No data for this period', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.adaptiveSecondaryText(context))),
            ],
          ),
        ),
      );
    }

    final maxExpense = expenseData.isEmpty ? 0.0 : expenseData.reduce((a, b) => a > b ? a : b);
    final maxIncome = incomeData.isEmpty ? 0.0 : incomeData.reduce((a, b) => a > b ? a : b);
    double maxVal = maxExpense > maxIncome ? maxExpense : maxIncome;
    if (maxVal == 0) maxVal = 100;
    final maxY = maxVal * 1.2;

    double interval = maxY > 0 ? maxY / 4 : 25;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _getBottomLabel(value.toInt()),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.adaptiveSecondaryText(context)),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value >= 1000 ? '\$${(value / 1000).toStringAsFixed(1)}k' : '\$${value.toInt()}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.adaptiveSecondaryText(context)),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: AppColors.adaptiveDivider(context), strokeWidth: 1);
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: _getBarGroups(expenseData, incomeData),
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups(List<double> expenseData, List<double> incomeData) {
    return List.generate(expenseData.length, (index) {
      List<BarChartRodData> rods = [];
      
      if (_selectedType == 0 || _selectedType == 2) {
        rods.add(
          BarChartRodData(
            toY: incomeData[index] > 0 ? incomeData[index] : 0,
            color: AppColors.income,
            width: _selectedPeriod == 3 ? 10 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        );
      }
      
      if (_selectedType == 0 || _selectedType == 1) {
        rods.add(
          BarChartRodData(
            toY: expenseData[index] > 0 ? expenseData[index] : 0,
            color: AppColors.error,
            width: _selectedPeriod == 3 ? 10 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        );
      }

      return BarChartGroupData(
        x: index,
        barsSpace: 4,
        barRods: rods,
      );
    });
  }

  String _getBottomLabel(int index) {
    switch (_selectedPeriod) {
      case 0:
        if (index == 0) return '12am';
        if (index == 6) return '6am';
        if (index == 12) return '12pm';
        if (index == 18) return '6pm';
        return '';
      case 1:
        const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
        return index < days.length ? days[index] : '';
      case 2:
        return (index + 1) % 5 == 0 ? (index + 1).toString() : '';
      case 3:
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return index < months.length ? months[index] : '';
      default:
        return '';
    }
  }

  Widget _buildSummaryCard(String title, double amount, int typeIndex) {
    Color amountColor;
    String lottiePath;

    if (typeIndex == 0) {
      amountColor = amount >= 0 ? AppColors.income : AppColors.error;
      lottiePath = 'assets/lotties/piggybank.json';
    } else if (typeIndex == 1) {
      amountColor = AppColors.error;
      lottiePath = 'assets/lotties/Watch a movie with popcorn.json';
    } else {
      amountColor = AppColors.income;
      lottiePath = 'assets/lotties/Budget Tracker.json';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Lottie.asset(lottiePath, width: 24, height: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.adaptiveSecondaryText(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(amount.abs()),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: amountColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(String title, List<model.Transaction> transactions, model.TransactionType type) {
    final categories = _getCategoryTotalsList(transactions, type);

    if (categories.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.adaptiveText(context),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: categories.map((category) {
            final lottie = category['lottie'] as String;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.adaptiveFieldBackground(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.adaptiveCard(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: lottie.isNotEmpty
                          ? Lottie.asset(lottie, width: 24, height: 24)
                          : Icon(
                              category['icon'] as IconData,
                              size: 20,
                              color: type == model.TransactionType.expense ? AppColors.error : AppColors.income,
                            ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.adaptiveSecondaryText(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(category['amount'] as double),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.adaptiveText(context),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
