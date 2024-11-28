import 'package:flutter/material.dart';
import 'dbhelper.dart';

void main() {
  runApp(FoodOrderingApp());
}

class FoodOrderingApp extends StatelessWidget {
  const FoodOrderingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbHelper = DatabaseHelper();
  double targetCost = 0.0;
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> foodItems = [];
  List<int> selectedFoodIds = [];

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  Future<void> _fetchFoodItems() async {
    final items = await dbHelper.getFoodItems();
    setState(() {
      foodItems = items;
    });
  }

  Future<void> _saveOrderPlan() async {
    if (selectedFoodIds.isEmpty) return;

    final selectedItems = foodItems
        .where((item) => selectedFoodIds.contains(item['id']))
        .map((item) => item['name'])
        .join(', ');

    await dbHelper.addOrderPlan(
      selectedDate.toIso8601String().split('T').first,
      targetCost,
      selectedItems,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order plan saved successfully!')),
    );
  }

  Future<void> _viewOrderPlan(String date) async {
    final plans = await dbHelper.getOrderPlan(date);
    if (plans.isNotEmpty) {
      final plan = plans.first;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Order Plan for $date'),
          content: Text('Target Cost: ${plan['target_cost']}\nSelected Items: ${plan['selected_items']}'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No order plan found for $date')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Ordering App')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Target Cost Per Day'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => targetCost = double.tryParse(value) ?? 0.0,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  ).then((date) {
                    if (date != null) setState(() => selectedDate = date);
                  }),
                  child: const Text('Select Date'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                return CheckboxListTile(
                  title: Text('${item['name']} - \$${item['cost']}'),
                  value: selectedFoodIds.contains(item['id']),
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        selectedFoodIds.add(item['id']);
                      } else {
                        selectedFoodIds.remove(item['id']);
                      }
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _saveOrderPlan,
            child: const Text('Save Order Plan'),
          ),
          ElevatedButton(
            onPressed: () => _viewOrderPlan(selectedDate.toIso8601String().split('T').first),
            child: const Text('View Order Plan'),
          ),
        ],
      ),
    );
  }
}
