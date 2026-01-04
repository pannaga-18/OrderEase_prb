import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orderease/Admin/admin_dashboard.dart';
import 'package:orderease/Cook/cook_dashboard.dart';
import 'package:orderease/Manager/considated_bill.dart';
import 'package:orderease/Manager/mg_category_dashboard.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cook_Welcome extends StatefulWidget {
  final String hotel_loc;

  const Cook_Welcome({
    super.key,
    required this.hotel_loc,
  });

  @override
  State<Cook_Welcome> createState() => Cook_Welcome_State();
}

// Map<String, dynamic>? data;
// late Future<void> menu_items;
// bool _isLoading = true;
// bool _isfetched = false;
// Iterable? docids;
// List? d;

class Cook_Welcome_State extends State<Cook_Welcome> {
  // Map<String, Map<String, dynamic>> tableData = {};
  // String globalStoredID = "";

  // Future<Map<String, Map<String, dynamic>>> getTableData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   tableData = {};

  //   // Load the map from SharedPreferences
  //   String? mapJson = prefs.getString('tableData');
  //   if (mapJson != null) {
  //     Map<String, dynamic> decodedData = jsonDecode(mapJson);

  //     // NOTE
  //     // MAP ENTRY IS A CONSTRUCTOR providing key and value as the OUTPUT
  //     // .from method helps to retain the value as MAP itself instead of object.

  //     tableData = decodedData.map((key, value) => MapEntry(
  //           key,
  //           Map<String, dynamic>.from(value),
  //         ));
  //   }

  //   // Load status and UID from SharedPreferences
  //   bool? storedStatus = prefs.getBool("isBlocked_${widget.table_option}");
  //   String? uid = prefs.getString("uid_${widget.table_option}");
  //   print("LOADED MAP DATA");
  //   print(tableData);

  //   return tableData;
  // }

  // Map<String, dynamic> localSessionItems = {};
  // String subtotal = "0.0";
  // int itemsLength = 0;

  // Future<void> fetch_menu_data_locally() async {
  //   subtotal = "0.0";
  //   d = [];
  //   localSessionItems = {};

  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection("Hotels")
  //       .doc(widget.hotel_loc)
  //       .collection("Bill")
  //       .get();

  //   print("SNAP");
  //   print(querySnapshot.size);

  //   if (querySnapshot.size != 0) {
  //     for (var doc in querySnapshot.docs) {
  //       if (doc.id.split("_")[1] == widget.table_option) {
  //         globalStoredID = doc.id;
  //         break;
  //       }
  //     }
  //     print("GID");
  //     print(globalStoredID);
  //     if (globalStoredID != '') {
  //       print("PPPP");
  //       DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //           .collection("Hotels")
  //           .doc(widget.hotel_loc)
  //           .collection("Bill")
  //           .doc(globalStoredID)
  //           .get();

  //       if (documentSnapshot.exists) {
  //         localSessionItems = documentSnapshot.data() as Map<String, dynamic>;

  //         localSessionItems = Map.fromEntries(localSessionItems.entries.where(
  //             (entry) =>
  //                 entry.key != "status" &&
  //                 entry.key != "timestamp" &&
  //                 entry.key != "email"));

  //         print(localSessionItems);
  //         print("FFF1");

  //         var sortedEntries = localSessionItems.entries.toList()
  //           ..sort((a, b) => (a.key).compareTo(b.key));

  //         localSessionItems = {
  //           for (var entry in sortedEntries) entry.key: entry.value
  //         } as Map<String, dynamic>;

  //         d = localSessionItems.keys.toList();

  //         itemsLength = 0;
  //         for (var key in localSessionItems.keys) {
  //           var item = localSessionItems[key];

  //           subtotal = (double.parse(subtotal) +
  //                   (double.parse(item['price']) *
  //                       double.parse(item['quantity'])))
  //               .toString();
  //           itemsLength += int.parse(item['quantity']);
  //         }

  //         print("FFF2");
  //         print(d);
  //         print(localSessionItems);
  //       }
  //     } else {
  //       print("Invalid GID");
  //       print(localSessionItems);
  //       print(d);
  //     }
  //     setState(() {
  //       d = d;
  //       _isLoading = false;
  //       _isfetched = true;
  //       localSessionItems = localSessionItems;
  //       subtotal = subtotal;
  //       itemsLength = itemsLength;
  //     });
  //   }
  // }

  // void initState() {
  //   super.initState();
  //   print("inside menu");

  //   menu_items = fetch_menu_data_locally();
  //   print(menu_items);
  // }

