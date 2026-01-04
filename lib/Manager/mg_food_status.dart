import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/Manager/considated_bill.dart';
import 'package:orderease/Manager/mg_category_dashboard.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Manager_Status_Dashboard extends StatefulWidget {
  // final Map<String, dynamic> menu_data;
  // required this.menu_data,
  final String hotel_loc;
  final String table_option;
  final String screen_label;
  const Manager_Status_Dashboard(
      {super.key,
      required this.hotel_loc,
      required this.table_option,
      required this.screen_label});

  @override
  State<Manager_Status_Dashboard> createState() =>
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

class Manager_Status_DashboardState extends State<Manager_Status_Dashboard> {
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

  Future<void> fetch_menu_data_locally() async {
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
            ..sort((a, b) => (int.parse(b.value['preparing']))
                .compareTo(int.parse(a.value['preparing'])));

          localSessionItems = {
            for (var entry in sortedEntries) entry.key: entry.value
          } as Map<String, dynamic>;

          d = localSessionItems.keys.toList();

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
    Future<Map<String, dynamic>> _showEditDialog(
        BuildContext context, String food_name) async {
      print(food_name);

      TextEditingController textController = TextEditingController();

      return await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7, // 70% width
                  padding: EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "How many items would you like to cancel?",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: textController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Quantity....",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: inner_background(),
                                foregroundColor: outer_background(),
                              ),
                              child: Text("Cancel"),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                // updating the data after cancelling

                                // Status for returning which collection to update
                                bool cancelledAtLast = false;

                                int cancel_qty = 0;

                                // storing the values in local variables
                                int prepared = int.parse(
                                    localSessionItems[food_name]['prepared']);
                                int preparing = int.parse(
                                    localSessionItems[food_name]['preparing']);
                                int quantity = int.parse(
                                    localSessionItems[food_name]['quantity']);
                                int cancelled = int.parse(
                                    localSessionItems[food_name]['cancelled']);

                                if (textController.text.isNotEmpty) {
                                  cancel_qty =
                                      int.parse(textController.text.trim());
                                  if (localSessionItems
                                          .containsKey(food_name) &&
                                      localSessionItems[food_name]
                                          .containsKey('quantity') &&
                                      (cancel_qty <=
                                          int.parse(localSessionItems[food_name]
                                              ['quantity'])) &&
                                      cancel_qty > 0) {
                                    // Two cases

                                    if (prepared <= quantity) {
                                      // 1
                                      // if prepared + cancelled == ordered, and cancelled at last, ONLY UPDATE IN BILL
                                      if ((prepared + cancelled) == quantity &&
                                          (cancel_qty <=
                                              prepared + cancelled) &&
                                          (prepared > 0) &&
                                          (cancel_qty <= prepared)) {
                                        localSessionItems[food_name]
                                                ['cancelled'] =
                                            (cancelled + (cancel_qty))
                                                .toString();
                                        localSessionItems[food_name]
                                                ['prepared'] =
                                            (prepared - (cancel_qty))
                                                .toString();
                                        cancelledAtLast = true;
                                        print("CANCELLED AT LAST");
                                      }

                                      // 2
                                      // for immediate cancelling, update both preparing and cancelled.
                                      // UPDATE BOTH COOK AND BILL
                                      else if (cancel_qty <= preparing) {
                                        localSessionItems[food_name]
                                                ['preparing'] =
                                            (preparing - (cancel_qty))
                                                .toString();

                                        localSessionItems[food_name]
                                                ['cancelled'] =
                                            (cancelled + (cancel_qty))
                                                .toString();
                                      } else {
                                        print("DISPLAyING SNACKBAR");
                                        Navigator.pop(context, {
                                          "result": false,
                                          "updateCollection": "",
                                          "cancel_quantity": 0,
                                          "display": true
                                        });

                                        return;
                                      }
                                    }

                                    setState(() {
                                      // Sorting the items based on preparing quantity
                                      var sortedEntries = localSessionItems
                                          .entries
                                          .toList()
                                        ..sort((a, b) => int.parse(
                                                b.value['preparing'].toString())
                                            .compareTo(int.parse(a
                                                .value['preparing']
                                                .toString())));

                                      localSessionItems = {
                                        for (var entry in sortedEntries)
                                          entry.key: entry.value
                                      };
                                    });

                                    // Sending status to update the data in Firestore
                                    if (cancelledAtLast == true) {
                                      Navigator.pop(context, {
                                        "result": true,
                                        "updateCollection": "Bill"
                                      });
                                      print("UPDATE BILL ONLY");
                                    } else {
                                      Navigator.pop(context, {
                                        "result": true,
                                        "updateCollection": "Bill_Cook",
                                        "cancel_quantity":
                                            int.parse(textController.text)
                                      });
                                      print("UPDATE BOTH");
                                    }
                                  } else {
                                    print("CLOSE INVALID");
                                    // showBounceSnackBar(
                                    //     context,
                                    //     "Please enter a valid number, to cancel",
                                    //     "warning");
                                    Navigator.pop(context, {
                                      "result": false,
                                      "updateCollection": "",
                                      "cancel_quantity": 0,
                                      "display": true
                                    });
                                  }

                                  print("Added Note: ${textController.text}");
                                  print(localSessionItems[food_name]);
                                } else {
                                  // closing window
                                  Navigator.pop(context, {
                                    "result": false,
                                    "updateCollection": "",
                                    "cancel_quantity": 0
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: inner_background(),
                                backgroundColor: outer_background(),
                              ),
                              child: Text("Save changes"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ).then((value) =>
          value ??
          {"result": false, "updateCollection": "", "cancel_quantity": 0});
    }

    // Refreshing the page
    Future<void> refreshPage() async {
      setState(() {
        menu_items = fetch_menu_data_locally();
      });
    }

    Future<void> updateCookCollection(
        String food_item, int index, int cancel_quantity) async {
      print("Updating Cook Collection");
      print(food_item);
      print(index);
      print(cancel_quantity);

      if (cancel_quantity == null) {
        showBounceSnackBar(
            context, "Please enter a valid number to cancel", "warning");
        return;
      }

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.hotel_loc)
          .collection("Cook")
          .doc(globalStoredID)
          .get();

      int local_cancel_quantity = cancel_quantity;
      bool fullyDeleted = false;

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        List items = List.from(data[food_item]);

        List toRemove = [];
        for (var item in data[food_item]) {
          if (item['prepared_status'] == false) {
            // Updating the collection "Cook"
            if (int.parse(item['preparing']) >= local_cancel_quantity) {
              item['preparing'] =
                  (int.parse(item['preparing']) - local_cancel_quantity)
                      .toString();
              item['cancelled'] =
                  (int.parse(item['cancelled']) + local_cancel_quantity)
                      .toString();
              local_cancel_quantity = 0;
            } else {
              // If the preparing quantity is less than the cancel quantity
              local_cancel_quantity -= int.parse(item['preparing']);
              item['cancelled'] =
                  (int.parse(item['cancelled']) + int.parse(item['preparing']))
                      .toString();
              item['preparing'] = "0";
            }

            print("Updated Cook collection for $food_item");

            if (item['preparing'] == "0") {
              toRemove.add(item);
              print("Removed item from Cook collection for $food_item");
            }

            if (local_cancel_quantity == 0) {
              fullyDeleted = true;
              break;
            }
          }
        }

        // Simultaneously reoving the items is not possible, so we are storing the items to be removed in a list and removing them after the loop
        // to avoid Concurrent modification error.
        for (var item in toRemove) {
          data[food_item].remove(item);
        }

        print("FInal");

        // Update the collection "Cook" in Firestore
        if (fullyDeleted) {
          await FirebaseFirestore.instance
              .collection("Hotels")
              .doc(widget.hotel_loc)
              .collection("Cook")
              .doc(globalStoredID)
              .set(
                data,
                SetOptions(merge: true),
              );
        }
      }
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
          "Progress (${widget.table_option})",
          style: TextStyle(
              fontSize: 23,
              color: inner_background(),
              fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: inner_background()),
        ),
        actions: [
          IconButton(
              icon:  Icon(Icons.qr_code, color: inner_background(),),
              onPressed: () {
                showQR(
                    context,
                    widget.hotel_loc, // hotelId
                    widget.table_option, // tableId
                    0, // bill data,
                    "food_status", 
                    "", 
                    true);
              },
            ),
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
              return CustomLoader(message: 'Loading food status...');
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
                  TextButton(
                    style: TextButton.styleFrom(
                      // backgroundColor: outer_background(), // Slightly darker blue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // WANT TO ADD MORE.. POPPING
                      if (widget.screen_label == "mg_menu") {
                        Future.delayed(Duration(milliseconds: 10), () {
                          Navigator.pop(context);
                          // Navigator.pop(context);
                        });
                      } else if (widget.screen_label == "mg_search_bar") {
                        Future.delayed(Duration(milliseconds: 10), () {
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: Center(
                      child: Text(
                        "Add items..",
                        style: TextStyle(
                          fontSize: 16,
                          color: outer_background(),
                        ),
                      ),
                    ),
                  ),
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
                        child: CustomLoader(message: 'Loading food status...'))
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      d![index].toString().toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        size: 30,
                                        color:
                                            outer_background(), // No note added
                                      ),
                                      onPressed: () async {
                                        print(globalStoredID);
                                        print("Brfore");
                                        print(localSessionItems[d![index]]);
                                        var res = await _showEditDialog(
                                            context, d![index]);

                                        print("After");
                                        print(res);

                                        if (res['result'] == true) {
                                          // Updating the data in Firestore

                                          // Log
                                          String email = FirebaseAuth
                                              .instance.currentUser!.email!;
                                          await addLogEntry(
                                            hotelId: widget.hotel_loc,
                                            userEmail: email,
                                            action:
                                                "Ordered item -> ${d![index]} cancelled.",
                                            tableNumber: "",
                                            sessionId: "",
                                          );

                                          if (res['updateCollection'] ==
                                              "Bill_Cook") {
                                            // Update the collection "Bill_Cook"
                                            await FirebaseFirestore.instance
                                                .collection("Hotels")
                                                .doc(widget.hotel_loc)
                                                .collection("Bill")
                                                .doc(globalStoredID)
                                                .update({
                                              "${d![index]}":
                                                  localSessionItems[d![index]]
                                            });

                                            updateCookCollection(d![index],
                                                index, res['cancel_quantity']);
                                          } else if (res['updateCollection'] ==
                                              "Bill") {
                                            // Update the collection "Bill"
                                            await FirebaseFirestore.instance
                                                .collection("Hotels")
                                                .doc(widget.hotel_loc)
                                                .collection("Bill")
                                                .doc(globalStoredID)
                                                .update({
                                              "${d![index]}":
                                                  localSessionItems[d![index]]
                                            });
                                          }

                                          print(localSessionItems[d![index]]);
                                          print("Updated data in Firestore");

                                          setState(() {
                                            menu_items =
                                                fetch_menu_data_locally();
                                          });

                                          showSlideFromLeftSnackBar(
                                              context,
                                              "Items successfully cancelled",
                                              "success");
                                        } else if (!res['result'] &&
                                            res.containsKey("display") &&
                                            res['display'] == true) {
                                          print("Display invalid");
                                          showBounceSnackBar(
                                              context,
                                              "Please enter valid number, to cancel",
                                              "warning");

                                          return;
                                        }
                                      },
                                    ),
                                  ],
                                ),

