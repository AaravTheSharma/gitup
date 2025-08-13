import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cycle_model.dart';

class CycleRepository {
  final SharedPreferences _prefs;
  static const String _cycleKey = 'cycle_data';
  static const String _historyKey = 'cycle_history';

  // Common symptoms for tracking
  static const List<String> commonSymptoms = [
    'Headache',
    'Abdominal pain',
    'Back pain',
    'Breast tenderness',
    'Fatigue',
    'Acne',
    'Mood swings',
    'Increased appetite',
    'Insomnia',
    'Swelling',
    'Nausea',
    'Bloating',
    'Dizziness',
  ];

  // Mood options
  static const List<String> moodOptions = [
    'Happy',
    'Calm',
    'Tired',
    'Anxious',
    'Depressed',
    'Irritable',
    'Sensitive',
  ];

  // Flow intensity options
  static const List<String> flowOptions = [
    'Light',
    'Normal',
    'Heavy',
    'Very heavy',
  ];

  CycleRepository(this._prefs);

  // Get current cycle data
  Future<Cycle?> getCycle() async {
    final String? cycleJson = _prefs.getString(_cycleKey);
    if (cycleJson == null) {
      return null;
    }

    try {
      final Map<String, dynamic> cycleMap =
          jsonDecode(cycleJson) as Map<String, dynamic>;
      return Cycle.fromJson(cycleMap);
    } catch (e) {
      print('Error retrieving cycle data: $e');
      return null;
    }
  }

  // Save cycle data
  Future<bool> saveCycle(Cycle cycle) async {
    try {
      final String cycleJson = jsonEncode(cycle.toJson());
      return await _prefs.setString(_cycleKey, cycleJson);
    } catch (e) {
      print('Error saving cycle data: $e');
      return false;
    }
  }

  // Initialize cycle with user input
  Future<bool> initializeCycle({
    required DateTime lastPeriodDate,
    required int cycleDuration,
    required int periodDuration,
  }) async {
    // Calculate current day in cycle
    final today = DateTime.now();
    final daysSinceLastPeriod = today.difference(lastPeriodDate).inDays;
    final currentDay = (daysSinceLastPeriod % cycleDuration) + 1;

    // Calculate next period date
    final nextPeriodDate = lastPeriodDate.add(Duration(days: cycleDuration));

    // Calculate phase
    final phase = Cycle.calculatePhase(currentDay, cycleDuration);

    // Create cycle model
    final cycle = Cycle(
      currentDay: currentDay,
      phase: phase,
      nextPeriodDate: nextPeriodDate,
      lastPeriodDate: lastPeriodDate,
      cycleDuration: cycleDuration,
      periodDuration: periodDuration,
    );

    // Save to history
    await _addToHistory(cycle);

    return await saveCycle(cycle);
  }

  // Update cycle data daily
  Future<bool> updateCycleDay() async {
    final cycle = await getCycle();
    if (cycle == null) {
      return false;
    }

    // Calculate current day based on last period date
    final today = DateTime.now();
    final daysSinceLastPeriod = today.difference(cycle.lastPeriodDate).inDays;
    final currentDay = (daysSinceLastPeriod % cycle.cycleDuration) + 1;

    // Update phase if needed
    final phase = Cycle.calculatePhase(currentDay, cycle.cycleDuration);

    // If cycle completed, update last period date and next period date
    DateTime nextPeriodDate = cycle.nextPeriodDate;
    DateTime lastPeriodDate = cycle.lastPeriodDate;

    if (currentDay == 1) {
      lastPeriodDate = today;
      nextPeriodDate = today.add(Duration(days: cycle.cycleDuration));

      // Save to history when new cycle starts
      await _addToHistory(cycle);
    }

    // Create updated cycle
    final updatedCycle = cycle.copyWith(
      currentDay: currentDay,
      phase: phase,
      nextPeriodDate: nextPeriodDate,
      lastPeriodDate: lastPeriodDate,
    );

    return await saveCycle(updatedCycle);
  }

  // Add symptom for today
  Future<bool> addSymptom(String symptom) async {
    final cycle = await getCycle();
    if (cycle == null) {
      return false;
    }

    final updatedCycle = cycle.addSymptom(symptom);
    return await saveCycle(updatedCycle);
  }

  // Remove symptom for today
  Future<bool> removeSymptom(String symptom) async {
    final cycle = await getCycle();
    if (cycle == null) {
      return false;
    }

    final updatedCycle = cycle.removeSymptom(symptom);
    return await saveCycle(updatedCycle);
  }

  // Set mood for today
  Future<bool> setMood(String mood) async {
    final cycle = await getCycle();
    if (cycle == null) {
      return false;
    }

    final updatedCycle = cycle.setMood(mood);
    return await saveCycle(updatedCycle);
  }

