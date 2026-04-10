import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart' as model;
import '../models/category.dart';
import '../models/goal.dart';
import '../core/constants/app_colors.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance_companion.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create goals table
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL,
        deadline TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_completed INTEGER NOT NULL
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_code INTEGER NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // Seed default categories
    await _seedCategories(db);
  }

  Future<void> _seedCategories(Database db) async {
    final expenseCategories = [
      Category(
        id: 'food_dining',
        name: 'Food & Dining',
        icon: Icons.restaurant,
        color: AppColors.foodDining,
        type: model.TransactionType.expense,
      ),
      Category(
        id: 'shopping',
        name: 'Shopping',
        icon: Icons.shopping_bag,
        color: AppColors.shopping,
        type: model.TransactionType.expense,
      ),
      Category(
        id: 'transportation',
        name: 'Transportation',
        icon: Icons.directions_car,
        color: AppColors.transportation,
        type: model.TransactionType.expense,
      ),
      Category(
        id: 'entertainment',
        name: 'Entertainment',
        icon: Icons.movie,
        color: AppColors.entertainment,
        type: model.TransactionType.expense,
      ),
      Category(
        id: 'bills',
        name: 'Bills & Utilities',
        icon: Icons.receipt,
        color: AppColors.bills,
        type: model.TransactionType.expense,
      ),
      Category(
        id: 'healthcare',
        name: 'Healthcare',
        icon: Icons.local_hospital,
        color: AppColors.healthcare,
        type: model.TransactionType.expense,
      ),
      Category(
        id: 'education',
        name: 'Education',
        icon: Icons.school,
        color: AppColors.education,
        type: model.TransactionType.expense,
      ),
      Category(
        id: 'other_expense',
        name: 'Other',
        icon: Icons.category,
        color: AppColors.other,
        type: model.TransactionType.expense,
      ),
    ];

    final incomeCategories = [
      Category(
        id: 'salary',
        name: 'Salary',
        icon: Icons.attach_money,
        color: AppColors.salary,
        type: model.TransactionType.income,
      ),
      Category(
        id: 'freelance',
        name: 'Freelance',
        icon: Icons.work,
        color: AppColors.freelance,
        type: model.TransactionType.income,
      ),
      Category(
        id: 'investment',
        name: 'Investment',
        icon: Icons.trending_up,
        color: AppColors.investment,
        type: model.TransactionType.income,
      ),
      Category(
        id: 'gift',
        name: 'Gift',
        icon: Icons.card_giftcard,
        color: AppColors.gift,
        type: model.TransactionType.income,
      ),
      Category(
        id: 'other_income',
        name: 'Other',
        icon: Icons.money,
        color: AppColors.otherIncome,
        type: model.TransactionType.income,
      ),
    ];

    final allCategories = [...expenseCategories, ...incomeCategories];

    for (final category in allCategories) {
      await db.insert('categories', category.toMap());
    }
  }

  // Transaction CRUD operations
  Future<void> insertTransaction(model.Transaction transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toMap());
  }

  Future<List<model.Transaction>> getTransactions() async {
    final db = await database;
    final result = await db.query(
      'transactions',
      orderBy: 'date DESC, created_at DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC, created_at DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<void> updateTransaction(model.Transaction transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Goal CRUD operations
  Future<void> insertGoal(Goal goal) async {
    final db = await database;
    await db.insert('goals', goal.toMap());
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final result = await db.query(
      'goals',
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Goal.fromMap(map)).toList();
  }

  Future<Goal?> getActiveGoal() async {
    final db = await database;
    final result = await db.query(
      'goals',
      where: 'is_completed = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Goal.fromMap(result.first);
  }

  Future<void> updateGoal(Goal goal) async {
    final db = await database;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(String id) async {
    final db = await database;
    await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category operations
  Future<List<Category>> getCategories({model.TransactionType? type}) async {
    final db = await database;
    final result = type != null
        ? await db.query(
            'categories',
            where: 'type = ?',
            whereArgs: [type == model.TransactionType.income ? 'income' : 'expense'],
          )
        : await db.query('categories');

    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
