import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orderease/Admin/admin_dashboard.dart';
import 'package:orderease/Manager/confirm_order_dashboard.dart';
import 'package:orderease/Manager/manager_dashboard.dart';
import 'package:orderease/util_components/profile.dart';
import 'package:orderease/util_components/util.dart';

class ManagerPage extends StatefulWidget {
  final String href;
  const ManagerPage({required this.href});

  @override
  _ManagerPageState createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  List<Map<String, dynamic>> menuItems = [];

  late int no_of_tables;
  bool _isLoading = true;
  Map<String, dynamic> tableStatusMap = {}; // Track table status
  // late Map<String, dynamic> table_status_map = {};

  Future<void> fetch_tables(String hotel_loc) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(hotel_loc)
        .get();
    if (documentSnapshot.exists) {
      var data = documentSnapshot.data() as Map<String, dynamic>;
      print("ASDASDEWR0");
      print(data);
      no_of_tables = (data['no_of_tables'] == null)
          ? 0
          : int.parse(data['no_of_tables'].toString());

      // Fetch table status - Reset and update
      tableStatusMap.clear();
      if (data.containsKey('table_status')) {
        tableStatusMap = Map<String, dynamic>.from(
            data['table_status'] as Map<String, dynamic>);
        print("Table Status Map Updated: $tableStatusMap");
      }
    }
    setState(() {
      menuItems = List.generate(no_of_tables, (index) {
        return {
          'title': (index + 1).toString(),
          'icon': Icons.table_bar,
        };
      });
      _isLoading = false;
    });
  }

  Future<void> fetch(String hotel_loc) async {
    await fetch_tables(hotel_loc);
  }

  @override
  void initState() {
    super.initState();
    fetch(widget.href);
  }

  // Helper function to check if any variant of a base table is blocked
  bool _isAnyVariantBlocked(String baseTableNum) {
    List<String> tablesToCheck = ['Table $baseTableNum'];
    List<String> variants = ['A', 'B', 'C', 'D', 'E', 'F'];

    for (String variant in variants) {
      tablesToCheck.add('Table $baseTableNum$variant');
    }

    for (String tableKey in tablesToCheck) {
      if (tableStatusMap.containsKey(tableKey)) {
        var status = tableStatusMap[tableKey];
        if (status is List && status.length >= 2) {
          if (status[0] == true) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Widget _buildTableStatsRow() {
    int occupiedBaseTables = 0; // Count of BASE tables with ANY variant blocked
    int totalBaseTables = menuItems.length; // Total base tables (12)

    // Debug: Print current table status
    print("Debug - Building Stats Row - TableStatusMap: $tableStatusMap");
    print("Debug - Total Base Tables: $totalBaseTables");

    // Check all base tables
    for (var i = 0; i < totalBaseTables; i++) {
      String baseTableNum = (i + 1).toString();

      // Use helper function to check if ANY variant is blocked
      if (_isAnyVariantBlocked(baseTableNum)) {
        occupiedBaseTables++;
        print("Debug - Base table $baseTableNum has a blocked variant");
      }
    }

    int availableTables = totalBaseTables - occupiedBaseTables;

    print(
        "Debug - Total Base Tables: $totalBaseTables, In Service: $occupiedBaseTables, Available: $availableTables");

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Available',
            '$availableTables',
            Icons.check_circle,
            Color(0xFF4CAF50),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'In Service',
            '$occupiedBaseTables',
            Icons.restaurant,
            Colors.orange,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total',
            '$totalBaseTables',
            Icons.grid_3x3,
            outer_background(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    return PopScope(
        canPop: false, // prevents default pop
        onPopInvokedWithResult: (didPop, result) async {
          // If user tries to exit (back button)
          bool exitApp = await showExitDialog(context);

          if (exitApp) {
            SystemNavigator.pop(); // close app
          }
        },
        child: Scaffold(
          backgroundColor: inner_background(),
          appBar: AppBar(
            title: Row(
              children: [
                Icon(
                  Icons.dashboard_customize,
                  size: isTablet ? 24 : 20,
                  color: inner_background(),
                ),
                SizedBox(width: 8),
                Text(
                  "Table Management", // Replace with your text
                  style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.w600,
                      color: inner_background()),
                ),
              ],
            ),
            backgroundColor: outer_background(),
            automaticallyImplyLeading: false,
            elevation: 2,
            shadowColor: Colors.black26,
            actions: [
              ProfileButton(
                  context: context, hotelref: widget.href, isTablet: isTablet)
            ],
          ),

          // Scrollable & Centered Content
          body: _isLoading
              ? CustomLoader(message: 'Loading tables...')
              : RefreshIndicator(
                  onRefresh: () => fetch_tables(widget.href),
                  color: outer_background(),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            inner_background(),
                            inner_background().withOpacity(0.95),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Section with Icon
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    outer_background(),
                                    outer_background().withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: outer_background().withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: inner_background(),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.restaurant_menu,
                                        size: 28, color: outer_background()),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome, Captain 👋',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: inner_background(),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Manage your tables efficiently',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: inner_background()
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 32),

                            // Table Status Stats
                            _buildTableStatsRow(),
                            SizedBox(height: 24),

                            // Tables Heading
                            Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Text(
                                'Available Tables',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            (no_of_tables == 0) ? SizedBox(height: 40,): SizedBox(height: 16),

                            // Grid
                            no_of_tables == 0
                                ? Center(
                                    child: Text(
                                      "No Tables Added, please contact Admin.",
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      int crossAxisCount =
                                          constraints.maxWidth > 600 ? 6 : 3;
                                      double childAspectRatio =
                                          crossAxisCount == 6 ? 1 : 0.85;

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: childAspectRatio,
                                        ),
                                        itemCount: no_of_tables,
                                        itemBuilder: (context, index) {
                                          return _buildDashboardButton(
                                            menuItems[index]['title'],
                                            menuItems[index]['icon'],
                                            context,
                                          );
                                        },
                                      );
                                    },
                                  ),
                            SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ));
  }

  Widget _buildDashboardButton(
      String table, IconData icon, BuildContext context) {
    String tableKey = 'Table $table';

    // Check if any variant of this table is occupied/in use
    bool isTableInUse = _isAnyVariantBlocked(table);

    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _showPopupMenu(context, details.globalPosition, table);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isTableInUse
                ? [
                    Colors.orange.withOpacity(0.12),
                    Colors.orange.withOpacity(0.06),
                  ]
                : [
                    Colors.white,
                    Colors.blue.withOpacity(0.03),
                  ],
          ),
          border: isTableInUse
              ? Border.all(
                  color: Colors.orange,
                  width: 2.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                )
              : Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1.5,
                ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isTableInUse
                  ? Colors.orange.withOpacity(0.25)
                  : Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
            if (!isTableInUse)
              BoxShadow(
                color: Colors.blue.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern - Decorative circle
            Positioned(
              top: -25,
              right: -25,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTableInUse
                      ? Colors.orange.withOpacity(0.08)
                      : outer_background().withOpacity(0.04),
                ),
              ),
            ),
            // Main Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Table Icon with Number inside
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isTableInUse
                          ? [
                              Colors.orange.withOpacity(0.25),
                              Colors.orange.withOpacity(0.12),
                            ]
                          : [
                              outer_background().withOpacity(0.12),
                              outer_background().withOpacity(0.06),
                            ],
                    ),
                    border: Border.all(
                      color: isTableInUse
                          ? Colors.orange.withOpacity(0.4)
                          : outer_background().withOpacity(0.25),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isTableInUse
                            ? Colors.orange.withOpacity(0.2)
                            : outer_background().withOpacity(0.1),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Table Icon
                      Icon(
                        Icons.table_restaurant,
                        size: 32,
                        color:
                            isTableInUse ? Colors.orange : outer_background(),
                      ),
                      // Table Number Badge
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isTableInUse
                                ? Colors.orange
                                : outer_background(),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isTableInUse
                                        ? Colors.orange
                                        : outer_background())
                                    .withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              table,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Status Text
                Text(
                  isTableInUse ? 'In Service' : 'Ready',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isTableInUse ? Colors.orange : Colors.grey[700],
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            // Status Badge - Live indicator
            if (isTableInUse)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 2,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
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

  void _showPopupMenu(
      BuildContext context, Offset position, String table) async {
    final tableOptions = [
      'Table ${table}',
      'Table ${table}A',
      'Table ${table}B',
      'Table ${table}C',
      'Table ${table}D',
      'Table ${table}E',
      'Table ${table}F'
    ];

    final selectedValue = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: tableOptions.map((String option) {
        // Check if this table variant is blocked
        bool isBlocked = false;
        if (tableStatusMap.containsKey(option)) {
          var status = tableStatusMap[option];
          if (status is List && status.length >= 2) {
            isBlocked = status[0] == true;
          }
        }

        return PopupMenuItem<String>(
          value: option,
          child: Container(
            color: isBlocked
                ? Colors.orange.withOpacity(0.15)
                : Colors.transparent,
            child: Row(
              children: [
                if (isBlocked)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.info, color: Colors.orange, size: 16),
                  ),
                Text(
                  option,
                  style: TextStyle(
                    fontWeight: isBlocked ? FontWeight.bold : FontWeight.normal,
                    color: isBlocked ? Colors.orange : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      elevation: 8.0,
    );

    if (selectedValue != null) {
      print("Selected: ${widget.href}");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Manager_Prepareorder_Dashboard(
                    table_option: selectedValue,
                    href: widget.href,
                  )));
    }
  }
}
