import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/util_components/util.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AnalyticsReport {
  final String hotelLoc;
  final DateTime startDate;
  final DateTime endDate;
  final double totalSales;
  final int totalOrders;
  final String peakHour;
  final Map<String, int> paymentModeCount;
  final Map<String, Map<String, dynamic>> itemAnalytics;
  final Map<String, double> chartData;
  final String granularity;
  final String timeFrame;

  AnalyticsReport({
    required this.hotelLoc,
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.totalOrders,
    required this.peakHour,
    required this.paymentModeCount,
    required this.itemAnalytics,
    required this.chartData,
    required this.granularity,
    required this.timeFrame,
  });

  /// Generate PDF report with safe symbols
  Future<pw.Document> generatePdfReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header with gradient
            pw.Container(
              padding: pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [PdfColors.blue700, PdfColors.blue900],
                ),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ANALYTICS REPORT',
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        hotelLoc,
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding:
                        pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      DateFormat('MMM d, yyyy').format(DateTime.now()),
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 25),

            // Report Period Section
            _buildPdfSectionHeader('REPORT PERIOD', PdfColors.purple700),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple50,
                border: pw.Border.all(color: PdfColors.purple200, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  _buildInfoRow('Time Frame', timeFrame.toUpperCase()),
                  _buildDivider(),
                  _buildInfoRow('Granularity', _formatGranularity(granularity)),
                  _buildDivider(),
                  _buildInfoRow('Start Date',
                      DateFormat('MMM d, yyyy HH:mm').format(startDate)),
                  _buildDivider(),
                  _buildInfoRow('End Date',
                      DateFormat('MMM d, yyyy HH:mm').format(endDate)),
                  _buildDivider(),
                  _buildInfoRow(
                      'Generated',
                      DateFormat('MMM d, yyyy HH:mm:ss')
                          .format(DateTime.now())),
                ],
              ),
            ),
            pw.SizedBox(height: 25),

            // Summary Statistics with colored boxes
            _buildPdfSectionHeader('SUMMARY STATISTICS', PdfColors.green700),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBox(
                  'TOTAL SALES',
                  'Rs ${totalSales.toStringAsFixed(2)}',
                  PdfColors.green,
                  '<>',
                ),
                pw.SizedBox(width: 12),
                _buildStatBox(
                  'TOTAL ORDERS',
                  '$totalOrders',
                  PdfColors.blue,
                  '#',
                ),
                pw.SizedBox(width: 12),
                _buildStatBox(
                  'AVG ORDER',
                  'Rs ${(totalOrders > 0 ? totalSales / totalOrders : 0).toStringAsFixed(2)}',
                  PdfColors.orange,
                  '~',
                ),
              ],
            ),
            pw.SizedBox(height: 25),

            // Peak Hours
            if (peakHour.isNotEmpty) ...[
              _buildPdfSectionHeader('PEAK HOURS', PdfColors.deepPurple700),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.deepPurple50,
                  border:
                      pw.Border.all(color: PdfColors.deepPurple200, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 40,
                          height: 40,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.deepPurple700,
                            shape: pw.BoxShape.circle,
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              '<>',
                              style: pw.TextStyle(
                                  fontSize: 20, color: PdfColors.white),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Busiest Time',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                peakHour,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.deepPurple900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Container(
                      padding: pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.amber100,
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: PdfColors.amber300),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Container(
                            width: 6,
                            height: 6,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.amber900,
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Expanded(
                            child: pw.Text(
                              'RECOMMENDATION: Increase staff and stock during this time',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontStyle: pw.FontStyle.italic,
                                color: PdfColors.grey800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),
            ],

            // Payment Mode Analysis
            if (paymentModeCount.isNotEmpty) ...[
              _buildPdfSectionHeader(
                  'PAYMENT MODE ANALYSIS', PdfColors.indigo700),
              pw.SizedBox(height: 12),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Table(
                  border: pw.TableBorder.symmetric(
                    inside: pw.BorderSide(color: PdfColors.grey300),
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1),
                  },
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.indigo700,
                      ),
                      children: [
                        _buildTableHeaderCell('Payment Mode'),
                        _buildTableHeaderCell('Count'),
                        _buildTableHeaderCell('Percentage'),
                      ],
                    ),
                    // Data rows
                    ...paymentModeCount.entries.map((entry) {
                      int totalTrans =
                          paymentModeCount.values.fold(0, (a, b) => a + b);
                      double pct = (entry.value / totalTrans) * 100;
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey50,
                        ),
                        children: [
                          _buildTableCell(entry.key),
                          _buildTableCell('${entry.value}',
                              align: pw.Alignment.center),
                          _buildTableCell('${pct.toStringAsFixed(1)}%',
                              align: pw.Alignment.centerRight),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),
            ],

            // Top Selling Items
            if (itemAnalytics.isNotEmpty) ...[
              _buildPdfSectionHeader('TOP SELLING ITEMS', PdfColors.teal700),
              pw.SizedBox(height: 12),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Table(
                  border: pw.TableBorder.symmetric(
                    inside: pw.BorderSide(color: PdfColors.grey300),
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(0.5),
                    1: pw.FlexColumnWidth(3),
                    2: pw.FlexColumnWidth(1.5),
                    3: pw.FlexColumnWidth(1),
                    4: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.teal700),
                      children: [
                        _buildTableHeaderCell('#'),
                        _buildTableHeaderCell('Item Name'),
                        _buildTableHeaderCell('Price (Rs)'),
                        _buildTableHeaderCell('Qty'),
                        _buildTableHeaderCell('Revenue (Rs)'),
                      ],
                    ),
                    // Data rows with ranking
                    ..._getTopItemsForPdf().asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> item = entry.value;
                      bool isTop3 = index < 3;

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: isTop3 ? PdfColors.amber50 : PdfColors.grey50,
                        ),
                        children: [
                          _buildTableCell(
                            '${index + 1}',
                            align: pw.Alignment.center,
                            isBold: isTop3,
                          ),
                          _buildTableCell(item['name'], isBold: isTop3),
                          _buildTableCell(
                            '${item['price'].toStringAsFixed(2)}',
                            align: pw.Alignment.centerRight,
                          ),
                          _buildTableCell(
                            '${item['count']}',
                            align: pw.Alignment.center,
                          ),
                          _buildTableCell(
                            '${item['total'].toStringAsFixed(2)}',
                            align: pw.Alignment.centerRight,
                            isBold: isTop3,
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),
            ],

            // Sales by Period
            if (chartData.isNotEmpty) ...[
              _buildPdfSectionHeader('SALES BY ${granularity.toUpperCase()}',
                  PdfColors.deepOrange700),
              pw.SizedBox(height: 12),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Table(
                  border: pw.TableBorder.symmetric(
                    inside: pw.BorderSide(color: PdfColors.grey300),
                  ),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration:
                          pw.BoxDecoration(color: PdfColors.deepOrange700),
                      children: [
                        _buildTableHeaderCell('Period'),
                        _buildTableHeaderCell('Sales Amount'),
                      ],
                    ),
                    // Data rows
                    ...chartData.entries.map((entry) {
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey50),
                        children: [
                          _buildTableCell(entry.key),
                          _buildTableCell(
                            '${entry.value.toStringAsFixed(2)}',
                            align: pw.Alignment.centerRight,
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green100,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.green300, width: 2),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 6,
                      height: 6,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green700,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'HIGHEST SALES: ${_getHighestSalesPeriod()}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Footer
            pw.SizedBox(height: 30),
            pw.Container(
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Container(
                    width: double.infinity,
                    height: 3,
                    color: PdfColors.blue700,
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'END OF REPORT',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                      letterSpacing: 2,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated by OrderEase Analytics System',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  // Helper: Build section header
  pw.Widget _buildPdfSectionHeader(String title, PdfColor color) {
    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // Helper: Build info row
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Build divider
  pw.Widget _buildDivider() {
    return pw.Container(
      margin: pw.EdgeInsets.symmetric(vertical: 4),
      height: 1,
      color: PdfColors.purple100,
    );
  }

  // Helper: Build stat box
  pw.Widget _buildStatBox(
      String label, String value, PdfColor color, String symbol) {
    return pw.Expanded(
      child: pw.Container(
        padding: pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: color.shade(0.9),
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: color, width: 3),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.Container(
                  width: 24,
                  height: 24,
                  decoration: pw.BoxDecoration(
                    color: color,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      symbol,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Build table header cell
  pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  // Helper: Build table cell
  pw.Widget _buildTableCell(String text,
      {pw.Alignment? align, bool isBold = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(10),
      child: pw.Align(
        alignment: align ?? pw.Alignment.centerLeft,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: PdfColors.grey800,
          ),
        ),
      ),
    );
  }

  // Get top items sorted by count
  List<Map<String, dynamic>> _getTopItemsForPdf() {
    List<Map<String, dynamic>> items = [];
    itemAnalytics.forEach((name, data) {
      items.add({
        'name': name,
        'price': data['price'],
        'count': data['count'],
        'total': data['total'],
      });
    });
    items.sort((a, b) => b['count'].compareTo(a['count']));
    return items.take(10).toList();
  }

  // Get highest sales period
  String _getHighestSalesPeriod() {
    if (chartData.isEmpty) return 'N/A';
    double highestSale = 0;
    String highestPeriod = '';
    chartData.forEach((period, sales) {
      if (sales > highestSale) {
        highestSale = sales;
        highestPeriod = period;
      }
    });
    return '$highestPeriod (Rs ${highestSale.toStringAsFixed(2)})';
  }

  /// Download PDF report
  Future<void> downloadPdfReport(BuildContext context) async {
    try {
      // Log
      String email = FirebaseAuth.instance.currentUser!.email!;
      await addLogEntry(
        hotelId: hotelLoc,
        userEmail: email,
        action: "Analytics Report ($granularity, $timeFrame) downloaded.",
        tableNumber: "",
        sessionId: "",
      );

      final pdf = await generatePdfReport();
      final bytes = await pdf.save();

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
      final fileName = 'analytics_report_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          content: Row(
            children: [
              Icon(Icons.download_done, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Report downloaded: $fileName',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Printing.layoutPdf(
                    onLayout: (_) async => bytes,
                  );
                },
                child: Text(
                  'Open',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error downloading PDF report: $e');
      showBounceSnackBar(context, 'Error downloading report: $e', "fail");
    }
  }

  /// Share PDF report
  Future<void> sharePdfReport(BuildContext context) async {
    try {
      // Log
      String email = FirebaseAuth.instance.currentUser!.email!;
      await addLogEntry(
        hotelId: hotelLoc,
        userEmail: email,
        action: "Analytics Report ($granularity, $timeFrame) shared.",
        tableNumber: "",
        sessionId: "",
      );

      final pdf = await generatePdfReport();
      final bytes = await pdf.save();

      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
      final fileName = 'analytics_report_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Analytics Report - $hotelLoc',
        text:
            'Analytics Report for $hotelLoc (${DateFormat('MMM d, yyyy').format(startDate)} to ${DateFormat('MMM d, yyyy').format(endDate)})',
      );
    } catch (e) {
      print('Error sharing PDF report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Preview PDF report
  Future<void> previewPdfReport(BuildContext context) async {
    try {
      final pdf = await generatePdfReport();
      final bytes = await pdf.save();

      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'Analytics Report',
      );
    } catch (e) {
      print('Error previewing PDF report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error previewing report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatGranularity(String granularity) {
    switch (granularity.toLowerCase()) {
      case 'hourly':
        return 'Hourly';
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'yearly':
        return 'Yearly';
      default:
        return granularity;
    }
  }
}

/// Widget to display report download/share options
class AnalyticsReportActions extends StatelessWidget {
  final AnalyticsReport report;

  const AnalyticsReportActions({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text(
                'Export PDF Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Download or share your analytics report',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              // Preview Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    report.previewPdfReport(context);
                  },
                  icon: Icon(Icons.preview, size: 20),
                  label: Text('Preview', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              // Share Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    report.sharePdfReport(context);
                  },
                  icon: Icon(Icons.share, size: 20),
                  label: Text('Share', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Download Button (Full Width)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                report.downloadPdfReport(context);
              },
              icon: Icon(Icons.download, size: 20),
              label: Text('Download PDF', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
