import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Manager/considated_bill.dart';
import 'package:orderease/Manager/mg_category_dashboard.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Manager_Bill_Dashboard extends StatefulWidget {
  // final Map<String, dynamic> menu_data;
  // required this.menu_data,
  final String hotel_loc;
  final String table_option;
  final String screen_label;
  const Manager_Bill_Dashboard(
      {super.key,
      required this.hotel_loc,
      required this.table_option,
      required this.screen_label});

  @override
  State<Manager_Bill_Dashboard> createState() =>
      Manager_Status_DashboardState();
}

Map<String, dynamic>? data;
late Future<void> menu_items;
bool _isLoading = true;
bool _isfetched = false;
Iterable? docids;
List? d;
// bool
// var data_with_imagepath;

class Manager_Status_DashboardState extends State<Manager_Bill_Dashboard> {
  Map<String, Map<String, dynamic>> tableData = {};
  String globalStoredID = "";

  Future<Map<String, Map<String, dynamic>>> getTableData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    tableData = {};

    // Load the map from SharedPreferences
    String? mapJson = prefs.getString('tableData');
    if (mapJson != null) {
      Map<String, dynamic> decodedData = jsonDecode(mapJson);

      // NOTE
      // MAP ENTRY IS A CONSTRUCTOR providing key and value as the OUTPUT
      // .from method helps to retain the value as MAP itself instead of object.

      tableData = decodedData.map((key, value) => MapEntry(
            key,
            Map<String, dynamic>.from(value),
          ));
    }

    // Load status and UID from SharedPreferences
    bool? storedStatus = prefs.getBool("isBlocked_${widget.table_option}");
    String? uid = prefs.getString("uid_${widget.table_option}");
    print("LOADED MAP DATA");
    print(tableData);

