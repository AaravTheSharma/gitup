import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../../data/models/decision_model.dart';
import '../../../logic/decision_service.dart';
import '../../../utils/helpers.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/radar_chart_widget.dart';

class ReportScreen extends StatefulWidget {
  final Decision decision;

  const ReportScreen({super.key, required this.decision});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late DecisionService _decisionService;
  late Map<String, double> _scores;
  String _analysis = '';
  bool _isLoadingAI = true;

  @override
  void initState() {
    super.initState();
    _decisionService = DecisionService.getInstance();
    _scores = _decisionService.calculateScores(widget.decision);
    _loadAIAnalysis();
  }

  Future<void> _loadAIAnalysis() async {
    if (!mounted) return;

    setState(() {
      _isLoadingAI = true;
    });

    try {
      final aiAnalysis = await _decisionService.generateAIAnalysisReport(
        widget.decision,
      );
      if (!mounted) return;

      setState(() {
        _analysis = aiAnalysis;
        _isLoadingAI = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _analysis = _decisionService.generateAnalysisReport(widget.decision);
        _isLoadingAI = false;
      });
    }
  }

  String _getOptionName(String optionId) {
    return widget.decision.options
        .firstWhere((option) => option.id == optionId)
        .name;
  }

  Color _getOptionColor(int index) {
    final colors = [
      const Color(AppConstants.primaryColor),
      const Color(AppConstants.secondaryColor),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFFA855F7),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final sortedScores = _scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bestScore = sortedScores.isNotEmpty ? sortedScores.first.value : 0.0;
    final secondBestScore = sortedScores.length > 1
        ? sortedScores[1].value
        : 0.0;
    final scoreDifference = bestScore - secondBestScore;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decision Report'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.decision.title,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Generated on ${Helpers.formatReportDate(DateTime.now())}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (sortedScores.isNotEmpty) ...[
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Final Scores',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.paddingSmall,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getOptionColor(
                                      0,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getOptionName(sortedScores.first.key),
                                    style: TextStyle(
                                      color: _getOptionColor(0),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Helpers.formatScore(sortedScores.first.value),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          if (sortedScores.length > 1) ...[
                            Column(
                              children: [
                                Text(
                                  'Score difference',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '+${Helpers.formatScore(scoreDifference)}',
                                  style: const TextStyle(
                                    color: Color(AppConstants.secondaryColor),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppConstants.paddingSmall,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getOptionColor(
                                        1,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getOptionName(sortedScores[1].key),
                                      style: TextStyle(
                                        color: _getOptionColor(1),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Helpers.formatScore(sortedScores[1].value),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Comparison',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Center(
                    child: RadarChartWidget(
                      decision: widget.decision,
                      size: 280,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Wrap(
                    spacing: AppConstants.paddingMedium,
                    runSpacing: AppConstants.paddingSmall,
                    children: widget.decision.options.asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final option = entry.value;
                      final color = _getOptionColor(index);

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
                            option.name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        'AI Analysis',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(fontSize: 18),
                      ),
                      if (_isLoadingAI) ...[
                        const SizedBox(width: AppConstants.paddingSmall),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  if (_isLoadingAI)
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusSmall,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: AppConstants.paddingSmall),
                          Text(
                            'AI is analyzing your decision...',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      _analysis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Archive Decision',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: PrimaryButton(
                    text: 'New Decision',
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
