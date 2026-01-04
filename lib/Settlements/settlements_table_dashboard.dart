import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orderease/Admin/admin_dashboard.dart';
import 'package:orderease/Manager/confirm_order_dashboard.dart';
import 'package:orderease/Manager/manager_dashboard.dart';
import 'package:orderease/Settlements/cleared_settlements.dart';
import 'package:orderease/Settlements/settlements_view.dart';
import 'package:orderease/util_components/profile.dart';
import 'package:orderease/util_components/util.dart';

class SettlementsPage extends StatefulWidget {
  final String href;
  final String role;
  const SettlementsPage({required this.href, required this.role});

  @override
  _SettlementsPageState createState() => _SettlementsPageState();
}

class _SettlementsPageState extends State<SettlementsPage> {
  List<Map<String, dynamic>> menuItems = [];

  late int no_of_tables;
  bool _isLoading = true;
  Set<String> pendingTableNumbers = {}; // Track pending table numbers
  Map<String, int> pendingCountPerTable =
      {}; // Track count of pending transactions per table
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
      // table_status_map = data['table_status'];
    }

    // Fetch pending table numbers from Transactions collection
    await _fetchPendingTableNumbers(hotel_loc);

    setState(() {
      menuItems = List.generate(no_of_tables, (index) {
        return {
          'title': (index + 1).toString(),
          'icon': Icons.table_bar, // Icon remains the same for all
        };
      });
      _isLoading = false;
    });
  }

  Future<void> _fetchPendingTableNumbers(String hotel_loc) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(hotel_loc)
          .collection("Transactions")
          .where('status', isEqualTo: 'Pending')
          .get();

      print("Found ${querySnapshot.docs.length} pending transactions"); // Debug

      Map<String, int> countPerTable = {};
      for (var doc in querySnapshot.docs) {
        String tableOption = doc['table_option'].toString();
        String baseTable = tableOption.replaceAll(RegExp(r'[A-Z]$'), '');
        countPerTable[baseTable] = (countPerTable[baseTable] ?? 0) + 1;
      }

      print("Pending count per table: $countPerTable"); // Debug

      setState(() {
        pendingTableNumbers = querySnapshot.docs
            .map((doc) => doc['table_option'].toString())
            .toSet();
        pendingCountPerTable = countPerTable;
      });
    } catch (e) {
      print("Error fetching pending tables: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetch_tables(widget.href);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;
    return PopScope(
        canPop: (widget.role != "Admin") ? false : true, // prevents default pop
        onPopInvokedWithResult: (didPop, result) async {
          // If user tries to exit (back button)
          print(widget.role);
          print("POP");
          if (widget.role != "Admin") {
            bool exitApp = await showExitDialog(context);

            if (exitApp) {
              SystemNavigator.pop(); // close app
            }
          }
        },
        child: Scaffold(
            backgroundColor: inner_background(),
            appBar: AppBar(
              leading: widget.role == "Admin"
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: inner_background(),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  : null,
              centerTitle: widget.role == "Admin" ? true : false,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.role == "Cashier") ...[
                    Icon(Icons.payments, size: 24, color: inner_background()),
                    SizedBox(width: 8)
                  ],
                  Text(
                    "Settlements", // Replace with your text
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.w600,
                      color: inner_background(),
                    ),
                  ),
                ],
              ),
              backgroundColor: outer_background(),
              automaticallyImplyLeading: false,
              elevation: 0,
              actions: [
                ProfileButton(
                    context: context, hotelref: widget.href, isTablet: isTablet)
              ],
            ),

            // Scrollable & Centered Content
            body: _isLoading
                ? CustomLoader(message: 'Loading tables...')
                : Stack(
                    children: [
                      RefreshIndicator(
                        color: outer_background(),
                        onRefresh: () => fetch_tables(widget.href),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      // Welcome Section with Icon
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              outer_background(),
                                              outer_background()
                                                  .withOpacity(0.8),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: outer_background()
                                                  .withOpacity(0.3),
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
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(Icons.restaurant_menu,
                                                  size: 28,
                                                  color: outer_background()),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Welcome, ${widget.role} 👋',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
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

                                      Text(
                                        'Select a Table to settle Orders',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700]),
                                      ),
                                      (no_of_tables == 0)
                                          ? SizedBox(height: 40)
                                          : SizedBox(height: 20),

                                      // ⭐ Your grid as it is
                                      no_of_tables == 0
                                          ? Center(
                                              child: Text(
                                                "No Tables Added, please add tables.",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : LayoutBuilder(
                                              builder: (context, constraints) {
                                                int crossAxisCount =
                                                    constraints.maxWidth > 600
                                                        ? 5
                                                        : 3;

                                                return GridView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount:
                                                              crossAxisCount,
                                                          crossAxisSpacing: 12,
                                                          mainAxisSpacing: 12,
                                                          childAspectRatio:
                                                              crossAxisCount ==
                                                                      3
                                                                  ? 1.1
                                                                  : 1.3),
                                                  itemCount: no_of_tables,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return _buildDashboardButton(
                                                      menuItems[index]['title'],
                                                      menuItems[index]['icon'],
                                                      context,
                                                    );
                                                  },
                                                );
                                              },
                                            ),

                                      SizedBox(height: 50),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Completed_Settlements_Dashboard(
                                                      hotel_loc: widget.href,
                                                      table_option: "all"),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: outer_background(),
                                          foregroundColor: inner_background(),
                                        ),
                                        child: Text(
                                          "Settled Transactions",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ✖ FAB at bottom-right - Fixed position
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: PendingBell(
                          pending_tables: pendingTableNumbers.toList(),
                          pendingCount: pendingCountPerTable.values
                              .fold(0, (sum, count) => sum + count),
                          onTap: () => showPendingBottomSheet(
                              context, pendingTableNumbers.toList()),
                        ),
                      )
                    ],
                  )));
  }

  void showPendingBottomSheet(BuildContext context, List pending_tables) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 40), // space for the X button
              padding: EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      padding: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Text("Pending Settlements",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  (pending_tables.length == 0)
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "🧾 No active bill found — it may be not generated yet or already settled.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                height: 1.4,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0.5, 0.5),
                                    blurRadius: 1,
                                    color: Colors.black12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: pending_tables.length,
                            itemBuilder: (context, index) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  title: Text("${pending_tables[index]}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
            // ✖ FLOATING CLOSE BUTTON
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashboardButton(
      String table, IconData icon, BuildContext context) {
    final pendingCount = pendingCountPerTable['Table $table'] ?? 0;
    final hasPending = pendingCount > 0;

    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _showPopupMenu(context, details.globalPosition, table);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, size: 36, color: outer_background()),
                  SizedBox(height: 10),
                  Text(
                    table,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            // Orange badge with pending count - positioned on container corner
            if (hasPending)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$pendingCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
        final isPending = pendingTableNumbers.contains(option);
        print(pendingTableNumbers);
        print("Pen");
        return PopupMenuItem<String>(
          value: option,
          child: Container(
            color:
                isPending ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
            child: Row(
              children: [
                if (isPending)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.warning, color: Colors.orange, size: 16),
                  ),
                Text(
                  option,
                  style: TextStyle(
                    fontWeight: isPending ? FontWeight.bold : FontWeight.normal,
                    color: isPending ? Colors.orange : Colors.black,
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
              builder: (context) => SettlementsView(
                    table_option: selectedValue,
                    href: widget.href,
                  )));
    }
  }
}

class PendingBell extends StatefulWidget {
  final int pendingCount;
  final VoidCallback onTap;
  final List pending_tables;

  const PendingBell(
      {super.key,
      required this.pendingCount,
      required this.onTap,
      required this.pending_tables});

  @override
  State<PendingBell> createState() => _PendingBellState();
}

class _PendingBellState extends State<PendingBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _shakeAnimation = Tween<double>(begin: -0.08, end: 0.08)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _shakeAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.notifications, color: Colors.white, size: 30),

              /// Pending count badge
              Positioned(
                right: 6,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${widget.pendingCount}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
