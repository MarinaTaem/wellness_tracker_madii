import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildStatCards(),
            const SizedBox(height: 32),
            const Text(
              'Study Hours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5, color: const Color(0xFF6C63FF))]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: const Color(0xFF6C63FF))]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3, color: const Color(0xFF6C63FF))]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 7, color: const Color(0xFF6C63FF))]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 6, color: const Color(0xFF6C63FF))]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Task Completion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 40, color: const Color(0xFF6C63FF), title: 'Math'),
                    PieChartSectionData(value: 30, color: const Color(0xFF03DAC6), title: 'Physics'),
                    PieChartSectionData(value: 30, color: Colors.orange, title: 'History'),
                  ],
                ),
              ),
            ),
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

  Widget _buildStatCards() {
    return Row(
      children: [
        _statCard('Focus Time', '12.5h', Icons.timer, Colors.blue),
        const SizedBox(width: 16),
        _statCard('Tasks Done', '24', Icons.check_circle, Colors.green),
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
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