  // Set flow intensity for today
  Future<bool> setFlow(String flow) async {
    final cycle = await getCycle();
    if (cycle == null) {
      return false;
    }

    final updatedCycle = cycle.setFlow(flow);
    return await saveCycle(updatedCycle);
  }

  // Add a note
  Future<bool> addNote(String note) async {
    final cycle = await getCycle();
    if (cycle == null) {
      return false;
    }

    final updatedCycle = cycle.addNote(note);
    return await saveCycle(updatedCycle);
  }

  // Get cycle history
  Future<List<Map<String, dynamic>>> getCycleHistory() async {
    final String? historyJson = _prefs.getString(_historyKey);
    if (historyJson == null) {
      return [];
    }

    try {
      final List<dynamic> historyList =
          jsonDecode(historyJson) as List<dynamic>;
      return List<Map<String, dynamic>>.from(historyList);
    } catch (e) {
      print('Error retrieving cycle history: $e');
      return [];
    }
  }

  // Add current cycle to history
  Future<bool> _addToHistory(Cycle cycle) async {
    try {
      final history = await getCycleHistory();

      // Add current cycle data to history
      final cycleData = {
        'startDate': cycle.lastPeriodDate.toIso8601String(),
        'endDate': cycle.lastPeriodDate
            .add(Duration(days: cycle.periodDuration))
            .toIso8601String(),
        'duration': cycle.cycleDuration,
        'periodDuration': cycle.periodDuration,
      };

      history.add(cycleData);

      // Keep only last 12 cycles
      final limitedHistory = history.length > 12
          ? history.sublist(history.length - 12)
          : history;

      final historyJson = jsonEncode(limitedHistory);
      return await _prefs.setString(_historyKey, historyJson);
    } catch (e) {
      print('Error saving cycle history: $e');
      return false;
    }
  }

  // Update cycle settings
  Future<bool> updateCycleSettings({
    required int cycleDuration,
    required int periodDuration,
  }) async {
    final cycle = await getCycle();
    if (cycle == null) {
      return false;
    }

    final updatedCycle = cycle.copyWith(
      cycleDuration: cycleDuration,
      periodDuration: periodDuration,
    );

    return await saveCycle(updatedCycle);
  }

  // Calculate if we should show reminder (7 days before next period)
  bool shouldShowReminder(Cycle cycle) {
    final daysUntilNextPeriod = cycle.daysUntilNextPeriod();
    return daysUntilNextPeriod <= 7 && daysUntilNextPeriod > 0;
  }

  // Get reminder text based on cycle phase
  String getReminderText(Cycle cycle) {
    final daysUntilNextPeriod = cycle.daysUntilNextPeriod();

    if (cycle.phase == 'Menstrual') {
      return 'You are in the menstrual phase, please rest and maintain a good mood. Avoid intense exercise and cold foods.';
    } else if (daysUntilNextPeriod <= 7) {
      return 'Your period is expected to start in $daysUntilNextPeriod days, it is recommended to pay attention to diet, avoid cold food, and maintain a good mood.';
    } else if (cycle.phase == 'Ovulation') {
      return 'You are in the ovulation phase, which has the highest chance of conception. If you are trying to conceive, this is the best time.';
    } else if (cycle.phase == 'Luteal') {
      return 'You are in the luteal phase and may experience mild mood swings or physical discomfort. Please maintain a positive mindset.';
    }

    return '';
  }

  // Get health tips based on cycle phase
  String getHealthTips(Cycle cycle) {
    switch (cycle.phase) {
      case 'Menstrual':
        return '• Drink warm water, avoid cold drinks\n• Get enough sleep\n• Avoid strenuous exercise\n• Eat light meals, consume iron-rich foods';
      case 'Ovulation':
        return '• Maintain a regular schedule\n• Eat balanced meals with protein\n• Exercise moderately\n• Avoid overexertion';
      case 'Luteal':
        return '• Limit sugar intake\n• Do light exercise\n• Eat foods rich in vitamin B6\n• Avoid caffeine';
      case 'Safe':
        return '• Maintain regular routine\n• Eat balanced diet\n• Exercise moderately\n• Keep positive mindset';
      default:
        return '• Balanced diet\n• Regular routine\n• Moderate exercise\n• Positive mindset';
    }
  }

  // Calculate average cycle length from history
  Future<int> getAverageCycleLength() async {
    final history = await getCycleHistory();
    if (history.isEmpty) {
      return 28; // Default value
    }

    int totalDays = 0;
    for (var cycle in history) {
      totalDays += cycle['duration'] as int;
    }

    return totalDays ~/ history.length;
  }

  // Calculate average period duration from history
  Future<int> getAveragePeriodDuration() async {
    final history = await getCycleHistory();
    if (history.isEmpty) {
      return 5; // Default value
    }

    int totalDays = 0;
    for (var cycle in history) {
      totalDays += cycle['periodDuration'] as int;
    }

    return totalDays ~/ history.length;
  }
}
