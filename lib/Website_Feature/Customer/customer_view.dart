import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderease/util_components/util.dart';

class CustomerFoodStatusScreen extends StatefulWidget {
  final String hotelId;
  final String tableId;

  const CustomerFoodStatusScreen({
    Key? key,
    required this.hotelId,
    required this.tableId,
  }) : super(key: key);

  @override
  State<CustomerFoodStatusScreen> createState() =>
      _CustomerFoodStatusScreenState();
}

class _CustomerFoodStatusScreenState extends State<CustomerFoodStatusScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic> localSessionItems = {};
  List<String> foodItems = [];
  bool _isLoading = true;
  String globalStoredID = "";
  Timer? _refreshTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fetchFoodStatus();

    // Auto-refresh every 10 seconds
    // _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
    //   _fetchFoodStatus();
    // });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchFoodStatus() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.hotelId)
          .collection("Bill")
          .get();

      if (querySnapshot.size != 0) {
        for (var doc in querySnapshot.docs) {
          if (doc.id.split("_")[1] == widget.tableId) {
            globalStoredID = doc.id;
            break;
          }
        }

        if (globalStoredID != '') {
          DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
              .collection("Hotels")
              .doc(widget.hotelId)
              .collection("Bill")
              .doc(globalStoredID)
              .get();

          if (documentSnapshot.exists) {
            Map<String, dynamic> data =
                documentSnapshot.data() as Map<String, dynamic>;

            localSessionItems = Map.fromEntries(data.entries.where((entry) =>
                entry.key != "status" &&
                entry.key != "timestamp" &&
                entry.key != "email" &&
                entry.key != "mg_name"));

            // Sort by preparing quantity
            var sortedEntries = localSessionItems.entries.toList()
              ..sort((a, b) => (int.parse(b.value['preparing'].toString()))
                  .compareTo(int.parse(a.value['preparing'].toString())));

            localSessionItems = {
              for (var entry in sortedEntries) entry.key: entry.value
            };

            foodItems = localSessionItems.keys.toList();
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching food status: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeTablet = screenWidth > 900;
    final isWeb = screenWidth > 1200;
    final imagePath = "assets/images/cook_icon_sgs.png";

    double getResponsiveFontSize(double mobile, double tablet, double large) {
      if (isWeb) return large;
      if (isLargeTablet) return large;
      if (isTablet) return tablet;
      return mobile;
    }

    double getResponsivePadding(double mobile, double tablet) {
      return isTablet ? tablet : mobile;
    }

    return Scaffold(
        backgroundColor: inner_background(),
        appBar: AppBar(
          backgroundColor: outer_background(),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: isTablet ? 28.0 : 24.0,
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(imagePath),
                radius: isTablet ? 24.0 : 18.0,
              ),
              SizedBox(width: 12.0),
              Text(
                "Your Order Status",
                style: TextStyle(
                  fontSize: getResponsiveFontSize(20.0, 24.0, 28.0),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _fetchFoodStatus();
              },
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
                size: isTablet ? 28.0 : 24.0,
              ),
              tooltip: 'Refresh',
            ),
            SizedBox(width: 8.0),
          ],
        ),
        body: _isLoading
            ? CustomLoader(message: "Loading your order...")
            : foodItems.isEmpty
                ? _buildEmptyState(
                    isTablet, getResponsiveFontSize, getResponsivePadding)
                : RefreshIndicator(
                    color: outer_background(),
                    onRefresh: _fetchFoodStatus,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Center(child:Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                color: Colors.black87,
                                size: isTablet ? 28.0 : 24.0,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.tableId,
                                style: TextStyle(
                                  fontSize:
                                      getResponsiveFontSize(20.0, 24.0, 28.0),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),),
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isWeb ? 1200 : double.infinity,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: getResponsivePadding(16.0, 24.0),
                                vertical: getResponsivePadding(20.0, 24.0),
                              ),
                              itemCount: foodItems.length,
                              itemBuilder: (context, index) {
                                final foodName = foodItems[index];
                                final foodData = localSessionItems[foodName];

                                return buildFoodItemCard(
                                  foodName: foodName,
                                  foodData: foodData,
                                  pulseAnimation: _pulseAnimation,
                                  getResponsiveFontSize: getResponsiveFontSize,
                                  getResponsivePadding: getResponsivePadding,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
  }

  Widget _buildEmptyState(
    bool isTablet,
    Function getResponsiveFontSize,
    Function getResponsivePadding,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(getResponsivePadding(24.0, 48.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(getResponsivePadding(32.0, 40.0)),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_outlined,
                size: isTablet ? 120.0 : 100.0,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: getResponsivePadding(32.0, 40.0)),
            Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: getResponsiveFontSize(28.0, 32.0, 36.0),
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: getResponsivePadding(12.0, 16.0)),
            Text(
              'Your order will appear here once placed',
              style: TextStyle(
                fontSize: getResponsiveFontSize(16.0, 18.0, 20.0),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFoodItemCard({
    required String foodName,
    required Map<String, dynamic> foodData,
    required Animation<double> pulseAnimation,
    required double Function(double, double) getResponsivePadding,
    required double Function(double, double, double) getResponsiveFontSize,
  }) {
    final int ordered = int.parse(foodData['quantity']?.toString() ?? '0');
    final int preparing = int.parse(foodData['preparing']?.toString() ?? '0');
    final int prepared = int.parse(foodData['prepared']?.toString() ?? '0');
    final int cancelled = int.parse(foodData['cancelled']?.toString() ?? '0');

    final double progress = ordered > 0 ? prepared / ordered : 0.0;

    String currentStatus = 'Ordered';
    Color statusColor = Colors.blue;
    IconData statusIcon = Icons.receipt_long;

    if (prepared == ordered && ordered > 0) {
      currentStatus = 'Ready to Serve!';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (preparing > 0) {
      currentStatus = 'Cooking...';
      statusColor = Colors.orange;
      statusIcon = Icons.restaurant;
    } else if (cancelled > 0 && prepared == 0 && preparing == 0) {
      currentStatus = 'Cancelled';
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isMobile = width < 600;
        final bool isTablet = width >= 600 && width < 1024;
        final bool isWeb = width >= 1024;

        final int gridCount = isWeb
            ? 4
            : isTablet
                ? 3
                : 2;
        final double iconSize = isWeb
            ? 34
            : isTablet
                ? 30
                : 26;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWeb ? 900 : double.infinity,
            ),
            child: Container(
              margin: EdgeInsets.only(
                bottom: getResponsivePadding(20, 28),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  /// HEADER
                  Container(
                    padding: EdgeInsets.all(getResponsivePadding(18, 24)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.12),
                          Colors.white,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.restaurant,
                                size: iconSize,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    foodName.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize:
                                          getResponsiveFontSize(18, 22, 24),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Quantity: $ordered',
                                    style: TextStyle(
                                      fontSize:
                                          getResponsiveFontSize(14, 16, 17),
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        /// STATUS BADGE
                        ScaleTransition(
                          scale: preparing > 0 && prepared < ordered
                              ? pulseAnimation
                              : const AlwaysStoppedAnimation(1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  currentStatus,
                                  style: TextStyle(
                                    fontSize: getResponsiveFontSize(14, 16, 18),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// PROGRESS + GRID
                  Padding(
                    padding: EdgeInsets.all(getResponsivePadding(18, 24)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Preparation Progress',
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(14, 16, 17),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(16, 18, 20),
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: isTablet ? 14 : 10,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(statusColor),
                          ),
                        ),
                        const SizedBox(height: 24),

                        /// STATUS GRID
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridCount,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: isWeb
                                ? 3.0
                                : isTablet
                                    ? 2.6
                                    : 2.2,
                          ),
                          itemCount: cancelled > 0 ? 4 : 3,
                          itemBuilder: (context, index) {
                            final items = [
                              _statusChip(
                                  Icons.receipt_long,
                                  'Ordered',
                                  ordered.toString(),
                                  Colors.blue,
                                  isTablet,
                                  getResponsiveFontSize),
                              _statusChip(
                                  Icons.restaurant,
                                  'Cooking',
                                  preparing.toString(),
                                  Colors.orange,
                                  isTablet,
                                  getResponsiveFontSize),
                              _statusChip(
                                  Icons.check_circle,
                                  'Ready',
                                  prepared.toString(),
                                  Colors.green,
                                  isTablet,
                                  getResponsiveFontSize),
                              if (cancelled > 0)
                                _statusChip(
                                    Icons.cancel,
                                    'Cancelled',
                                    cancelled.toString(),
                                    Colors.red,
                                    isTablet,
                                    getResponsiveFontSize),
                            ];
                            return items[index];
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statusChip(
    IconData icon,
    String label,
    String value,
    Color color,
    bool isTablet,
    double Function(double, double, double) getResponsiveFontSize,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12, vertical: isTablet ? 14 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: isTablet ? 22 : 18),
          const SizedBox(width: 3),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: getResponsiveFontSize(12, 13, 14),
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: getResponsiveFontSize(18, 20, 22),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