    return tableData;
  }

  Map<String, dynamic> localSessionItems = {};
  String subtotal = "0.0";
  int itemsLength = 0;
  String gst = "";

  Future<void> fetch_menu_data_locally() async {
    gst = "";

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.hotel_loc)
        .get();
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    gst = data['gst_rate'];
    print(gst);
    print("GST");

    subtotal = "0.0";
    d = [];
    localSessionItems = {};

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.hotel_loc)
        .collection("Bill")
        .get();

    print("SNAP");
    print(querySnapshot.size);

    if (querySnapshot.size != 0) {
      for (var doc in querySnapshot.docs) {
        if (doc.id.split("_")[1] == widget.table_option) {
          globalStoredID = doc.id;
          break;
        }
      }
      print("GID");
      print(globalStoredID);
      if (globalStoredID != '') {
        print("PPPP");
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("Hotels")
            .doc(widget.hotel_loc)
            .collection("Bill")
            .doc(globalStoredID)
            .get();

        if (documentSnapshot.exists) {
          localSessionItems = documentSnapshot.data() as Map<String, dynamic>;

          localSessionItems = Map.fromEntries(localSessionItems.entries.where(
              (entry) =>
                  entry.key != "status" &&
                  entry.key != "timestamp" &&
                  entry.key != "email" &&
                  entry.key != "mg_name"));

          print(localSessionItems);
          print("FFF1");

          var sortedEntries = localSessionItems.entries.toList()
            ..sort((a, b) => (a.key).compareTo(b.key));

          localSessionItems = {
            for (var entry in sortedEntries) entry.key: entry.value
          } as Map<String, dynamic>;

          // Removing items with quantity zero
          for (var entry in sortedEntries) {
            print("KEY:${entry.key}, VALUE:${entry.value}");
            if (int.parse(entry.value['quantity']) -
                    int.parse(entry.value['cancelled']) ==
                0) {
              print("REMOVING ${entry.key}");
              localSessionItems.remove(entry.key);
            }
          }

          d = localSessionItems.keys.toList();

          itemsLength = 0;
          for (var key in localSessionItems.keys) {
            var item = localSessionItems[key];

            subtotal = (double.parse(subtotal) +
                    (double.parse(item['price']) *
                        double.parse(item['quantity'])))
                .toString();
            itemsLength += int.parse(item['quantity']);
          }

          print("FFF2");
          print(d);
          print(localSessionItems);
        }
      } else {
        print("Invalid GID");
        print(localSessionItems);
        print(d);
      }
      setState(() {
        d = d;
        _isLoading = false;
        _isfetched = true;
        localSessionItems = localSessionItems;
        subtotal = subtotal;
        itemsLength = itemsLength;
        gst = gst;
      });
    }
  }

  void initState() {
    super.initState();
    print("inside menu");

    menu_items = fetch_menu_data_locally();
    print(menu_items);
  }

  @override
  Widget build(BuildContext context) {
    // Edit for cancelling

    // Refreshing the page
    Future<void> refreshPage() async {
      setState(() {
        menu_items = fetch_menu_data_locally();
      });
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: outer_background(),
        elevation: 0,
        title: Text(
          "Bill (${widget.table_option})",
          style: TextStyle(fontSize: 23, color: inner_background(), fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          ProfileButton(
              context: context, hotelref: widget.hotel_loc, isTablet: isTablet)
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        color: outer_background(),
        child: FutureBuilder<void>(
          future: menu_items,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CustomLoader(message: 'Loading Bill...');
            } else if (snapshot.hasError) {
              print("Error: ${snapshot.error}");
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else if (d == null || !_isfetched || d!.length == 0) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "🛒 Your cart is empty.\nAdd some items to get started!",
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
                  ),
                  // TextButton(
                  //   style: TextButton.styleFrom(
                  //     // backgroundColor: outer_background(), // Slightly darker blue
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     padding: EdgeInsets.symmetric(vertical: 14),
                  //   ),
                  //   onPressed: () {
                  //     // WANT TO ADD MORE.. POPPING
                  //     if (widget.screen_label == "mg_menu") {
                  //       Future.delayed(Duration(milliseconds: 10), () {
                  //         Navigator.pop(context);
                  //         // Navigator.pop(context);
                  //       });
                  //     } else if (widget.screen_label == "mg_search_bar") {
                  //       Future.delayed(Duration(milliseconds: 10), () {
                  //         Navigator.pop(context);
                  //       });
                  //     }
                  //   },
                  //   child: Center(
                  //     child: Text(
                  //       "Add items..",
                  //       style: TextStyle(
                  //         fontSize: 16,
                  //         color: outer_background(),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              );
            }

            // data is present
            else {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: 15)),

                  // The loading indicator
                  if (_isLoading)
                    SliverToBoxAdapter(
                      child: CustomLoader(message: 'Loading Bill...')
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // 🔹 Item Name & Price per unit
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d![index].toString().toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "₹${localSessionItems[d![index]]['price']} per item",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 🔹 Quantity
                                  Column(
                                    children: [
                                      Text(
                                        "Qty",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                      Text(
                                        localSessionItems
                                                    .containsKey(d![index]) &&
                                                localSessionItems[d![index]]
                                                        ?['quantity'] !=
                                                    null
                                            ? "${int.parse(localSessionItems[d![index]]['quantity']) - int.parse(localSessionItems[d![index]]['cancelled'])}"
                                            : "0",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 🔹 Total Price
                                  Column(
                                    children: [
                                      Text(
                                        "Total",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                      Text(
                                        "₹${(double.tryParse(localSessionItems[d![index]]['price'].toString()) ?? 0.0) * (double.tryParse(localSessionItems[d![index]]['quantity'].toString()) ?? 0.0)}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: d!.length,
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: BillSummarySection(
                      key: ValueKey(subtotal),
                      subTotal: subtotal,
                      itemsLength: itemsLength.toString(),
                      screen_label: widget.screen_label,
                      table_option: widget.table_option,
                      href: widget.hotel_loc,
                      gst: gst,
                      orderPlaced: () {
                        setState(() {
                          subtotal = "0.0";
                          d = [];
                          itemsLength = 0;
                        });
                      },
                      screen_label_for_bill: "mg_bill",
                    ),
                  )
                ],
              );
            }
          },
        ),
      ),
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
