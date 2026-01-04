import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/food_review/review_analytics.dart';
import 'package:orderease/util_components/profile.dart';
import 'package:orderease/util_components/util.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:orderease/Settlements/get_analytics_report.dart';

class AnalyticsDashboard extends StatefulWidget {
  final String hotel_loc;

  const AnalyticsDashboard({Key? key, required this.hotel_loc})
      : super(key: key);

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  String _selectedFilter = 'daily'; // daily, hourly, weekly, monthly, yearly
  String _selectedTimeFrame =
      'today'; // today, this_week, this_month, this_year, custom
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  int _topItemsCount = 10; // For top items dropdown
  String _sortBy = 'count'; // count, price, total

  Map<String, double> chartData = {};
  List<Map<String, dynamic>> settlements = [];
  Map<String, dynamic> food_reviews = {};
  bool _isLoading = true;
  double totalSales = 0;
  int totalOrders = 0;

  bool _showAllOrders = false;

  // New analytics data
  Map<String, Map<String, dynamic>> itemAnalytics =
      {}; // item_name -> {price, count, total}
  Map<String, int> paymentModeCount = {}; // payment_mode -> count
  String peakHour = '';
  Map<int, int> hourlyOrderCount = {}; // hour -> count

  @override
  void initState() {
    super.initState();
    _fetchSettlements();
  }

  Future<void> _fetchSettlements() async {
    try {
      setState(() => _isLoading = true);

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.hotel_loc)
          .collection("Settlements")
          .get();

      settlements = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      _processDataForChart();
      _calculateItemAnalytics();
      _calculatePaymentModeAnalytics();
      _calculatePeakHour();

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.hotel_loc)
          .collection("Food_Reviews").doc("food_review_data")
          .get();

      food_reviews = documentSnapshot.data() as Map<String, dynamic>;

      print(food_reviews);
      print("FOOD REVEIW DATA");

