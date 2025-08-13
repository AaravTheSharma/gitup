import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final SharedPreferences _prefs;
  static const String _expensesKey = 'fashion_expenses';

  ExpenseRepository(this._prefs);

  // Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    final String? expensesJson = _prefs.getString(_expensesKey);
    if (expensesJson == null) {
      return [];
    }

    try {
      final List<dynamic> expensesList =
          jsonDecode(expensesJson) as List<dynamic>;
      return expensesList
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error retrieving expense data: $e');
      return [];
    }
  }

  // Save all expenses
  Future<bool> saveExpenses(List<Expense> expenses) async {
    try {
      final String expensesJson = jsonEncode(
        expenses.map((e) => e.toJson()).toList(),
      );
      return await _prefs.setString(_expensesKey, expensesJson);
    } catch (e) {
      print('Error saving expense data: $e');
      return false;
    }
  }

  // Add a new expense
  Future<bool> addExpense(Expense expense) async {
    final expenses = await getAllExpenses();
    expenses.add(expense);
    return await saveExpenses(expenses);
  }

  // Get expenses for a specific month
  Future<List<Expense>> getMonthExpenses(DateTime month) async {
    final allExpenses = await getAllExpenses();
    return allExpenses
        .where(
          (expense) =>
              expense.date.year == month.year &&
              expense.date.month == month.month,
        )
        .toList();
  }

  // Get expense totals by category for a month
  Future<Map<String, double>> getCategoryTotals(DateTime month) async {
    final expenses = await getMonthExpenses(month);
    return Expense.calculateMonthlyTotals(expenses, month);
  }

  // Get total expense for a month
  Future<double> getMonthTotal(DateTime month) async {
    final expenses = await getMonthExpenses(month);
    return Expense.calculateMonthTotal(expenses, month);
  }

  // Get monthly change percentage compared to previous month
  Future<double> getMonthlyChangePercentage(DateTime month) async {
    final expenses = await getAllExpenses();
    return Expense.calculateMonthlyChange(expenses, month);
  }

  // Get all expenses by category
  Future<Map<String, List<Expense>>> getExpensesByCategory() async {
    final expenses = await getAllExpenses();
    final Map<String, List<Expense>> categorized = {
      'Clothing': [],
      'Shoes': [],
      'Accessories': [],
      'Bags': [],
    };

    for (var expense in expenses) {
      // Convert old Chinese categories to English if needed
      String category = expense.category;
      if (category == '服装') category = 'Clothing';
      if (category == '鞋子') category = 'Shoes';
      if (category == '首饰') category = 'Accessories';
      if (category == '包') category = 'Bags';

      categorized[category]?.add(expense);
    }

    return categorized;
  }

  // Delete an expense
  Future<bool> deleteExpense(Expense expenseToDelete) async {
    final expenses = await getAllExpenses();

    // Find the expense to delete by matching all properties
    final filteredExpenses = expenses
        .where(
          (expense) =>
              expense.amount == expenseToDelete.amount &&
              expense.category == expenseToDelete.category &&
              expense.date.year == expenseToDelete.date.year &&
              expense.date.month == expenseToDelete.date.month &&
              expense.date.day == expenseToDelete.date.day &&
              expense.description == expenseToDelete.description,
        )
        .toList();

    if (filteredExpenses.isEmpty) {
      return false; // Expense not found
    }

    // Remove the first matching expense
    expenses.remove(filteredExpenses.first);

    // Save updated expenses list
    return await saveExpenses(expenses);
  }

  // Edit an existing expense
  Future<bool> editExpense(Expense oldExpense, Expense newExpense) async {
    final expenses = await getAllExpenses();

    // Find the expense to edit by matching all properties
    final filteredExpenses = expenses
        .where(
          (expense) =>
              expense.amount == oldExpense.amount &&
              expense.category == oldExpense.category &&
              expense.date.year == oldExpense.date.year &&
              expense.date.month == oldExpense.date.month &&
              expense.date.day == oldExpense.date.day &&
              expense.description == oldExpense.description,
        )
        .toList();

    if (filteredExpenses.isEmpty) {
      return false; // Expense not found
    }

    // Find the index of the expense to edit
    final index = expenses.indexOf(filteredExpenses.first);

    // Replace the old expense with the new one
    expenses[index] = newExpense;

    // Save updated expenses list
    return await saveExpenses(expenses);
  }
}
