import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:orderease/util_components/util.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter/material.dart';

/// ------------------------------------------------------------
///  Detect Device Type (mobile / tablet / desktop)
/// ------------------------------------------------------------
Future<Map<String, dynamic>> _detectDeviceType() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;

    final width = (PlatformDispatcher.instance.views.first.physicalSize.width /
        PlatformDispatcher.instance.views.first.devicePixelRatio);
    final model = android.model;

    return width >= 600
        ? {"deviceType": "tablet", "model": model}
        : {"deviceType": "mobile", "model": model};
  }

  if (Platform.isIOS) {
    final ios = await deviceInfo.iosInfo;
    return ios.name!.toLowerCase().contains("ipad")
        ? {"deviceType": "tablet", "model": ""}
        : {"deviceType": "tablet", "model": ""};
  }

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    return {"deviceType": "desktop", "model": ""};
  }

  return {"deviceType": "unknown", "model": ""};
}

Future<Map<String, dynamic>> getUserName(String email, String hotel_id) async {
  DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
      .collection("Hotels")
      .doc(hotel_id)
      .collection("Users")
      .doc(email)
      .get();

  if (documentSnapshot.exists) {
    final data = documentSnapshot.data() as Map<String, dynamic>;
    return {
      "name": data['name'] ?? data['admin_name'],
      "role": data['role'] ?? ""
    };
  }
  return {"name": "", "role": ""};
}

Future<bool> addLogEntry({
  required String hotelId,
  required String userEmail,
  required String action,
  required String tableNumber, // optional
  required String sessionId,
}) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Create date id: yyyy-mm-dd
  final DateTime now = DateTime.now();
  final String dateId =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  // Detect device type + platform + model
  final deviceInfo = await _detectDeviceType();

  // Extract model
  String model = deviceInfo['model'];

  // Getting userName from DB.
  Map userData = await getUserName(userEmail, hotelId);

  print("deviceinfo $deviceInfo");

  final Map<String, dynamic> activity = {
    "logId": "${now.microsecondsSinceEpoch}", // unique per action
    "email": userEmail,
    "name": userData['name'],
    "role": userData['role'],
    "action": action,
    "tableNumber": tableNumber,
    "timestamp": now.toIso8601String(),
    "sessionId": sessionId,
    "model": model
  };

  print("Activity");
  print(activity);

  // Reference to the daily log document
  final DocumentReference dailyLogRef = firestore
      .collection("Hotels")
      .doc(hotelId)
      .collection("Logs")
      .doc(dateId);

  // Start Firestore transaction
  return await firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(dailyLogRef);

    if (!snapshot.exists) {
      // Create new document for today with first activity
      transaction.set(dailyLogRef, {
        "date": dateId,
        "createdAt": now.toIso8601String(),
        "activities": [activity],
      });
    } else {
      // Append activity to existing list
      transaction.update(dailyLogRef, {
        "activities": FieldValue.arrayUnion([activity]),
      });
    }

    return true; // Transaction result
  });
// return true;
}

// Enhanced UI For Logs with Optimized Firebase Reads
class ActivityLogsScreen extends StatefulWidget {
  final String hotelRef;

  const ActivityLogsScreen({Key? key, required this.hotelRef})
      : super(key: key);

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  // Core data structures

  // Array of maps of Activity
  Map<String, List<Map<String, dynamic>>> groupedLogs = {};
  Map<String, int> displayCounts = {};
  Map<String, bool> dateFullyLoaded = {};

  List<String> availableDates = []; // All dates available in Firebase
  List<String> loadedDates = []; // Dates that have been fetched

  bool isInitialLoading = false;
  bool isLoadingDate = false;
  bool hasCheckedAvailableDates = false;

  final int activitiesPerLoad = 5;

  @override
  void initState() {
    super.initState();
    _initializeWithTodayOnly();
  }

