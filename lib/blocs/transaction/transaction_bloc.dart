import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/database_service.dart';
import '../../models/transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final DatabaseService _databaseService;

  TransactionBloc({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance,
        super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<FilterTransactions>(_onFilterTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    try {
      final transactions = await _databaseService.getTransactions();
      final stats = _calculateStats(transactions);
      emit(TransactionLoaded(
        transactions: transactions,
        totalIncome: stats['income']!,
        totalExpense: stats['expense']!,
        balance: stats['balance']!,
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _databaseService.insertTransaction(event.transaction);
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _databaseService.updateTransaction(event.transaction);
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _databaseService.deleteTransaction(event.id);
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onFilterTransactions(
    FilterTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    try {
      List<Transaction> transactions;

      if (event.startDate != null && event.endDate != null) {
        transactions = await _databaseService.getTransactionsByDateRange(
          event.startDate!,
          event.endDate!,
        );
      } else {
        transactions = await _databaseService.getTransactions();
      }

      // Apply additional filters
      if (event.type != null) {
        transactions = transactions.where((t) => t.type == event.type).toList();
      }

      if (event.category != null) {
        transactions = transactions.where((t) => t.category == event.category).toList();
      }

      final stats = _calculateStats(transactions);
      emit(TransactionLoaded(
        transactions: transactions,
        totalIncome: stats['income']!,
        totalExpense: stats['expense']!,
        balance: stats['balance']!,
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Map<String, double> _calculateStats(List<Transaction> transactions) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }
}
