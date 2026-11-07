import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import '../utils/format.dart';
import '../widgets/category_summary.dart';
import '../widgets/expense_tile.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  List<Expense> _expenses = [];
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _storage.load();
    setState(() {
      _expenses = data;
      _loading = false;
    });
  }

  // ----- calculations -----
  List<Expense> get _monthExpenses => _expenses
      .where((e) => e.date.year == _month.year && e.date.month == _month.month)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  double get _monthTotal =>
      _monthExpenses.fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> get _categoryTotals {
    final map = <String, double>{};
    for (final e in _monthExpenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  // ----- actions -----
  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  Future<void> _addExpense() async {
    final expense = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    if (expense == null) return;
    setState(() {
      _expenses.add(expense);
      _month = DateTime(expense.date.year, expense.date.month);
    });
    await _storage.save(_expenses);
  }

  Future<void> _deleteExpense(Expense expense) async {
    setState(() => _expenses.removeWhere((e) => e.id == expense.id));
    await _storage.save(_expenses);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: const Text('Expense deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () async {
            setState(() => _expenses.add(expense));
            await _storage.save(_expenses);
          },
        ),
      ));
  }

  // ----- UI -----
  @override
  Widget build(BuildContext context) {
    final list = _monthExpenses;
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _monthSelector(),
                _totalCard(),
                const SizedBox(height: 8),
                Expanded(
                  child: list.isEmpty
                      ? const Center(child: Text('No expenses this month'))
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 90),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: CategorySummary(
                                totals: _categoryTotals,
                                monthTotal: _monthTotal,
                              ),
                            ),
                            const Divider(height: 24),
                            ...list.map((e) => ExpenseTile(
                                  expense: e,
                                  onDelete: () => _deleteExpense(e),
                                )),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _monthSelector() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_month),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      );

  Widget _totalCard() => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total spent', style: TextStyle(fontSize: 16)),
              Text(
                formatMoney(_monthTotal),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
}