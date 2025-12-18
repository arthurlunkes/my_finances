import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as app_models;
import '../models/credit_card.dart';
import '../models/category.dart' as app_category;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('my_finances.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabela de Transações
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        category TEXT NOT NULL,
        isRecurrent INTEGER NOT NULL,
        notes TEXT,
        creditCardId TEXT,
        installments INTEGER,
        currentInstallment INTEGER,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    // Tabela de Cartões de Crédito
    await db.execute('''
      CREATE TABLE credit_cards (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        lastDigits TEXT NOT NULL,
        cardLimit REAL NOT NULL,
        closingDay INTEGER NOT NULL,
        dueDay INTEGER NOT NULL,
        brand TEXT NOT NULL,
        color TEXT,
        isActive INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    // Tabela de Categorias
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        isIncome INTEGER NOT NULL,
        isDefault INTEGER NOT NULL
      )
    ''');

    // Inserir categorias padrão
    for (var category in app_category.DefaultCategories.all) {
      await db.insert('categories', category.toJson());
    }
  }

  // ========== TRANSAÇÕES ==========

  Future<String> insertTransaction(app_models.Transaction transaction) async {
    final db = await database;
    try {
      await db.insert('transactions', transaction.toJson());
      return transaction.id;
    } catch (e, st) {
      debugPrint('DB insertTransaction error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<List<app_models.Transaction>> getAllTransactions() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => app_models.Transaction.fromJson(json)).toList();
  }

  Future<List<app_models.Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => app_models.Transaction.fromJson(json)).toList();
  }

  Future<List<app_models.Transaction>> getTransactionsByType(
    app_models.TransactionType type,
  ) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'date DESC',
    );
    return result.map((json) => app_models.Transaction.fromJson(json)).toList();
  }

  Future<List<app_models.Transaction>> getTransactionsByStatus(
    app_models.TransactionStatus status,
  ) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'date ASC',
    );
    return result.map((json) => app_models.Transaction.fromJson(json)).toList();
  }

  Future<int> updateTransaction(app_models.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ========== CARTÕES DE CRÉDITO ==========

  Future<String> insertCreditCard(CreditCard card) async {
    final db = await database;
    await db.insert('credit_cards', card.toJson());
    return card.id;
  }

  Future<List<CreditCard>> getAllCreditCards() async {
    final db = await database;
    final result = await db.query(
      'credit_cards',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return result.map((json) => CreditCard.fromJson(json)).toList();
  }

  Future<CreditCard?> getCreditCard(String id) async {
    final db = await database;
    final result = await db.query(
      'credit_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return CreditCard.fromJson(result.first);
  }

  Future<int> updateCreditCard(CreditCard card) async {
    final db = await database;
    return await db.update(
      'credit_cards',
      card.toJson(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCreditCard(String id) async {
    final db = await database;
    return await db.delete('credit_cards', where: 'id = ?', whereArgs: [id]);
  }

  // ========== CATEGORIAS ==========

  Future<List<app_category.Category>> getAllCategories() async {
    final db = await database;
    final result = await db.query('categories');
    return result.map((json) => app_category.Category.fromJson(json)).toList();
  }

  Future<List<app_category.Category>> getCategoriesByType(bool isIncome) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'isIncome = ?',
      whereArgs: [isIncome ? 1 : 0],
    );
    return result.map((json) => app_category.Category.fromJson(json)).toList();
  }

  Future<String> insertCategory(app_category.Category category) async {
    final db = await database;
    await db.insert('categories', category.toJson());
    return category.id;
  }

  // ========== FECHAR ==========

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
