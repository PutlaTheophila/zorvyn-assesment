import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helper.dart';
import '../../models/transaction.dart' as model;
import 'widgets/balance_card.dart';
import 'widgets/quick_stats.dart';
import 'widgets/spending_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Persistent Header - User Greeting & Professional Avatar
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final userName = authState is AuthAuthenticated
                      ? authState.user.name
                      : 'Guest';
                  final userInitial = userName.isNotEmpty
                      ? userName[0].toUpperCase()
                      : '?';

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning,',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.adaptiveSecondaryText(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.adaptiveText(context),
                              letterSpacing: -0.6,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            userInitial,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 24),

              // Transaction-based content
              BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is TransactionError) {
                    return Center(
                      child: Text('Error: ${state.message}'),
                    );
                  }

                  if (state is TransactionLoaded) {
                    final balance = state.balance;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        BalanceCard(balance: balance),
                        const SizedBox(height: 24),
                        QuickStats(
                          income: state.totalIncome,
                          expenses: state.totalExpense,
                          savings: balance,
                        ),
                        const SizedBox(height: 24),
                        
                        if (state.transactions.isEmpty) ...[
                          const SizedBox(height: 40),
                          Center(
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/finance-svgrepo-com.svg',
                                  width: 80,
                                  height: 80,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.adaptiveSecondaryText(context).withValues(alpha: 0.2),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.adaptiveText(context),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add your first transaction to see your spending breakdown.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.adaptiveSecondaryText(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Spending Breakdown',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.adaptiveText(context),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 0,
                            color: AppColors.adaptiveCard(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: AppColors.adaptiveDivider(context).withValues(alpha: 0.1)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SpendingChart(
                                transactions: state.transactions,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent transactions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.adaptiveText(context),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigated via tab index in main.dart
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.income,
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'View all',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...state.transactions.take(4).map((transaction) {
                            final isIncome = transaction.type == model.TransactionType.income;
                            
                            // Category Icon mapping
                            IconData categoryIcon;
                            Color iconBg;
                            switch (transaction.category.toLowerCase()) {
                              case 'food & dining':
                              case 'restaurant':
                                categoryIcon = Icons.local_cafe;
                                iconBg = const Color(0xFF00704A);
                                break;
                              case 'entertainment':
                                categoryIcon = Icons.play_circle_filled;
                                iconBg = const Color(0xFFE50914);
                                break;
                              case 'shopping':
                                categoryIcon = Icons.shopping_bag;
                                iconBg = const Color(0xFFE4002B);
                                break;
                              default:
                                categoryIcon = Icons.store;
                                iconBg = AppColors.primary;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.adaptiveCard(context),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.adaptiveDivider(context).withValues(alpha: 0.05)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: iconBg.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      categoryIcon,
                                      color: iconBg,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          transaction.category,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.adaptiveText(context),
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          DateHelper.getRelativeDate(transaction.date),
                                          style: TextStyle(
                                            color: AppColors.adaptiveSecondaryText(context),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isIncome ? AppColors.income : AppColors.error,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
