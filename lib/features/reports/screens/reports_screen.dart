import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

import '../../../core/services/pdf_report_service.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/reports_controller.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Future<void> _exportPdf(ReportsController controller) async {
    final pdfService = PdfReportService();

    final doc = await pdfService.buildMonthlyReport(
      month: controller.selectedMonth.value,
      income: controller.monthlyIncome,
      expense: controller.monthlyExpense,
      categoryBreakdown: controller.expenseByCategory,
    );

    final fileName = 'InternGrow_Report_${controller.formattedSelectedMonth.replaceAll(' ', '_')}.pdf';

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: fileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF',
            onPressed: () => _exportPdf(controller),
          ),
        ],
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: controller.goToPreviousMonth,
                  ),
                  Text(
                    controller.formattedSelectedMonth,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: controller.isCurrentMonth ? null : controller.goToNextMonth,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Income',
                    value: controller.monthlyIncome,
                    color: AppColors.income,
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Expense',
                    value: controller.monthlyExpense,
                    color: AppColors.expense,
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: controller.monthlyNet >= 0
                    ? AppColors.income.withValues(alpha: 0.1)
                    : AppColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Net Savings', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '${controller.monthlyNet >= 0 ? '+' : ''}\$${controller.monthlyNet.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: controller.monthlyNet >= 0 ? AppColors.income : AppColors.expense,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            if (controller.expenseByCategory.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('No expenses recorded for this month.', style: TextStyle(color: subTextColor)),
                ),
              )
            else ...[
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: [
                      for (final category in controller.expenseByCategory)
                        PieChartSectionData(
                          value: category.amount,
                          color: Color(category.colorValue),
                          title: '${category.percentage.toStringAsFixed(0)}%',
                          radius: 45,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (final category in controller.expenseByCategory)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: Color(category.colorValue), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(category.categoryName, style: const TextStyle(fontSize: 13))),
                      Text(
                        '\$${category.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 28),
            Text(
              'Income vs. Expense (Last 6 Months)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 220,
              child: _TrendBarChart(data: controller.last6MonthsTrend),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: AppColors.income, label: 'Income'),
                const SizedBox(width: 20),
                _LegendDot(color: AppColors.expense, label: 'Expense'),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _exportPdf(controller),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export This Month as PDF'),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _SummaryCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _TrendBarChart extends StatelessWidget {
  final List<MonthlyTotal> data;

  const _TrendBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold(0.0, (max, m) {
      final localMax = m.income > m.expense ? m.income : m.expense;
      return localMax > max ? localMax : max;
    });

    return BarChart(
      BarChartData(
        maxY: maxValue == 0 ? 100 : maxValue * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                final month = data[index].month;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${month.month}/${month.year.toString().substring(2)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: [
          for (int i = 0; i < data.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: data[i].income, color: AppColors.income, width: 8, borderRadius: BorderRadius.circular(2)),
                BarChartRodData(toY: data[i].expense, color: AppColors.expense, width: 8, borderRadius: BorderRadius.circular(2)),
              ],
              barsSpace: 4,
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}