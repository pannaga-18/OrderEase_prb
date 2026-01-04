import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Manager/considated_bill.dart';
import 'package:orderease/Manager/mg_category_dashboard.dart';
import 'package:orderease/Manager/mg_food_status.dart';
import 'package:orderease/Manager/mg_items_consolidated.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Manager_Menu_Items1 is for Consolidated CARDS (CONFUSION)

class Manager_Menu_Items1 extends StatefulWidget {
  // final Map<String, dynamic> menu_data;
  // required this.menu_data,
  final String hotel_loc;
  final String table_option;
  final String screen_label;
  const Manager_Menu_Items1(
      {super.key,
      required this.hotel_loc,
      required this.table_option,
      required this.screen_label});

  @override
  State<Manager_Menu_Items1> createState() => _MenuState();
}

Map<String, dynamic>? data;
late Future<void> menu_items;
bool _isLoading = true;
bool _isfetched = false;
Iterable? docids;
List? d;
// bool
// var data_with_imagepath;

class _MenuState extends State<Manager_Menu_Items1> {
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

  void updateLocally(
      BuildContext context,
      String itemPrice,
      String itemName,
      String operation,
      bool quantityEdit,
      bool descriptionEdit,
      String customNote) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if data exists in SharedPreferences
    bool? storedStatus = prefs.getBool("isBlocked_${widget.table_option}");

