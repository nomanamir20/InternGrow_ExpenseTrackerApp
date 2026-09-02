import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/reports/controllers/reports_controller.dart';

/// Builds a PDF document summarizing a month's income, expenses, and
/// category breakdown — used for the "PDF Report Export" upgrade feature.
class PdfReportService {
  Future<pw.Document> buildMonthlyReport({
    required DateTime month,
    required double income,
    required double expense,
    required List<CategorySpending> categoryBreakdown,
  }) async {
    final doc = pw.Document();
    final net = income - expense;
    final currency = NumberFormat.currency(symbol: '\$');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'InternGrow Finance',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Monthly Report — ${DateFormat('MMMM yyyy').format(month)}',
                style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 24),

              // Summary row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _summaryBox('Income', currency.format(income), PdfColors.green700),
                  _summaryBox('Expense', currency.format(expense), PdfColors.red700),
                  _summaryBox(
                    'Net Savings',
                    currency.format(net),
                    net >= 0 ? PdfColors.green700 : PdfColors.red700,
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              pw.Text(
                'Spending by Category',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),

              if (categoryBreakdown.isEmpty)
                pw.Text('No expenses recorded for this month.', style: const pw.TextStyle(color: PdfColors.grey600))
              else
                pw.TableHelper.fromTextArray(
                  headers: ['Category', 'Amount', '% of Total'],
                  data: [
                    for (final category in categoryBreakdown)
                      [
                        category.categoryName,
                        currency.format(category.amount),
                        '${category.percentage.toStringAsFixed(1)}%',
                      ],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),

              pw.SizedBox(height: 32),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              pw.Text(
                'Generated on ${DateFormat('MMM d, yyyy • h:mm a').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
              ),
            ],
          );
        },
      ),
    );

    return doc;
  }

  pw.Widget _summaryBox(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }
}