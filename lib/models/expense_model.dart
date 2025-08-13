class Expense {
  final String category; // 服装/鞋子/首饰/包
  final double amount;
  final DateTime date;
  final String description;

  Expense({
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
  });

  // Factory constructor to create from SharedPreferences data
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      category: json['category'] as String,
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
    ); //dsfsdfsdfsdf
  }

  // Convert to JSON for SharedPreferences storage
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  // Calculate monthly totals by category
  static Map<String, double> calculateMonthlyTotals(
    List<Expense> expenses,
    DateTime month,
  ) {
    final Map<String, double> totals = {
      '服装': 0.0,
      '鞋子': 0.0,
      '首饰': 0.0,
      '包': 0.0,
    };

    final filteredExpenses = expenses.where(
      (expense) =>
          expense.date.year == month.year && expense.date.month == month.month,
    );

    for (var expense in filteredExpenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    return totals;
  }

  // Calculate total spending for a specific month
  static double calculateMonthTotal(List<Expense> expenses, DateTime month) {
    final filteredExpenses = expenses.where(
      (expense) =>
          expense.date.year == month.year && expense.date.month == month.month,
    );

    return filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Calculate percentage change compared to previous month
  static double calculateMonthlyChange(List<Expense> expenses, DateTime month) {
    // Current month total
    final currentTotal = calculateMonthTotal(expenses, month);

    // Previous month
    final previousMonth = DateTime(month.year, month.month - 1);
    final previousTotal = calculateMonthTotal(expenses, previousMonth);

    if (previousTotal == 0) return 0;

    return ((currentTotal - previousTotal) / previousTotal) * 100;
  }
}
