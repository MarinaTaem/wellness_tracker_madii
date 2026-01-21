import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:wellness_tracker/providers/study_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final tasksPerSubject = studyProvider.tasksPerSubject;
    final focusPerSubject = studyProvider.focusMinutesPerSubject;
    final totalTasks = studyProvider.totalTasksCount;
    final completedTasks = studyProvider.completedTasksCount;
    final totalFocusMinutes = studyProvider.totalFocusMinutes;

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildStatCards(completedTasks, totalTasks, totalFocusMinutes),
            const SizedBox(height: 32),
            const Text(
              'Focus Time per Subject (min)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // TIMER -
            const SizedBox(height: 16),
            focusPerSubject.isEmpty
                ? const Center(child: Text('No focus data available'))
                : SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 &&
                                    index < focusPerSubject.keys.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      tasksPerSubject.keys
                                          .elementAt(index)
                                          .substring(0, 3),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: focusPerSubject.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                  toY: entry.value.value.toDouble(),
                                  color: const Color(0xFF6C63FF),
                                  width: 16,
                                  borderRadius: BorderRadius.circular(4))
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),

            const SizedBox(height: 32),
            const Text(
              'Task Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            tasksPerSubject.isEmpty
                ? const Center(child: Text('No task data available'))
                : SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: tasksPerSubject.entries.map((entry) {
                          final index =
                              tasksPerSubject.keys.toList().indexOf(entry.key);
                          final colors = [
                            const Color(0xFF6C63FF),
                            const Color(0xFF03DAC6),
                            Colors.orange,
                            Colors.pink,
                            Colors.amber
                          ];
                          return PieChartSectionData(
                            value: entry.value.toDouble(),
                            color: colors[index % colors.length],
                            title: entry.key,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
            // const SizedBox(height: 32),
            // const Text(
            //   'Task Completion Distribution',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 16),
            // tasksPerSubject.isEmpty
            //     ? Center(
            //         child: Text('No distribution data available'),
            //       )
            //     : SizedBox(
            //         height: 200,
            //         child: PieChart(PieChartData(
            //           sections: tasksPerSubject.entries.map((entry) {
            //             final index =
            //                 tasksPerSubject.keys.toList().indexOf(entry.key);
            //             final colors = [
            //               const Color(0xFF6C63FF),
            //               const Color(0xFF03DAC6),
            //               Colors.orange,
            //               Colors.pink,
            //               Colors.amber
            //             ];

            //             return PieChartSectionData(
            //               value: entry.value.toDouble(),
            //               color: colors[index % colors.length],
            //               title: entry.key,
            //               radius: 50,
            //               titleStyle: const TextStyle(
            //                 fontSize: 12,
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.white,
            //               ),
            //             );
            //           }).toList(),
            //         )),
            //       ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((period) {
          bool isSelected = period == 'Weekly';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (_) {},
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatCards(int completed, int total, int focus) {
    return Column(
      children: [
        Row(
          children: [
            _statCard(
                'Total Tasks', total.toString(), Icons.assignment, Colors.blue),
            const SizedBox(width: 16),
            _statCard('Completed', completed.toString(), Icons.check_circle,
                Colors.green),
            const SizedBox(width: 16),
            _statCard(
              'Efficiency',
              total == 0 ? '0%' : '${(completed / total * 100).toInt()}%',
              Icons.trending_up,
              Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _statCard(
              'Focus Time',
              '${focus}m',
              Icons.timer,
              Colors.orange,
            ),
            const SizedBox(width: 16),
            _statCard(
              'Efficiency',
              total == 0 ? '0%' : '${(completed / total * 100).toInt()}%',
              Icons.trending_up,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
