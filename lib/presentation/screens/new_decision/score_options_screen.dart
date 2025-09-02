import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../../data/models/decision_model.dart';
import '../../../data/models/option_model.dart';
import '../../../data/services/storage_service.dart';
import '../../../utils/helpers.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/primary_button.dart';
import '../report/report_screen.dart';

class ScoreOptionsScreen extends StatefulWidget {
  final Decision decision;

  const ScoreOptionsScreen({super.key, required this.decision});

  @override
  State<ScoreOptionsScreen> createState() => _ScoreOptionsScreenState();
}

class _ScoreOptionsScreenState extends State<ScoreOptionsScreen> {
  late Decision _decision;
  bool _isGenerating = false;
  StorageService? _storageService;

  @override
  void initState() {
    super.initState();
    _decision = widget.decision;
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageService.getInstance();
  }

  void _updateScore(String optionId, String criterionId, int score) {
    setState(() {
      final optionIndex = _decision.options.indexWhere((o) => o.id == optionId);
      if (optionIndex >= 0) {
        final updatedOption = _decision.options[optionIndex];
        updatedOption.setScore(criterionId, score);
        
        final updatedOptions = List<Option>.from(_decision.options);
        updatedOptions[optionIndex] = updatedOption;
        
        _decision = _decision.copyWith(options: updatedOptions);
      }
    });
  }

  Future<void> _generateReport() async {
    if (_storageService == null) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // Mark decision as completed
      final completedDecision = _decision.copyWith(
        status: AppConstants.statusCompleted,
      );

      // Save to storage
      await _storageService!.saveDecision(completedDecision);

      // Navigate to report
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ReportScreen(decision: completedDecision),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving decision: $e'),
            backgroundColor: const Color(AppConstants.dangerColor),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  bool _canGenerateReport() {
    for (final option in _decision.options) {
      for (final criterion in _decision.criteria) {
        if (option.getScore(criterion.id) == 0) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Options'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                    'Score Each Option',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Rate each option against the criteria (1-10 scale).',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),
                  ..._decision.criteria.map((criterion) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.paddingXLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Helpers.getCriterionIcon(criterion.icon),
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: AppConstants.paddingSmall),
                              Text(
                                criterion.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),
                          ..._decision.options.map((option) {
                            final currentScore = option.getScore(criterion.id);
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      option.name,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Wrap(
                                      spacing: 4,
                                      children: List.generate(10, (index) {
                                        final score = index + 1;
                                        final isSelected = currentScore == score;
                                        
                                        return GestureDetector(
                                          onTap: () => _updateScore(option.id, criterion.id, score),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Theme.of(context).primaryColor
                                                  : Colors.white,
                                              border: Border.all(
                                                color: isSelected
                                                    ? Theme.of(context).primaryColor
                                                    : Colors.grey[300]!,
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Center(
                                              child: Text(
                                                score.toString(),
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                  if (!_canGenerateReport()) ...[
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        border: Border(
                          left: BorderSide(
                            color: const Color(0xFFF59E0B),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            color: Color(0xFF92400E),
                            size: 16,
                          ),
                          const SizedBox(width: AppConstants.paddingSmall),
                          Expanded(
                            child: Text(
                              'Please score all options for all criteria to generate the report.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                  ],
                  PrimaryButton(
                    text: 'Generate Analysis Report',
                    onPressed: _canGenerateReport() ? _generateReport : null,
                    isLoading: _isGenerating,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}