      setState(() {
        food_reviews = food_reviews;
        settlements = settlements;
      });
    } catch (e) {
      print("Error fetching settlements: $e");
    }
  }

  void _processDataForChart() {
    chartData.clear();
    totalSales = 0;
    totalOrders = 0;

    // Filter settlements based on selected timeframe
    List<Map<String, dynamic>> filteredSettlements =
        _filterByTimeFrame(settlements);

    // Process data based on selected filter
    switch (_selectedFilter) {
      case 'hourly':
        _processHourlyData(filteredSettlements);
        break;
      case 'daily':
        _processDailyData(filteredSettlements);
        break;
      case 'weekly':
        _processWeeklyData(filteredSettlements);
        break;
      case 'monthly':
        _processMonthlyData(filteredSettlements);
        break;
      case 'yearly':
        _processYearlyData(filteredSettlements);
        break;
    }

    // Recalculate all analytics
    _calculateItemAnalytics();
    _calculatePaymentModeAnalytics();
    _calculatePeakHour();

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _filterByTimeFrame(
      List<Map<String, dynamic>> data) {
    DateTime now = DateTime.now();
    DateTime filterStart = _startDate;
    DateTime filterEnd = _endDate.add(Duration(days: 1));

    switch (_selectedTimeFrame) {
      case 'today':
        filterStart = DateTime(now.year, now.month, now.day);
        filterEnd = DateTime(now.year, now.month, now.day + 1);
        break;
      case 'this_week':
        filterStart = now.subtract(Duration(days: now.weekday - 1));
        filterEnd = now.add(Duration(days: 7 - now.weekday + 1));
        break;
      case 'this_month':
        filterStart = DateTime(now.year, now.month, 1);
        filterEnd = DateTime(now.year, now.month + 1, 1);
        break;
      case 'this_year':
        filterStart = DateTime(now.year, 1, 1);
        filterEnd = DateTime(now.year + 1, 1, 1);
        break;
      case 'custom':
        break;
    }

    return data.where((settlement) {
      try {
        // Try multiple possible time field names
        String? timeString;

        if (settlement.containsKey('settled_time')) {
          timeString = settlement['settled_time'].toString();
        } else if (settlement.containsKey('generate_bill_time')) {
          timeString = settlement['generate_bill_time'].toString();
        } else if (settlement.containsKey('timestamp')) {
          timeString = settlement['timestamp'].toString();
        }

        if (timeString != null) {
          DateTime settleDate = DateTime.parse(timeString);
          return settleDate.isAfter(filterStart) &&
              settleDate.isBefore(filterEnd);
        }
        return false;
      } catch (e) {
        print("Error filtering settlement: $e");
        return false;
      }
    }).toList();
  }

  void _processHourlyData(List<Map<String, dynamic>> data) {
    // Group by hour (00:00 - 23:00)
    for (int i = 0; i < 24; i++) {
      chartData['$i:00'] = 0;
    }

    for (var settlement in data) {
      try {
        String? timeString;
        if (settlement.containsKey('settled_time')) {
          timeString = settlement['settled_time'].toString();
        } else if (settlement.containsKey('generate_bill_time')) {
          timeString = settlement['generate_bill_time'].toString();
        }

        if (timeString != null) {
          DateTime settleDate = DateTime.parse(timeString);
          String hour = '${settleDate.hour}:00';
          double amount = double.tryParse(
                  settlement['discount_amount']?.toString() ?? '0') ??
              0;
          chartData[hour] = (chartData[hour] ?? 0) + amount;
          totalSales += amount;
          totalOrders++;
        }
      } catch (e) {
        print("Error processing hourly data: $e");
      }
    }
  }

  void _processDailyData(List<Map<String, dynamic>> data) {
    // Group by day
    Map<String, double> dailyData = {};

    for (var settlement in data) {
      try {
        String? timeString;
        if (settlement.containsKey('settled_time')) {
          timeString = settlement['settled_time'].toString();
        } else if (settlement.containsKey('generate_bill_time')) {
          timeString = settlement['generate_bill_time'].toString();
        }

        if (timeString != null) {
          DateTime settleDate = DateTime.parse(timeString);
          String day = DateFormat('MMM d').format(settleDate);
          double amount = double.tryParse(
                  settlement['discount_amount']?.toString() ?? '0') ??
              0;
          dailyData[day] = (dailyData[day] ?? 0) + amount;
          totalSales += amount;
          totalOrders++;
        }
      } catch (e) {
        print("Error processing daily data: $e");
      }
    }

    chartData = dailyData;
  }

  void _processWeeklyData(List<Map<String, dynamic>> data) {
    // Group by week
    Map<String, double> weeklyData = {};

    for (var settlement in data) {
      try {
        String? timeString;
        if (settlement.containsKey('settled_time')) {
          timeString = settlement['settled_time'].toString();
        } else if (settlement.containsKey('generate_bill_time')) {
          timeString = settlement['generate_bill_time'].toString();
        }

        if (timeString != null) {
          DateTime settleDate = DateTime.parse(timeString);
          int week = _getWeekNumber(settleDate);
          String weekLabel = 'Week $week';
          double amount = double.tryParse(
                  settlement['discount_amount']?.toString() ?? '0') ??
              0;
          weeklyData[weekLabel] = (weeklyData[weekLabel] ?? 0) + amount;
          totalSales += amount;
          totalOrders++;
        }
      } catch (e) {
        print("Error processing weekly data: $e");
      }
    }

    chartData = weeklyData;
  }

  void _processMonthlyData(List<Map<String, dynamic>> data) {
    // Group by month
    Map<String, double> monthlyData = {};

    for (var settlement in data) {
      try {
        String? timeString;
        if (settlement.containsKey('settled_time')) {
          timeString = settlement['settled_time'].toString();
        } else if (settlement.containsKey('generate_bill_time')) {
          timeString = settlement['generate_bill_time'].toString();
        }

        if (timeString != null) {
          DateTime settleDate = DateTime.parse(timeString);
          String month = DateFormat('MMM yyyy').format(settleDate);
          double amount = double.tryParse(
                  settlement['discount_amount']?.toString() ?? '0') ??
              0;
          monthlyData[month] = (monthlyData[month] ?? 0) + amount;
          totalSales += amount;
          totalOrders++;
        }
      } catch (e) {
        print("Error processing monthly data: $e");
      }
    }

    chartData = monthlyData;
  }

  void _processYearlyData(List<Map<String, dynamic>> data) {
    // Group by year
    Map<String, double> yearlyData = {};

    for (var settlement in data) {
      try {
        String? timeString;
        if (settlement.containsKey('settled_time')) {
          timeString = settlement['settled_time'].toString();
        } else if (settlement.containsKey('generate_bill_time')) {
          timeString = settlement['generate_bill_time'].toString();
        }

        if (timeString != null) {
          DateTime settleDate = DateTime.parse(timeString);
          String year = settleDate.year.toString();
          double amount = double.tryParse(
                  settlement['discount_amount']?.toString() ?? '0') ??
              0;
          yearlyData[year] = (yearlyData[year] ?? 0) + amount;
          totalSales += amount;
          totalOrders++;
        }
      } catch (e) {
        print("Error processing yearly data: $e");
      }
    }

    chartData = yearlyData;
  }

  int _getWeekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDay).inDays + 1;
    return ((dayOfYear - 1) ~/ 7) + 1;
  }

  void _calculateItemAnalytics() {
    print("Food Analytics");
    itemAnalytics.clear();
    List<Map<String, dynamic>> filteredSettlements =
        _filterByTimeFrame(settlements);

    for (var settlement in filteredSettlements) {
      // Remove metadata fields to get only the items
      Map<String, dynamic> items = Map.from(settlement);

      // Remove non-item fields
      items.removeWhere((key, value) =>
          key == 'table_option' ||
          key == 'settled_time' ||
          key == 'discount_amount' ||
          key == 'mode_of_payment' ||
          key == 'email' ||
          key == 'mg_name' ||
          key == 'generate_bill_time' ||
          key == 'paid_status' ||
          key == 'session_start_time' ||
          key == 'actual_price' ||
          key == 'status' ||
          key == 'bill_no' ||
          key == 'remark' ||
          key == 'timestamp');

      print("PP");
      // Now iterate through the actual items
      items.forEach((itemKey, itemData) {
        if (itemData is Map) {
          print("ITEM $itemKey");
          String itemName = itemKey ?? 'Unknown';
          double price =
              double.tryParse(itemData['price']?.toString() ?? '0') ?? 0;
          int quantity =
              int.tryParse(itemData['quantity']?.toString() ?? '1') ?? 1;

          if (!itemAnalytics.containsKey(itemName)) {
            itemAnalytics[itemName] = {
              'price': price,
              'count': quantity,
              'total': price * quantity,
            };
          } else {
            itemAnalytics[itemName]!['count'] += quantity;
            itemAnalytics[itemName]!['total'] += (price * quantity);
          }
        }
      });
    }

    print("Item Analytics: $itemAnalytics");
  }

  void _calculatePaymentModeAnalytics() {
    paymentModeCount.clear();
    List<Map<String, dynamic>> filteredSettlements =
        _filterByTimeFrame(settlements);

    for (var settlement in filteredSettlements) {
      String paymentMode = settlement['mode_of_payment'] ?? 'Unknown';
      paymentModeCount[paymentMode] = (paymentModeCount[paymentMode] ?? 0) + 1;
    }
  }

  void _calculatePeakHour() {
    hourlyOrderCount.clear();
    List<Map<String, dynamic>> filteredSettlements =
        _filterByTimeFrame(settlements);

    print(
        "Calculating peak hours for ${filteredSettlements.length} settlements");

    for (var settlement in filteredSettlements) {
      try {
        // Try multiple possible time field names
        String? timeString;

        if (settlement.containsKey('settled_time')) {
          timeString = settlement['settled_time'].toString();
        } else if (settlement.containsKey('generate_bill_time')) {
          timeString = settlement['generate_bill_time'].toString();
        } else if (settlement.containsKey('timestamp')) {
          timeString = settlement['timestamp'].toString();
        }

        if (timeString != null) {
          DateTime settleTime = DateTime.parse(timeString);
          int hour = settleTime.hour;
          hourlyOrderCount[hour] = (hourlyOrderCount[hour] ?? 0) + 1;
          print("Added order at hour $hour");
        } else {
          print("No time field found in settlement: ${settlement.keys}");
        }
      } catch (e) {
        print("Error parsing time: $e");
        print("Settlement data: $settlement");
      }
    }

    // Find peak hour
    if (hourlyOrderCount.isNotEmpty) {
      print("Hourly order count: $hourlyOrderCount");
      int maxCount = 0;
      int peakHourValue = 0;

      hourlyOrderCount.forEach((hour, count) {
        if (count > maxCount) {
          maxCount = count;
          peakHourValue = hour;
        }
      });

      // Format with proper AM/PM
      String startTime = _formatHour(peakHourValue);
      String endTime = _formatHour(peakHourValue + 1);
      peakHour = '$startTime - $endTime ($maxCount orders)';

      print("PEAK HOUR: $peakHour");
    } else {
      print("No hourly order data found");
      peakHour = '';
    }
  }

