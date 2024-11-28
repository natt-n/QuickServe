import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'food_ordering.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        target_cost REAL NOT NULL,
        selected_items TEXT NOT NULL
      )
    ''');

    // Insert 20 food items
    await db.insert('food_items', {'name': 'Pizza', 'cost': 10.0});
    await db.insert('food_items', {'name': 'Burger', 'cost': 8.0});
    await db.insert('food_items', {'name': 'Pasta', 'cost': 12.0});
    await db.insert('food_items', {'name': 'Sushi', 'cost': 18.0});
    await db.insert('food_items', {'name': 'Salad', 'cost': 8.0});
    await db.insert('food_items', {'name': 'Tacos', 'cost': 9.0});
    await db.insert('food_items', {'name': 'Steak', 'cost': 25.0});
    await db.insert('food_items', {'name': 'Chicken Wings', 'cost': 12.0});
    await db.insert('food_items', {'name': 'Fish & Chips', 'cost': 14.0});
    await db.insert('food_items', {'name': 'Spaghetti', 'cost': 13.0});
    await db.insert('food_items', {'name': 'Lasagna', 'cost': 16.0});
    await db.insert('food_items', {'name': 'Soup', 'cost': 7.0});
    await db.insert('food_items', {'name': 'Grilled Cheese', 'cost': 6.0});
    await db.insert('food_items', {'name': 'Fried Rice', 'cost': 11.0});
    await db.insert('food_items', {'name': 'Sandwich', 'cost': 5.0});
    await db.insert('food_items', {'name': 'Ramen', 'cost': 13.0});
    await db.insert('food_items', {'name': 'Curry', 'cost': 14.0});
    await db.insert('food_items', {'name': 'Quesadilla', 'cost': 10.0});
    await db.insert('food_items', {'name': 'Dim Sum', 'cost': 15.0});
    await db.insert('food_items', {'name': 'Burrito', 'cost': 11.0});
  }

  Future<List<Map<String, dynamic>>> getFoodItems() async {
    final db = await database;
    return await db.query('food_items');
  }

  Future<void> addOrderPlan(
      String date, double targetCost, String selectedItems) async {
    final db = await database;
    await db.insert('order_plans', {
      'date': date,
      'target_cost': targetCost,
      'selected_items': selectedItems,
    });
  }

  Future<List<Map<String, dynamic>>> getOrderPlan(String date) async {
    final db = await database;
    return await db.query('order_plans', where: 'date = ?', whereArgs: [date]);
  }

  Future<void> updateFoodItem(int id, String name, double cost) async {
    final db = await database;
    await db.update('food_items', {'name': name, 'cost': cost},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteFoodItem(int id) async {
    final db = await database;
    await db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }
}
