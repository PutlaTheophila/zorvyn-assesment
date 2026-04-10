import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../models/transaction.dart' as model;
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helper.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _selectedType = 0; // 0: All, 1: Expenses, 2: Income

  Widget _buildTypeSelector() {
    final types = ['All', 'Expenses', 'Income'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(types.length, (index) {
          final isSelected = _selectedType == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.adaptiveText(context) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.adaptiveText(context) : AppColors.adaptiveDivider(context),
                  ),
                ),
                child: Text(
                  types[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.adaptiveBackground(context) : AppColors.adaptiveSecondaryText(context),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
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
          'Transactions',
          style: TextStyle(
            color: AppColors.adaptiveText(context),
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              );
            },
            icon: Icon(Icons.add_rounded, color: AppColors.adaptiveText(context)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildTypeSelector(),
          ),
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TransactionError) {
                  return Center(
                    child: Text('Error: ${state.message}'),
                  );
                }

                if (state is TransactionLoaded) {
                  var filteredList = state.transactions;
                  if (_selectedType == 1) {
                    filteredList = filteredList.where((t) => t.type == model.TransactionType.expense).toList();
                  } else if (_selectedType == 2) {
                    filteredList = filteredList.where((t) => t.type == model.TransactionType.income).toList();
                  }

                  if (filteredList.isEmpty) {
                    return EmptyState(
                      icon: Icons.receipt_long,
                      title: 'No transactions yet',
                      description: 'Start tracking your expenses to see them here',
                      lottiePath: 'assets/lotties/Budget Tracker.json',
                      svgPath: 'assets/svg/bill-check-svgrepo-com.svg',
                      actionText: 'Add Transaction',
                      onActionPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTransactionScreen(),
                          ),
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredList[index];
                      return Dismissible(
                        key: Key(transaction.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Transaction'),
                                content: const Text(
                                  'Are you sure you want to delete this transaction?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          context
                              .read<TransactionBloc>()
                              .add(DeleteTransaction(transaction.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transaction deleted'),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 0,
                          color: AppColors.adaptiveCard(context),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (transaction.type == model.TransactionType.income
                                    ? AppColors.income
                                    : AppColors.error).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _buildCategoryIcon(transaction),
                            ),
                            title: Text(
                              transaction.category,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.adaptiveText(context),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  DateHelper.formatDate(transaction.date),
                                  style: TextStyle(color: AppColors.adaptiveSecondaryText(context), fontSize: 13),
                                ),
                                if (transaction.description != null &&
                                    transaction.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      transaction.description!,
                                      style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              CurrencyFormatter.format(transaction.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: -0.5,
                                color: transaction.type == model.TransactionType.income
                                    ? AppColors.income
                                    : AppColors.adaptiveText(context),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddTransactionScreen(
                                    transaction: transaction,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(model.Transaction transaction) {
    String? lottiePath;
    final category = transaction.category.toLowerCase();
    
    if (category.contains('food') || category.contains('dining')) {
      lottiePath = 'assets/lotties/Food Carousel.json';
    } else if (category.contains('shopping')) {
      lottiePath = 'assets/lotties/shopping cart.json';
    } else if (category.contains('transport') || category.contains('travel')) {
      lottiePath = 'assets/lotties/Red Car Drive.json';
    } else if (category.contains('entertainment') || category.contains('movie')) {
      lottiePath = 'assets/lotties/Watch a movie with popcorn.json';
    } else if (category.contains('grocery')) {
      lottiePath = 'assets/lotties/Grocery Lottie JSON animation.json';
    }

    if (lottiePath != null) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Lottie.asset(lottiePath, fit: BoxFit.contain),
      );
    }

    return Icon(
      transaction.type == model.TransactionType.income
          ? Icons.arrow_downward
          : Icons.arrow_upward,
      color: transaction.type == model.TransactionType.income
          ? AppColors.income
          : AppColors.error,
      size: 22,
    );
  }
}