                                // SizedBox(height: 8),

                                // Status Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    buildStatusWithQuantity(
                                        "Ordered",
                                        localSessionItems[d![index]]
                                                ?['quantity'] ??
                                            "0",
                                        Colors.blue.shade100,
                                        Colors.blue.shade800),
                                    buildStatusWithQuantity(
                                        "Preparing",
                                        localSessionItems[d![index]]
                                                ?['preparing'] ??
                                            "0",
                                        Colors.amber.shade100,
                                        Colors.amber.shade800),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    buildStatusWithQuantity(
                                        "Prepared",
                                        localSessionItems[d![index]]
                                                ?['prepared'] ??
                                            "0",
                                        Colors.green.shade100,
                                        Colors.green.shade900),
                                    buildStatusWithQuantity(
                                        "Cancelled",
                                        localSessionItems[d![index]]
                                                ?['cancelled'] ??
                                            "0",
                                        Colors.red.shade100,
                                        Colors.red.shade800),
                                  ],
                                ),

                                SizedBox(height: 4),
                              ],
                            ),
                          );
                        },
                        childCount: d!.length,
                      ),
                    ),
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
  String label,
  String quantity,
  Color bgColor,
  Color textColor,
) {
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'ordered':
        return Icons.receipt_long;      // order placed
      case 'preparing':
        return Icons.restaurant;        // cooking
      case 'prepared':
        return Icons.check_circle;       // ready
      case 'cancelled':
        return Icons.cancel;             // cancelled
      default:
        return Icons.info_outline;
    }
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🔹 STATUS ICON
        Icon(
          _getStatusIcon(label),
          size: 16,
          color: textColor,
        ),

        const SizedBox(width: 6),

        // 🔹 STATUS LABEL
        Text(
          "$label:",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),

        const SizedBox(width: 4),

        // 🔹 QUANTITY
        Text(
          quantity,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}