  @override
  Widget build(BuildContext context) {
    // Refreshing the page
    Future<void> refreshPage() async {
      // setState(() {
      //   menu_items = fetch_menu_data_locally();
      // });
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;
    final horizontalPadding = isTablet ? 48.0 : 24.0;
    final maxWidth = isTablet ? 1000.0 : double.infinity;

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
          backgroundColor: inner_background(), // Light blue background
          appBar: AppBar(
            backgroundColor: outer_background(),
            elevation: 0,
            title: Row(
              children: [
                Icon(Icons.restaurant_menu,
                    color: Colors.white, size: isTablet ? 28 : 24),
                SizedBox(width: 12),
                Text(
                  "Welcome Cook!!",
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            automaticallyImplyLeading: false,
            actions: [
              ProfileButton(
                  context: context,
                  hotelref: widget.hotel_loc,
                  isTablet: isTablet),
            ],
          ),
          body: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: isLandscape
                  ? _buildLandscapeLayout(context, horizontalPadding, isTablet,
                      screenWidth, screenHeight)
                  : _buildPortraitLayout(context, horizontalPadding, isTablet,
                      screenWidth, screenHeight),
            ),
          ),
        ));
  }

// Portrait Layout
  Widget _buildPortraitLayout(
    BuildContext context,
    double horizontalPadding,
    bool isTablet,
    double screenWidth,
    double screenHeight,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Welcome Header Card
          Container(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  outer_background(),
                  outer_background().withOpacity(0.85)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restaurant,
                    size: isTablet ? 56 : 48,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Welcome to the Kitchen!",
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Ready to cook up something amazing?",
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.white.withOpacity(0.95),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 32),

          // Chef Image Card
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: isTablet ? 450 : 350,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    "https://firebasestorage.googleapis.com/v0/b/orderease-39f46.appspot.com/o/hotel_logos%2Fcook.png?alt=media&token=b7e95f28-2831-4019-a106-1fea22377efd",
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: outer_background(),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Image not available',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32),

          // Features Grid
          _buildFeaturesGrid(isTablet, isLandscape: false),
          SizedBox(height: 32),

          // Get Started Button
          SizedBox(
            width: double.infinity,
            height: isTablet ? 64 : 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: outer_background(),
                foregroundColor: inner_background(),
                elevation: 4,
                shadowColor: outer_background().withOpacity(0.4),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cook_Dashboard(
                      href: widget.hotel_loc,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: isTablet ? 28 : 24),
                  SizedBox(width: 12),
                  Text(
                    "Get Started",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 18 : 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

// Landscape Layout
  Widget _buildLandscapeLayout(
    BuildContext context,
    double horizontalPadding,
    bool isTablet,
    double screenWidth,
    double screenHeight,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      child: Column(
        children: [
          // Main Content Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side - Image
              Expanded(
                flex: 5,
                child: Container(
                  height: screenHeight * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          "https://firebasestorage.googleapis.com/v0/b/orderease-39f46.appspot.com/o/hotel_logos%2Fcook.png?alt=media&token=b7e95f28-2831-4019-a106-1fea22377efd",
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: outer_background(),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.broken_image,
                                  size: 64, color: Colors.grey),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 32),

              // Right Side - Content
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Welcome Header
                    Container(
                      padding: EdgeInsets.all(isTablet ? 28 : 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            outer_background(),
                            outer_background().withOpacity(0.85)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.restaurant,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Welcome Chef!",
                                      style: TextStyle(
                                        fontSize: isTablet ? 26 : 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Let's prepare amazing dishes",
                                      style: TextStyle(
                                        fontSize: isTablet ? 14 : 13,
                                        color: Colors.white.withOpacity(0.95),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 60),

                    // Features
                    // _buildFeaturesGrid(isTablet, isLandscape: true),
                    // SizedBox(height: 24),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: outer_background(),
                          foregroundColor: inner_background(),
                          elevation: 4,
                          shadowColor: outer_background().withOpacity(0.4),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Cook_Dashboard(
                                href: widget.hotel_loc,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow, size: 24),
                            SizedBox(width: 12),
                            Text(
                              "Get Started",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Features Grid Widget - Fully Responsive
  Widget _buildFeaturesGrid(bool isTablet, {bool isLandscape = false}) {
    final features = [
      {
        'icon': Icons.notifications_active,
        'title': 'Live Orders',
        'description': 'Real-time notifications',
        'color': Colors.orange,
      },
      {
        'icon': Icons.timer,
        'title': 'Quick Access',
        'description': 'Fast order management',
        'color': Colors.blue,
      },
      {
        'icon': Icons.check_circle,
        'title': 'Easy Updates',
        'description': 'Mark orders complete',
        'color': Colors.green,
      },
      {
        'icon': Icons.trending_up,
        'title': 'Track Progress',
        'description': 'Monitor your workflow',
        'color': Colors.purple,
      },
    ];

    // Calculate cross axis count based on device and orientation
    int getCrossAxisCount() {
      if (isLandscape) {
        return isTablet ? 1 : 2;
      } else {
        return 1;
      }
    }

    // Calculate aspect ratio based on device and orientation
    double getAspectRatio() {
      if (isLandscape) {
        return isTablet ? 4 : 1.5;
      } else {
        return isTablet ? 2.5 : 4;
      }
    }

    // Check if we should use column layout
    bool useColumnLayout = isLandscape && isTablet && getCrossAxisCount() == 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(),
        crossAxisSpacing: isTablet ? 20 : 16,
        mainAxisSpacing: isTablet ? 20 : 16,
        childAspectRatio: getAspectRatio(),
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          feature: feature,
          isTablet: isTablet,
          useColumnLayout: useColumnLayout,
        );
      },
    );
  }

// Individual Feature Card Widget
  Widget _buildFeatureCard({
    required Map<String, dynamic> feature,
    required bool isTablet,
    required bool useColumnLayout,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: (feature['color'] as Color).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: useColumnLayout
          ? _buildColumnLayout(feature, isTablet)
          : _buildRowLayout(feature, isTablet),
    );
  }

// Row Layout (for portrait and mobile landscape)
  Widget _buildRowLayout(Map<String, dynamic> feature, bool isTablet) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 10),
          decoration: BoxDecoration(
            color: (feature['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            feature['icon'] as IconData,
            color: feature['color'] as Color,
            size: isTablet ? 28 : 24,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                feature['title'] as String,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                feature['description'] as String,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

// Column Layout (for tablet landscape with 4 columns)
  Widget _buildColumnLayout(Map<String, dynamic> feature, bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (feature['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            feature['icon'] as IconData,
            color: feature['color'] as Color,
            size: 32,
          ),
        ),
        SizedBox(height: 12),
        Text(
          feature['title'] as String,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Text(
          feature['description'] as String,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

Widget buildStatusWithQuantity(
    String label, String quantity, Color bgColor, Color textColor) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        Text(
          "$quantity",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}