    if (storedStatus == true) {
      tableData = {};

      String? mapJson = prefs.getString('tableData');

      if (mapJson != null) {
        Map<String, dynamic> decodedData = jsonDecode(mapJson);

        tableData = decodedData.map(
            (key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
      }

      String? storedUid = prefs.getString("uid_${widget.table_option}");
      String tableSessionId =
          (storedUid != null ? storedUid + "_${widget.table_option}" : "");

      if (tableData[tableSessionId]!.containsKey(itemName)) {
        if (quantityEdit == true) {
// Update Quantity
          int updateQuantity =
              int.parse(tableData[tableSessionId]![itemName]['quantity']);

          // Update
          if (operation == "+") {
            updateQuantity += 1;
          } else if (operation == "-" && updateQuantity > 0) {
            updateQuantity -= 1;
          }

          // Ensure quantity doesn't go negative
          updateQuantity = updateQuantity < 0 ? 0 : updateQuantity;

          tableData[tableSessionId]![itemName]['quantity'] =
              updateQuantity.toString();

          // Delete Item from LS if Quantity is 0
          if (tableData[tableSessionId]![itemName]['quantity'] == "0") {
            tableData[tableSessionId]!.remove(itemName);
          }
        }

        if (descriptionEdit == true) {
          tableData[tableSessionId]![itemName]['description'] +=
              "$customNote, ";
        }

        // Store to LS
        String mapJson1 = jsonEncode(tableData);
        await prefs.setString('tableData', mapJson1);
      } else if (!tableData[tableSessionId]!.containsKey(itemName) &&
          quantityEdit == true &&
          operation == "+") {
        Map<String, dynamic> addSessionItems = {
          'price': itemPrice,
          "quantity": "1",
          'description': ""
        };

        tableData[tableSessionId]![itemName] = addSessionItems;

        String mapJson1 = jsonEncode(tableData);
        await prefs.setString('tableData', mapJson1);
        print("LS SET INITIALLY");
      }

      print("UID FOR UPDATE ${tableSessionId}");
      print("LOADED MAP DATA for UPDATE 1");
      print(tableData);

      localSessionItems = {};
      tableData = {};

      // Load the map from SharedPreferences
      String? mapJson2 = prefs.getString('tableData');
      String? uid = prefs.getString("uid_${widget.table_option}")! +
          "_${widget.table_option}";

      if (mapJson2 != null) {
        Map<String, dynamic> decodedData = jsonDecode(mapJson2);

        tableData = decodedData.map((key, value) => MapEntry(
              key,
              Map<String, dynamic>.from(value),
            ));
      }

      print("LOADING ITEMS DETAILS");

      localSessionItems = Map.fromEntries(tableData[uid]!
          .entries
          .where((entry) => entry.key != "status" && entry.key != "timestamp"));

      print(localSessionItems);

      print("LOADED MAP DATA for UPDATE 2");
      print(tableData);

      // IF NO SESSION,  IT VALIDATES for no error

      d = localSessionItems.keys.toList();

      print("FFF2");
      print(d);

      print(subtotal);
      print("PPPA");
      // subtotal = "0.0";

      if (localSessionItems.isEmpty) {
        subtotal = "0.0";
      }

      itemsLength = 0;
      subtotal = "0.0";
      for (var key in localSessionItems.keys) {
        var item = localSessionItems[key];

        subtotal = (double.parse(subtotal) +
                (double.parse(item['price']) * double.parse(item['quantity'])))
            .toString();
        itemsLength += int.parse(item['quantity']);
      }
      // if (operation == "+") {

      // } else if (operation == "-") {
      //   subtotal = "0.0";
      //   for (var key in localSessionItems.keys) {
      //     var item = localSessionItems[key];

      //     subtotal =
      //         (double.parse(item['price']) * double.parse(item['quantity']))
      //             .toString();
      //     itemsLength += int.parse(item['quantity']);
      //   }
      // }

      print(subtotal);
      print("PPPA11");

      setState(() {
        localSessionItems = localSessionItems;
        subtotal = subtotal;
        itemsLength = itemsLength;
      });
    }
    // Session not blocked Then Display MESG
    else {
      showBounceSnackBar(context, "Block the session!!", "warning");
    }
  }

  //
  Future<void> _showEditDialog(BuildContext context, String food_name) async {
    print(food_name);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? storedStatus = prefs.getBool("isBlocked_${widget.table_option}");
    tableData = await getTableData();

    String? storedUid = prefs.getString("uid_${widget.table_option}");
    String uid =
        (storedUid != null ? storedUid + "_${widget.table_option}" : "");
    print("ASD");
    print(tableData[uid]);

    if (storedStatus == true) {
      TextEditingController textController = TextEditingController();

      if (!tableData[uid]!.containsKey(food_name)) {
        showBounceSnackBar(context, "Please add some quantity...", "info");
      } else {
        String savedNote = "";
        if (tableData[uid]!.containsKey(food_name) &&
            tableData[uid]![food_name].containsKey('description')) {
          savedNote = tableData[uid]![food_name]['description'];
        }

        return showDialog(
          context: context,
          builder: (BuildContext context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final orientation = MediaQuery.of(context).orientation;
            final isLandscape = orientation == Orientation.landscape;
            final isTablet = screenWidth > 600;

            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 500 : (screenWidth * 0.85),
                      maxHeight: isLandscape
                          ? screenHeight * 0.85
                          : screenHeight * 0.7,
                    ),
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(isLandscape ? 16.0 : 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Add your custom note",
                              style: TextStyle(
                                fontSize: isTablet ? 20.0 : 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isLandscape ? 8 : 10),
                            TextField(
                              controller: textController,
                              decoration: InputDecoration(
                                labelText: "Description",
                                border: OutlineInputBorder(),
                              ),
                              maxLines: isLandscape ? 2 : 3,
                            ),
                            SizedBox(height: isLandscape ? 12 : 20),

                            // Display saved note if available
                            if (savedNote.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Saved Note: $savedNote",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: isTablet ? 15 : 14,
                                  ),
                                ),
                              ),
                            SizedBox(height: isLandscape ? 12 : 20),
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isLandscape ? 16 : 20,
                                      vertical: isLandscape ? 10 : 12,
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () async {
                                    // UPDATING CUSTOM NOTE
                                    if (textController.text.isNotEmpty) {
                                      // Updating Custom Note
                                      updateLocally(context, "", food_name, "",
                                          false, true, textController.text);

                                      tableData = await getTableData();

                                      if (tableData[uid]!
                                              .containsKey(food_name) &&
                                          tableData[uid]![food_name]
                                              .containsKey('description')) {
                                        Navigator.of(context).pop();
                                        // Updating UI
                                        setState(() {
                                          savedNote = tableData[uid]![food_name]
                                              ['description'];
                                        });
                                      }

                                      print(
                                          "Added Note: ${textController.text}");
                                      print(tableData[uid]![food_name]
                                          ['description']);
                                    } else {
                                      // closing window
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: inner_background(),
                                    backgroundColor: outer_background(),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isLandscape ? 16 : 20,
                                      vertical: isLandscape ? 10 : 12,
                                    ),
                                  ),
                                  child: Text(
                                    "Save Note",
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      }
    }
    // Session not blocked Then Display MESG
    else {
      showBounceSnackBar(context, "Block the session!!", "warning");
    }
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
    localSessionItems = {};
    tableData = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load the map from SharedPreferences

    String? mapJson = prefs.getString('tableData');

    String? storedUid = prefs.getString("uid_${widget.table_option}");

    String uid =
        (storedUid != null ? storedUid + "_${widget.table_option}" : "");

    globalStoredID = uid;

    print("MAPJOSN1");
    print(mapJson);

    if (mapJson != null) {
      Map<String, dynamic> decodedData = jsonDecode(mapJson);

      tableData = decodedData.map((key, value) => MapEntry(
            key,
            Map<String, dynamic>.from(value),
          ));

      print("LOADING ITEMS DETAILS");
      print(tableData);

      // IF NO SESSION,  IT VALIDATES for no error
      if (tableData.keys.length != 0) {
        print("UID HERE ${tableData[uid]}");
        localSessionItems = Map.fromEntries(tableData[uid]!.entries.where(
            (entry) => entry.key != "status" && entry.key != "timestamp"));

        print("LOCAL SESSION ITEMS");
        print(localSessionItems);
      }
    }

    d = localSessionItems.keys.toList();

    print("FFF1");
    print(d);

    itemsLength = 0;
    for (var key in localSessionItems.keys) {
      var item = localSessionItems[key];

      subtotal = (double.parse(subtotal) +
              (double.parse(item['price']) * double.parse(item['quantity'])))
          .toString();
      itemsLength += int.parse(item['quantity']);
    }

    setState(() {
      d = d;
      subtotal = subtotal;
      _isLoading = false;
      _isfetched = true;
      localSessionItems = localSessionItems;
      itemsLength = itemsLength;
      gst = gst;
    });
    // return true;
  }

  void initState() {
    super.initState();
    print("inside menu");

    menu_items = fetch_menu_data_locally();
    print(menu_items);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: outer_background(),
        elevation: 0,
        title: Text(
          "Order Cart (${widget.table_option})",
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
          ProfileButton(
              context: context, hotelref: widget.hotel_loc, isTablet: isTablet)
        ],
      ),
      body: FutureBuilder<void>(
        future: menu_items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomLoader(message: 'Loading items...');
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error fetching Data"),
            );
          } else if (d == null || !_isfetched || d!.length == 0) {
            return SingleChildScrollView(
                child: Column(
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

                //
                BillSummarySection(
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
                    });
                  },
                  screen_label_for_bill: "mg_items_consolidated",
                ),
              ],
            ));
          }

          // data is present
          else {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 15)),

                // The loading indicator
                if (_isLoading)
                  SliverToBoxAdapter(
                      child: CustomLoader(message: 'Loading items...'))
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 🔹 Left Section (Title, Description, Price)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title and Description
                                    Text(
                                      d![index].toString().toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    SizedBox(height: 4),

                                    // Description
                                    Text(
                                      (localSessionItems[d![index]]
                                                  ['description'] !=
                                              "")
                                          ? "${localSessionItems[d![index]]['description']}"
                                          : "No custom note", // Add description dynamically
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),

                                    SizedBox(height: 4),

                                    // Sub Price
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.currency_rupee_outlined,
                                            size: 20),
                                        Text(
                                          "${localSessionItems[d![index]]['price']}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[900],
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              Expanded(
                                child: IconButton(
                                  icon: Icon(
                                    tableData.containsKey(
                                                '${globalStoredID}') &&
                                            tableData['${globalStoredID}']!
                                                .containsKey(d![index]) &&
                                            tableData['${globalStoredID}']![
                                                    d![index]]
                                                .containsKey('description') &&
                                            tableData['${globalStoredID}']![
                                                    d![index]]['description']
                                                .isNotEmpty
                                        ? Icons.edit
                                        : Icons.edit_note,
                                    size: 25,
                                    color: tableData.containsKey(
                                                '${globalStoredID}') &&
                                            tableData['${globalStoredID}']!
                                                .containsKey(d![index]) &&
                                            tableData['${globalStoredID}']![
                                                    d![index]]
                                                .containsKey('description') &&
                                            tableData['${globalStoredID}']![
                                                    d![index]]['description']
                                                .isNotEmpty
                                        ? Colors.green // Custom note added
                                        : outer_background(), // No note added
                                  ),
                                  onPressed: () {
                                    _showEditDialog(context, d![index]);
                                  },
                                ),
                              ),

                              // 🔹 Quantity +/-
                              Row(
                                children: [
                                  // Minus Button
                                  IconButton(
                                    onPressed: () {
                                      updateLocally(
                                        context,
                                        localSessionItems[d![index]]['price']
                                            .toString(),
                                        d![index],
                                        "-",
                                        true,
                                        false,
                                        "",
                                      );
                                    },
                                    icon: Icon(Icons.remove_circle_outline,
                                        color: Colors.grey),
                                  ),

                                  // Quantity Count
                                  Text(
                                    localSessionItems.containsKey(d![index]) &&
                                            localSessionItems[d![index]]
                                                    ?['quantity'] !=
                                                null
                                        ? "${localSessionItems[d![index]]['quantity']}"
                                        : "0",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),

                                  // Plus Button
                                  IconButton(
                                    onPressed: () {
                                      updateLocally(
                                        context,
                                        localSessionItems[d![index]]['price']
                                            .toString(),
                                        d![index],
                                        "+",
                                        true,
                                        false,
                                        "",
                                      );
                                    },
                                    icon: Icon(Icons.add_circle_outline,
                                        color: Colors.black87),
                                  ),
                                ],
                              ),

                              // 🔹 Price
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.currency_rupee_outlined, size: 20),
                                  Text(
                                    "${double.parse(localSessionItems[d![index]]['price']) * double.parse(localSessionItems[d![index]]['quantity'])}", // Final price
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: dark_outer_background(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                    screen_label_for_bill: "mg_items_consolidated",
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
