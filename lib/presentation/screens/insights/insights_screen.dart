import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/models/decision_model.dart';
import '../../../core/app_constants.dart';
import '../../widgets/custom_card.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  Map<String, int> _criteriaStats = {};
  Map<String, int> _categoryStats = {};
  List<Decision> _decisions = [];
  bool _isLoading = true;
  StorageService? _storageService;
  int _totalDecisions = 0;
  int _completedDecisions = 0;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageService.getInstance();
    await _loadStats();
  }

  Future<void> _loadStats() async {
    if (_storageService == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final decisions = await _storageService!.loadDecisions();
      final criteriaStats = await _storageService!.getCriteriaUsageStats();
      final categoryStats = await _storageService!.getCategoryStats();
      final totalDecisions = await _storageService!.getTotalDecisionsCount();
      final completedDecisions = await _storageService!.getCompletedDecisionsCount();
      
      if (!mounted) return;
      
      setState(() {
        _decisions = decisions;
        _criteriaStats = criteriaStats;
        _categoryStats = categoryStats;
        _totalDecisions = totalDecisions;
        _completedDecisions = completedDecisions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading insights: $e')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Insights',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Analyze your decision-making patterns.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppConstants.paddingXLarge),

              // Summary Statistics
              if (!_isLoading && _totalDecisions > 0) ...[
                Row(
                  children: [
                    Expanded(
                      child: CustomCard(
                        child: Column(
                          children: [
                            Text(
                              '$_totalDecisions',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total Decisions',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: CustomCard(
                        child: Column(
                          children: [
                            Text(
                              '$_completedDecisions',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: const Color(AppConstants.secondaryColor),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Completed',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: CustomCard(
                        child: Column(
                          children: [
                            Text(
                              '${_totalDecisions > 0 ? ((_completedDecisions / _totalDecisions) * 100).round() : 0}%',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: const Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Completion Rate',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingLarge),
              ],

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingXLarge),
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (!_isLoading && _criteriaStats.isEmpty && _categoryStats.isEmpty)
                CustomCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.insights_outlined,
                        size: 64,
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        'No insights yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Complete some decisions to see your decision-making patterns and insights.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),



              if (!_isLoading && _criteriaStats.isNotEmpty) ...[
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Most Used Criteria',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'The evaluation criteria you use most often in your decisions.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (_criteriaStats.length > 8) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Showing top 8 most used criteria',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppConstants.paddingXLarge),
                      SizedBox(
                        height: 320,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _criteriaStats.values.isNotEmpty 
                                ? _criteriaStats.values.reduce((a, b) => a > b ? a : b).toDouble() + 1
                                : 10,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final entries = _criteriaStats.entries.toList()
                                    ..sort((a, b) => b.value.compareTo(a.value));
                                  final limitedEntries = entries.take(8).toList();
                                  if (groupIndex < limitedEntries.length) {
                                    return BarTooltipItem(
                                      '${limitedEntries[groupIndex].key}\n${limitedEntries[groupIndex].value} uses',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 60,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    final entries = _criteriaStats.entries.toList()
                                      ..sort((a, b) => b.value.compareTo(a.value));
                                    final limitedEntries = entries.take(8).toList();
                                    
                                    if (index >= 0 && index < limitedEntries.length) {
                                      String label = limitedEntries[index].key;
                                      // Truncate long labels and add ellipsis
                                      if (label.length > 10) {
                                        label = '${label.substring(0, 10)}...';
                                      }
                                      
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Transform.rotate(
                                          angle: -0.3, // Slight rotation for better readability
                                          child: Text(
                                            label,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontSize: 11,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: _buildBarGroups(),
                            gridData: const FlGridData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (!_isLoading && _categoryStats.isNotEmpty) ...[
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Decision Categories',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Distribution of your decisions by category.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      SizedBox(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sections: _buildPieChartSections(),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 60,
                            pieTouchData: PieTouchData(enabled: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Wrap(
                        spacing: AppConstants.paddingMedium,
                        runSpacing: AppConstants.paddingSmall,
                        children: _categoryStats.entries.map((entry) {
                          final color = _getCategoryColor(entry.key);
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${entry.key} (${entry.value})',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final sortedEntries = _criteriaStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Limit to top 8 criteria to avoid overcrowding
    final limitedEntries = sortedEntries.take(8).toList();

    return limitedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final criteriaEntry = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: criteriaEntry.value.toDouble(),
            color: Theme.of(context).primaryColor,
            width: MediaQuery.of(context).size.width / (limitedEntries.length * 2.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = _categoryStats.values.fold(0, (sum, value) => sum + value);
    
    return _categoryStats.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = _getCategoryColor(entry.key);
      
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${percentage.round()}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Career Decision': const Color(0xFF3B82F6),
      'Housing Decision': const Color(0xFF10B981),
      'Relationship Decision': const Color(0xFFA855F7),
      'Financial Decision': const Color(0xFFF59E0B),
      'Custom': const Color(0xFFEF4444),
    };
    
    return colors[category] ?? const Color(0xFF64748B);
  }
}