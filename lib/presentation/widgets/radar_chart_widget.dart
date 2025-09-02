import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/decision_model.dart';
import '../../core/app_constants.dart';

class RadarChartWidget extends StatelessWidget {
  final Decision decision;
  final double size;

  const RadarChartWidget({
    super.key,
    required this.decision,
    this.size = 250,
  });

  @override
  Widget build(BuildContext context) {
    if (decision.criteria.isEmpty || decision.options.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            'No data available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: RadarChart(
        RadarChartData(
          radarTouchData: RadarTouchData(enabled: false),
          dataSets: _buildDataSets(),
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: const BorderSide(color: Colors.transparent),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          getTitle: (index, angle) {
            if (index < decision.criteria.length) {
              return RadarChartTitle(
                text: decision.criteria[index].name,
                angle: angle,
              );
            }
            return const RadarChartTitle(text: '');
          },
          tickCount: 5,
          ticksTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 8,
            color: Colors.grey,
          ),
          tickBorderData: const BorderSide(color: Colors.grey, width: 0.5),
          gridBorderData: const BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
    );
  }

  List<RadarDataSet> _buildDataSets() {
    final List<RadarDataSet> dataSets = [];
    final colors = [
      const Color(AppConstants.primaryColor),
      const Color(AppConstants.secondaryColor),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFFA855F7),
    ];

    for (int i = 0; i < decision.options.length && i < colors.length; i++) {
      final option = decision.options[i];
      final color = colors[i];
      
      final dataEntries = decision.criteria.map((criterion) {
        final score = option.getScore(criterion.id).toDouble();
        return RadarEntry(value: score);
      }).toList();

      dataSets.add(
        RadarDataSet(
          fillColor: color.withValues(alpha: 0.2),
          borderColor: color,
          entryRadius: 3,
          dataEntries: dataEntries,
          borderWidth: 2,
        ),
      );
    }

    return dataSets;
  }
}