  /// TECHNIQUE 1: Initialize by loading ONLY today's date
  /// This minimizes initial Firebase reads to just 1 document
  Future<void> _initializeWithTodayOnly() async {
    setState(() {
      isInitialLoading = true;
    });

    try {
      // Get today's date in the same format as stored in Firebase
      String today = DateTime.now().toIso8601String().split('T')[0];

      // Fetch ONLY today's document (1 read)
      DocumentSnapshot todayDoc = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.hotelRef)
          .collection('Logs')
          .doc(today)
          .get();

      if (todayDoc.exists) {
        Map<String, dynamic> data = todayDoc.data() as Map<String, dynamic>;
        List<dynamic> activitiesData = data['activities'] ?? [];
        List<Map<String, dynamic>> activities =
            activitiesData.map((e) => Map<String, dynamic>.from(e)).toList();

        groupedLogs[today] = activities;
        loadedDates.add(today);
        displayCounts[today] = activitiesPerLoad;
        dateFullyLoaded[today] = activities.length <= activitiesPerLoad;
      }

      // Don't fetch available dates yet - wait for user to request
      setState(() {
        isInitialLoading = false;
      });
    } catch (e) {
      print('Error fetching today\'s logs: $e');
      setState(() {
        isInitialLoading = false;
      });
    }
  }

  /// TECHNIQUE 2: Lazy load available dates list
  /// Only fetch the list of available dates when user wants to see more
  /// Uses a lightweight query that only fetches document IDs (no activity data)
  Future<void> _fetchAvailableDates() async {
    if (hasCheckedAvailableDates) return;

    try {
      // Fetch all date documents but with limit to get only metadata
      // This is much cheaper than fetching full documents
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.hotelRef)
          .collection('Logs')
          .orderBy('date', descending: true)
          .get();

      availableDates = snapshot.docs.map((doc) => doc.id).toList();
      hasCheckedAvailableDates = true;

      setState(() {});
    } catch (e) {
      print('Error fetching available dates: $e');
    }
  }

  /// TECHNIQUE 3: Load specific date on-demand
  /// Only fetches data when user explicitly requests it
  Future<void> _loadSpecificDate(String date) async {
    // Don't reload if already loaded
    if (loadedDates.contains(date)) return;

    setState(() {
      isLoadingDate = true;
    });

    try {
      // Fetch only the requested date document (1 read per date)
      DocumentSnapshot dateDoc = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.hotelRef)
          .collection('Logs')
          .doc(date)
          .get();

      if (dateDoc.exists) {
        Map<String, dynamic> data = dateDoc.data() as Map<String, dynamic>;
        List<dynamic> activitiesData = data['activities'] ?? [];
        List<Map<String, dynamic>> activities =
            activitiesData.map((e) => Map<String, dynamic>.from(e)).toList();

        groupedLogs[date] = activities;
        loadedDates.add(date);
        displayCounts[date] = activitiesPerLoad;
        dateFullyLoaded[date] = activities.length <= activitiesPerLoad;
      }

      setState(() {
        isLoadingDate = false;
      });
    } catch (e) {
      print('Error loading date $date: $e');
      setState(() {
        isLoadingDate = false;
      });
    }
  }

  /// TECHNIQUE 4: Load date range (e.g., last 7 days, last 30 days)
  /// Efficient batch loading for common use cases
  Future<void> _loadDateRange(int days) async {
    setState(() {
      isLoadingDate = true;
    });

    try {
      DateTime now = DateTime.now();
      List<String> datesToLoad = [];

      // Generate date strings for the range
      for (int i = 0; i < days; i++) {
        String date =
            now.subtract(Duration(days: i)).toIso8601String().split('T')[0];
        if (!loadedDates.contains(date)) {
          datesToLoad.add(date);
        }
      }

      // Fetch all dates in the range in parallel for better performance
      List<Future<DocumentSnapshot>> futures = datesToLoad.map((date) {
        return FirebaseFirestore.instance
            .collection("Hotels")
            .doc(widget.hotelRef)
            .collection('Logs')
            .doc(date)
            .get();
      }).toList();

      List<DocumentSnapshot> snapshots = await Future.wait(futures);

      // Process results
      for (int i = 0; i < snapshots.length; i++) {
        DocumentSnapshot doc = snapshots[i];
        if (doc.exists) {
          String date = datesToLoad[i];
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          List<dynamic> activitiesData = data['activities'] ?? [];
          List<Map<String, dynamic>> activities =
              activitiesData.map((e) => Map<String, dynamic>.from(e)).toList();

          groupedLogs[date] = activities;
          loadedDates.add(date);
          displayCounts[date] = activitiesPerLoad;
          dateFullyLoaded[date] = activities.length <= activitiesPerLoad;
        }
      }

      setState(() {
        isLoadingDate = false;
      });
    } catch (e) {
      print('Error loading date range: $e');
      setState(() {
        isLoadingDate = false;
      });
    }
  }

  void _loadMoreActivitiesForDate(String date) {
    setState(() {
      int currentCount = displayCounts[date] ?? activitiesPerLoad;
      int totalActivities = groupedLogs[date]?.length ?? 0;

      displayCounts[date] = currentCount + activitiesPerLoad;
      dateFullyLoaded[date] = displayCounts[date]! >= totalActivities;
    });
  }

  void _showDatePickerDialog() async {
    // Ensure we have the available dates
    if (!hasCheckedAvailableDates) {
      await _fetchAvailableDates();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Load Previous Dates'),
          content: Container(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quick load options
                    ListTile(
                      leading:
                          Icon(Icons.calendar_today, color: outer_background()),
                      title: Text('Last 7 Days'),
                      subtitle: Text('Load logs from the past week'),
                      onTap: () {
                        Navigator.pop(context);
                        _loadDateRange(7);
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.calendar_month, color: outer_background()),
                      title: Text('Last 30 Days'),
                      subtitle: Text('Load logs from the past month'),
                      onTap: () {
                        Navigator.pop(context);
                        _loadDateRange(30);
                      },
                    ),
                    Divider(),
                    Text(
                      'Or select specific dates:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    // List of available dates
                    Container(
                      constraints: BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableDates.length,
                        itemBuilder: (context, index) {
                          String date = availableDates[index];
                          bool isLoaded = loadedDates.contains(date);

                          return ListTile(
                            leading: Icon(
                              isLoaded
                                  ? Icons.check_circle
                                  : Icons.calendar_today,
                              color: isLoaded ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                            title: Text(_formatDate(date)),
                            trailing: isLoaded
                                ? Text('Loaded',
                                    style: TextStyle(color: Colors.green))
                                : null,
                            onTap: isLoaded
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    _loadSpecificDate(date);
                                  },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: outer_background()),
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Color(0xFF2ECC71);
      case 'Cook':
        return Color(0xFFE67E22);
      case 'Cashier':
        return Color(0xFF9B59B6);
      case 'Manager':
        return Color(0xFF3498DB);
      default:
        return outer_background();
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Admin':
        return Icons.admin_panel_settings;
      case 'Cook':
        return Icons.restaurant;
      case 'Cashier':
        return Icons.point_of_sale;
      case 'Manager':
        return Icons.groups;
      default:
        return Icons.person;
    }
  }

  void _showLogDetails(BuildContext context, Map<String, dynamic> log) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isTablet = screenWidth > 600;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : (screenWidth * 0.9),
              maxHeight: isLandscape ? screenHeight * 0.85 : screenHeight * 0.7,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(isLandscape ? 16.0 : 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getRoleIcon(log['role'] ?? ''),
                          color: outer_background(),
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Activity Details",
                            style: TextStyle(
                              fontSize: isTablet ? 22.0 : 20.0,
                              fontWeight: FontWeight.bold,
                              color: outer_background(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    _buildDetailRow("Action", log['action'] ?? 'N/A',
                        Icons.check_circle, isTablet),
                    _buildDetailRow(
                        "Name", log['name'] ?? 'N/A', Icons.person, isTablet),
                    _buildDetailRow(
                        "Role", log['role'] ?? 'N/A', Icons.work, isTablet),
                    _buildDetailRow(
                        "Email", log['email'] ?? 'N/A', Icons.email, isTablet),
                    if (log['tableNumber'].toString().length > 0)
                      _buildDetailRow(
                          "Table Number",
                          log['tableNumber'] ?? 'N/A',
                          Icons.table_bar,
                          isTablet),
                    _buildDetailRow("Timestamp", log['timestamp'] ?? 'N/A',
                        Icons.access_time, isTablet),
                    _buildDetailRow("Log ID", log['logId'] ?? 'N/A',
                        Icons.fingerprint, isTablet),
                    _buildDetailRow("Device Model", log['model'] ?? 'N/A',
                        Icons.phone_android, isTablet),
                    if (log['sessionId'].toString().length > 0)
                      _buildDetailRow("Session ID", log['sessionId'] ?? 'N/A',
                          Icons.vpn_key, isTablet,
                          isLast: true),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: outer_background(),
                          foregroundColor: inner_background(),
                          padding: EdgeInsets.symmetric(
                              vertical: isLandscape ? 12 : 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Close",
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
      String label, String value, IconData icon, bool isTablet,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: outer_background()),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isTablet = screenWidth > 600;

    // Sort loaded dates in descending order for display
    List<String> sortedDates = List.from(loadedDates)
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: inner_background(),
      appBar: AppBar(
        backgroundColor: outer_background(),
        elevation: 0,
        title: Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            color: inner_background(),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            tooltip: 'Load more dates',
            onPressed: _showDatePickerDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                groupedLogs.clear();
                loadedDates.clear();
                displayCounts.clear();
                dateFullyLoaded.clear();
                availableDates.clear();
                hasCheckedAvailableDates = false;
              });
              _initializeWithTodayOnly();
            },
          ),
        ],
      ),
      body: isInitialLoading
          ? CustomLoader(message: "Loading logs...")
          : Column(
              children: [
                // Info banner showing current state
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: outer_background().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: outer_background().withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: outer_background(),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loadedDates.isEmpty
                              ? 'No logs for today. Tap history icon to load previous dates.'
                              : 'Showing ${loadedDates.length} date(s). Tap history icon to load more.',
                          style: TextStyle(
                            fontSize: 13,
                            color: outer_background(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Loading indicator when fetching a date
                if (isLoadingDate)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                outer_background()),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Loading logs...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: sortedDates.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No activity logs for today',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _showDatePickerDialog,
                                icon: Icon(Icons.calendar_today),
                                label: Text('Load Previous Dates'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: outer_background(),
                                  foregroundColor: inner_background(),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(isLandscape ? 12 : 16),
                          itemCount: sortedDates.length,
                          itemBuilder: (context, index) {
                            String date = sortedDates[index];
                            List<Map<String, dynamic>> activities =
                                groupedLogs[date]!;
                            int displayCount =
                                displayCounts[date] ?? activitiesPerLoad;
                            List<Map<String, dynamic>> displayedActivities =
                                activities.take(displayCount).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Header
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: outer_background(),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        _formatDate(date),
                                        style: TextStyle(
                                          fontSize: isTablet ? 20 : 18,
                                          fontWeight: FontWeight.bold,
                                          color: dark_outer_background(),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '(${activities.length} activities)',
                                        style: TextStyle(
                                          fontSize: isTablet ? 14 : 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          height: 2,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                outer_background(),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Activity Cards
                                ...displayedActivities.map((activity) {
                                  return _buildActivityCard(
                                    activity,
                                    isTablet,
                                    isLandscape,
                                  );
                                }).toList(),

                                // Load More Activities Button
                                if (!(dateFullyLoaded[date] ?? false))
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                      child: TextButton.icon(
                                        onPressed: () =>
                                            _loadMoreActivitiesForDate(date),
                                        icon: Icon(Icons.expand_more),
                                        label: Text(
                                            'Load More (${activities.length - displayCount} remaining)'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: outer_background(),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: sortedDates.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showDatePickerDialog,
              backgroundColor: outer_background(),
              icon: Icon(Icons.add, color: inner_background()),
              label: Text(
                'Load More Dates',
                style: TextStyle(color: inner_background()),
              ),
            )
          : null,
    );
  }

  Widget _buildActivityCard(
    Map<String, dynamic> activity,
    bool isTablet,
    bool isLandscape,
  ) {
    String role = activity['role'] ?? '';
    Color roleColor = _getRoleColor(role);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showLogDetails(context, activity),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isLandscape ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: roleColor,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getRoleIcon(role),
                      color: roleColor,
                      size: isTablet ? 24 : 22,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['action'] ?? 'No action',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: roleColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                role,
                                style: TextStyle(
                                  fontSize: isTablet ? 13 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: roleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Text(
                        activity['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  if (activity['tableNumber'].toString().length > 0) ...[
                    Row(
                      children: [
                        Icon(Icons.table_bar,
                            size: 16, color: Colors.grey[600]),
                        SizedBox(width: 6),
                        Text(
                          activity['tableNumber'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  ],
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Text(
                        _formatTimestamp(activity['timestamp'] ?? ''),
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(Duration(days: 1));
      DateTime compareDate =
          DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (compareDate == today) {
        return 'Today';
      } else if (compareDate == yesterday) {
        return 'Yesterday';
      }

      List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      String period = dateTime.hour >= 12 ? 'PM' : 'AM';
      int hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      if (hour == 0) hour = 12;
      String minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } catch (e) {
      return timestamp;
    }
  }
}
