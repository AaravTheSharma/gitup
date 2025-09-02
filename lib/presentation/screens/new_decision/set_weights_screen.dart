import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../../data/models/decision_model.dart';
import '../../../data/models/criterion_model.dart';
import '../../../utils/helpers.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/primary_button.dart';
import 'score_options_screen.dart';

class SetWeightsScreen extends StatefulWidget {
  final Decision decision;

  const SetWeightsScreen({super.key, required this.decision});

  @override
  State<SetWeightsScreen> createState() => _SetWeightsScreenState();
}

class _SetWeightsScreenState extends State<SetWeightsScreen> {
  late List<Criterion> _criteria;
  final Map<String, double> _weights = {};

  @override
  void initState() {
    super.initState();
    _criteria = List.from(widget.decision.criteria);
    
    // Initialize weights
    for (final criterion in _criteria) {
      _weights[criterion.id] = 70.0; // Default weight
    }
  }

  void _updateWeight(String criterionId, double weight) {
    setState(() {
      _weights[criterionId] = weight;
    });
  }

  void _continue() {
    // Update criteria with new weights
    final updatedCriteria = _criteria.map((criterion) {
      final weight = (_weights[criterion.id] ?? 70.0) / 100.0; // Convert to 0-1 range
      return criterion.copyWith(weight: weight);
    }).toList();

    final updatedDecision = widget.decision.copyWith(criteria: updatedCriteria);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScoreOptionsScreen(decision: updatedDecision),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Importance'),
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
                    'Assign Weight to Criteria',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Drag sliders to assign importance (0-100%) to each criterion. This reflects their relative importance in your decision.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),
                  ..._criteria.map((criterion) {
                    final weight = _weights[criterion.id] ?? 70.0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.paddingXLarge),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingSmall,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${weight.round()}%',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Theme.of(context).primaryColor,
                              inactiveTrackColor: Colors.grey[300],
                              thumbColor: Theme.of(context).primaryColor,
                              overlayColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: weight,
                              min: 0,
                              max: 100,
                              divisions: 100,
                              onChanged: (value) => _updateWeight(criterion.id, value),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Expanded(
                          child: Text(
                            'Higher percentages mean the criterion is more important in your final decision.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),
                  PrimaryButton(
                    text: 'Continue',
                    onPressed: _continue,
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