// Helper method to format hour with AM/PM
  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  List<Map<String, dynamic>> _getTopSellingItems() {
    List<Map<String, dynamic>> items = [];
    itemAnalytics.forEach((name, data) {
      items.add({
        'name': name,
        'price': data['price'],
        'count': data['count'],
        'total': data['total'],
      });
    });
    // Sort based on selected criteria
    if (_sortBy == 'price') {
      items.sort((a, b) => b['price'].compareTo(a['price']));
    } else if (_sortBy == 'total') {
      items.sort((a, b) => b['total'].compareTo(a['total']));
    } else {
      // Default: sort by count
      items.sort((a, b) => b['count'].compareTo(a['count']));
    }
    // Return based on selected count
    return items.take(_topItemsCount).toList();
  }

Map<String, dynamic> _filterFoodReviewsByTimeFrame() {
  if (food_reviews.isEmpty) return {};

  final DateTime now = DateTime.now();
  DateTime filterStart = _startDate;
  DateTime filterEnd = _endDate.add(const Duration(days: 1));

  switch (_selectedTimeFrame) {
    case 'today':
      filterStart = DateTime(now.year, now.month, now.day);
      filterEnd = filterStart.add(const Duration(days: 1));
      break;

    case 'this_week':
      filterStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      filterEnd = filterStart.add(const Duration(days: 7));
      break;

    case 'this_month':
      filterStart = DateTime(now.year, now.month, 1);
      filterEnd = DateTime(now.year, now.month + 1, 1);
      break;

    case 'this_year':
      filterStart = DateTime(now.year, 1, 1);
      filterEnd = DateTime(now.year + 1, 1, 1);
      break;

    case 'custom':
      break;
  }

 final Map<String, dynamic> filtered = {};

  food_reviews.forEach((foodName, reviewData) {
    try {
      final String? timestamp = reviewData['review_date_time'];
      if (timestamp == null || timestamp.isEmpty) return;

      final DateTime reviewDate = DateTime.parse(timestamp);

      if (!reviewDate.isBefore(filterStart) &&
          reviewDate.isBefore(filterEnd)) {
        filtered[foodName] = reviewData;
      }
    } catch (e) {
      print("Filter error for $foodName: $e");
    }
  });

  print(filtered);
  print("FIL DATA");
  return filtered;
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: inner_background(),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Sales Analytics',
          style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              color: inner_background(),
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: outer_background(),
        foregroundColor: inner_background(),
        elevation: 0,
        actions: [
          ProfileButton(
              context: context, hotelref: widget.hotel_loc, isTablet: isTablet)
        ],
      ),
      body: _isLoading
          ? CustomLoader(message: 'Loading Analytics...')
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryCard(
                          title: 'Total Sales',
                          value: '₹${totalSales.toStringAsFixed(2)}',
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                        _buildSummaryCard(
                          title: 'Total Orders',
                          value: totalOrders.toString(),
                          icon: Icons.shopping_cart,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Filter Selection
                    Text('Granularity', style: _sectionTitleStyle()),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterButton('Hourly', 'hourly'),
                        _buildFilterButton('Daily', 'daily'),
                        _buildFilterButton('Weekly', 'weekly'),
                        _buildFilterButton('Monthly', 'monthly'),
                        _buildFilterButton('Yearly', 'yearly'),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Time Frame Selection
                    Text('Time Frame', style: _sectionTitleStyle()),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTimeFrameButton('Today', 'today'),
                        _buildTimeFrameButton('This Week', 'this_week'),
                        _buildTimeFrameButton('This Month', 'this_month'),
                        _buildTimeFrameButton('This Year', 'this_year'),
                        _buildTimeFrameButton('Custom', 'custom'),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Custom Date Range
                    if (_selectedTimeFrame == 'custom')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Date Range',
                              style: _sectionTitleStyle()),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDatePickerButton(
                                  'Start: ${DateFormat('MMM d').format(_startDate)}',
                                  () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _startDate,
                                      firstDate: DateTime.now()
                                          .subtract(Duration(days: 365)),
                                      lastDate: _endDate,
                                    );
                                    if (picked != null) {
                                      setState(() => _startDate = picked);
                                      _processDataForChart();
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildDatePickerButton(
                                  'End: ${DateFormat('MMM d').format(_endDate)}',
                                  () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _endDate,
                                      firstDate: _startDate,
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      setState(() => _endDate = picked);
                                      _processDataForChart();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                        ],
                      ),

                    // Chart
                    if (chartData.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sales Chart', style: _sectionTitleStyle()),
                          SizedBox(height: 12),
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                width: _calculateChartWidth(),
                                height: 300,
                                child: _buildBarChart(),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                        ],
                      ),

                    // Detailed List
                    Text('Order Details', style: _sectionTitleStyle()),
                    SizedBox(height: 12),
                    _buildOrderListView(),
                    SizedBox(height: 32),

                    // Peak Hour Section
                    if (peakHour.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Peak Hours', style: _sectionTitleStyle()),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.withOpacity(0.1),
                                  Colors.pink.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.purple.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.purple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.access_time,
                                      color: Colors.white, size: 24),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Peak Hour',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          )),
                                      SizedBox(height: 4),
                                      Text(peakHour,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.purple[800],
                                          )),
                                      SizedBox(height: 8),
                                      Text(
                                          'Suggestion: Increase staff and stock during this time',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32),
                        ],
                      ),

                    // Payment Mode Analytics
                    if (paymentModeCount.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Payment Mode Analysis',
                              style: _sectionTitleStyle()),
                          SizedBox(height: 12),
                          ...paymentModeCount.entries
                              .map((entry) => _buildPaymentModeCard(
                                    paymentMode: entry.key,
                                    count: entry.value,
                                    total: paymentModeCount.values
                                        .reduce((a, b) => a + b),
                                  ))
                              .toList(),
                          SizedBox(height: 32),
                        ],
                      ),

                    // Top Selling Items
                    if (itemAnalytics.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Top Selling Items',
                                  style: _sectionTitleStyle()),
                              SizedBox(width: 10),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      // Sort By Dropdown
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: outer_background(),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: DropdownButton<String>(
                                          value: _sortBy,
                                          underline: SizedBox.shrink(),
                                          isDense: true,
                                          items: [
                                            DropdownMenuItem<String>(
                                              value: 'count',
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: Text('Sort by Count'),
                                              ),
                                            ),
                                            DropdownMenuItem<String>(
                                              value: 'price',
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: Text('Sort by Price'),
                                              ),
                                            ),
                                            DropdownMenuItem<String>(
                                              value: 'total',
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: Text('Sort by Total'),
                                              ),
                                            ),
                                          ].toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() => _sortBy = value);
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // Top Items Count Dropdown
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: outer_background(),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: DropdownButton<int>(
                                          value: _topItemsCount,
                                          underline: SizedBox.shrink(),
                                          isDense: true,
                                          items: [3, 5, 10].map((value) {
                                            return DropdownMenuItem<int>(
                                              value: value,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: Text('Top $value'),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(
                                                  () => _topItemsCount = value);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          ..._getTopSellingItems()
                              .map((item) => _buildItemAnalyticsCard(
                                    itemName: item['name'],
                                    price: item['price'],
                                    count: item['count'],
                                    total: item['total'],
                                  ))
                              .toList(),
                          SizedBox(height: 32),
                        ],
                      ),

                    // Review Data
                    if (food_reviews.length > 0)
                      FoodAnalyticsSection(
                        reviewsData: _filterFoodReviewsByTimeFrame(),
                      ),

                    // Analytics Report Section
                    if (totalOrders > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnalyticsReportActions(
                            report: AnalyticsReport(
                              hotelLoc: widget.hotel_loc,
                              startDate: _startDate,
                              endDate: _endDate,
                              totalSales: totalSales,
                              totalOrders: totalOrders,
                              peakHour: peakHour,
                              paymentModeCount: paymentModeCount,
                              itemAnalytics: itemAnalytics,
                              chartData: chartData,
                              granularity: _selectedFilter,
                              timeFrame: _selectedTimeFrame,
                            ),
                          ),
                          SizedBox(height: 32),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              )),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return ElevatedButton(
      onPressed: () {
        setState(() => _selectedFilter = value);
        _processDataForChart();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? outer_background() : Colors.grey[300],
        foregroundColor: isSelected ? inner_background() : Colors.black,
      ),
      child: Text(label),
    );
  }

  Widget _buildTimeFrameButton(String label, String value) {
    bool isSelected = _selectedTimeFrame == value;
    return ElevatedButton(
      onPressed: () {
        setState(() => _selectedTimeFrame = value);
        _processDataForChart();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? outer_background() : Colors.grey[300],
        foregroundColor: isSelected ? inner_background() : Colors.black,
      ),
      child: Text(label),
    );
  }

  Widget _buildDatePickerButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildBarChart() {
    final entries = chartData.entries.toList();
    if (entries.isEmpty) {
      return Center(
        child: Text('No data available'),
      );
    }

    return BarChart(
      BarChartData(
        maxY: (chartData.values.isEmpty
                ? 0
                : chartData.values.reduce((a, b) => a > b ? a : b)) *
            1.2,
        barGroups: List.generate(
          entries.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entries[index].value,
                color: outer_background(),
                width: 16,
              ),
            ],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < entries.length) {
                  String title = entries[index].key;
                  // Truncate long titles
                  if (title.length > 8) {
                    title = title.substring(0, 8);
                  }
                  return Text(
                    title,
                    style: TextStyle(fontSize: 10),
                  );
                }
                return Text('');
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${value.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 10),
                );
              },
              reservedSize: 50,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderListView() {
    List<Map<String, dynamic>> filteredSettlements =
        _filterByTimeFrame(settlements);

    if (filteredSettlements.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(
          'No orders found',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // Sort settlements by date (most recent first)
    filteredSettlements.sort((a, b) {
      try {
        String? timeStringA;
        String? timeStringB;

        if (a.containsKey('settled_time')) {
          timeStringA = a['settled_time'].toString();
        } else if (a.containsKey('generate_bill_time')) {
          timeStringA = a['generate_bill_time'].toString();
        } else if (a.containsKey('timestamp')) {
          timeStringA = a['timestamp'].toString();
        }

        if (b.containsKey('settled_time')) {
          timeStringB = b['settled_time'].toString();
        } else if (b.containsKey('generate_bill_time')) {
          timeStringB = b['generate_bill_time'].toString();
        } else if (b.containsKey('timestamp')) {
          timeStringB = b['timestamp'].toString();
        }

        if (timeStringA != null && timeStringB != null) {
          DateTime dateA = DateTime.parse(timeStringA);
          DateTime dateB = DateTime.parse(timeStringB);
          return dateB.compareTo(dateA); // Most recent first
        }
        return 0;
      } catch (e) {
        return 0;
      }
    });

    // Number of recent orders to show by default
    const int recentOrdersCount = 5;
    final bool hasMoreOrders = filteredSettlements.length > recentOrdersCount;
    final List<Map<String, dynamic>> ordersToShow = _showAllOrders
        ? filteredSettlements
        : filteredSettlements.take(recentOrdersCount).toList();

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: ordersToShow.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey[300],
          ),
          itemBuilder: (context, index) {
            final settlement = ordersToShow[index];
            DateTime settleDate;
            try {
              String? timeString;
              if (settlement.containsKey('settled_time')) {
                timeString = settlement['settled_time'].toString();
              } else if (settlement.containsKey('generate_bill_time')) {
                timeString = settlement['generate_bill_time'].toString();
              } else if (settlement.containsKey('timestamp')) {
                timeString = settlement['timestamp'].toString();
              }
              settleDate = timeString != null
                  ? DateTime.parse(timeString)
                  : DateTime.now();
            } catch (e) {
              settleDate = DateTime.now();
            }

            String date = DateFormat('MMM d, yyyy').format(settleDate);
            String time = DateFormat('HH:mm:ss').format(settleDate);
            double amount = double.tryParse(
                    settlement['discount_amount']?.toString() ?? '0') ??
                0;

            return InkWell(
              onTap: () {
                _showOrderDetailsModal(context, settlement);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: outer_background().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: outer_background(),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),

                    // Details - Expandable
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Table number and Amount in one line
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                settlement['table_option'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '₹${amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: outer_background(),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),

                          // Date and Time separated
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 12, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 16),
                              Icon(Icons.access_time,
                                  size: 12, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text(
                                time,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Expand/Collapse button
        if (hasMoreOrders)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _showAllOrders = !_showAllOrders;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: outer_background().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: outer_background().withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _showAllOrders
                          ? 'Show Less'
                          : 'Show ${filteredSettlements.length - recentOrdersCount} More Orders',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: outer_background(),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      _showAllOrders ? Icons.expand_less : Icons.expand_more,
                      color: outer_background(),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showOrderDetailsModal(
      BuildContext context, Map<String, dynamic> settlement) {
    // Extract items from settlement
    Map<String, dynamic> items = Map.from(settlement);
    items.removeWhere((key, value) =>
        key == 'table_option' ||
        key == 'settled_time' ||
        key == 'discount_amount' ||
        key == 'mode_of_payment' ||
        key == 'email' ||
        key == 'mg_name' ||
        key == 'generate_bill_time' ||
        key == 'paid_status' ||
        key == 'session_start_time' ||
        key == 'actual_price' ||
        key == 'status' ||
        key == 'bill_no' ||
        key == 'remark' ||
        key == 'timestamp');

    // Convert items to list of maps
    List<Map<String, dynamic>> itemsList = [];
    items.forEach((itemKey, itemData) {
      if (itemData is Map) {
        itemsList.add({
          'name': itemKey,
          'price': double.tryParse(itemData['price']?.toString() ?? '0') ?? 0,
          'quantity':
              int.tryParse(itemData['quantity']?.toString() ?? '1') ?? 1,
        });
      }
    });

    // Get settlement details
    DateTime settleDate;
    try {
      String? timeString;
      if (settlement.containsKey('settled_time')) {
        timeString = settlement['settled_time'].toString();
      } else if (settlement.containsKey('generate_bill_time')) {
        timeString = settlement['generate_bill_time'].toString();
      } else if (settlement.containsKey('timestamp')) {
        timeString = settlement['timestamp'].toString();
      }
      settleDate =
          timeString != null ? DateTime.parse(timeString) : DateTime.now();
    } catch (e) {
      settleDate = DateTime.now();
    }

    String date = DateFormat('MMM d, yyyy').format(settleDate);
    String time = DateFormat('HH:mm:ss').format(settleDate);
    double amount =
        double.tryParse(settlement['discount_amount']?.toString() ?? '0') ?? 0;
    double actualPrice =
        double.tryParse(settlement['actual_price']?.toString() ?? '0') ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Info Card
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: outer_background().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: outer_background().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Table: ${settlement['table_option'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: outer_background(),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '₹${amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          _buildInfoRow(Icons.calendar_today, 'Date', date),
                          SizedBox(height: 8),
                          _buildInfoRow(Icons.access_time, 'Time', time),
                          SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.payment,
                            'Payment Mode',
                            settlement['mode_of_payment'] ?? 'N/A',
                          ),
                          if (settlement['bill_no'] != null) ...[
                            SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.receipt,
                              'Bill No',
                              settlement['bill_no'].toString(),
                            ),
                          ],
                          if (actualPrice > 0 && actualPrice != amount) ...[
                            SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.price_check,
                              'Actual Price',
                              '₹${actualPrice.toStringAsFixed(2)}',
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Items List
                    Text(
                      'Order Items (${itemsList.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (itemsList.isEmpty)
                      Container(
                        padding: EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: Text(
                          'No items found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      ...itemsList.map((item) => Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? 'Unknown Item',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Qty: ${item['quantity']} × ₹${item['price'].toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${((item['price'] as double) * (item['quantity'] as int)).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: outer_background(),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    SizedBox(height: 24),
                    // Summary
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue[200]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Items:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                itemsList
                                    .fold<int>(
                                        0,
                                        (sum, item) =>
                                            sum + (item['quantity'] as int))
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Divider(height: 1),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '₹${amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: outer_background(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  TextStyle _sectionTitleStyle() {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
  }

  Widget _buildPaymentModeCard({
    required String paymentMode,
    required int count,
    required int total,
  }) {
    double percentage = (count / total) * 100;
    Color getModeColor(String mode) {
      if (mode.toLowerCase().contains('cash')) return Colors.green;
      if (mode.toLowerCase().contains('card')) return Colors.blue;
      if (mode.toLowerCase().contains('upi') ||
          mode.toLowerCase().contains('gpay')) return Colors.orange;
      return Colors.grey;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: getModeColor(paymentMode).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: getModeColor(paymentMode).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(paymentMode,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: getModeColor(paymentMode),
                  )),
              Text('$count orders',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  )),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: getModeColor(paymentMode).withOpacity(0.2),
              valueColor:
                  AlwaysStoppedAnimation<Color>(getModeColor(paymentMode)),
            ),
          ),
          SizedBox(height: 4),
          Text('${percentage.toStringAsFixed(1)}% of transactions',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              )),
        ],
      ),
    );
  }

  Widget _buildItemAnalyticsCard({
    required String itemName,
    required double price,
    required int count,
    required double total,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.teal.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(itemName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    )),
              ),
              SizedBox(width: 8),
              Text('₹${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  )),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Orders: $count',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  )),
              Text('Total: ₹${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[700],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateChartWidth() {
    // Minimum width to avoid label merging: 80 pixels per bar + 50 for padding
    int dataPoints = chartData.length;
    double minWidth = dataPoints * 80 + 100;

    // Get screen width
    double screenWidth =
        MediaQuery.of(context).size.width - 32; // minus padding

    // Return the maximum of calculated width or screen width
    return minWidth > screenWidth ? minWidth : screenWidth;
  }
}
