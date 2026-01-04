import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Manager/confirm_order_dashboard.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Manager_Menu_Items extends StatefulWidget {
  // final Map<String, dynamic> menu_data;
  // required this.menu_data,
  final String hotel_loc;
  final String menu_label;
  final String table_option;
  const Manager_Menu_Items(
      {super.key,
      required this.hotel_loc,
      required this.menu_label,
      required this.table_option});

  @override
  State<Manager_Menu_Items> createState() => _MenuState();
}

Map<String, dynamic>? data;
late Future<void> menu_items;
bool _isLoading = true;
bool _isfetched = false;
Iterable? docids;
List? d;
// bool
// var data_with_imagepath;
Map<String, Map<String, dynamic>> food_status_map = {};

class _MenuState extends State<Manager_Menu_Items> {
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

      setState(() {
        localSessionItems = localSessionItems;
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

  // FUTURE IMPRVISATION FOR CHECKBOX

  // Future<void> _showEditDialog(BuildContext context, String food_name) async {
  //   print(food_name);

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool? storedStatus = prefs.getBool("isBlocked_${widget.table_option}");
  //   tableData = await getTableData();

  //   String? storedUid = prefs.getString("uid_${widget.table_option}");
  //   String uid =
  //       (storedUid != null ? storedUid + "_${widget.table_option}" : "");

  //   if (storedStatus == true) {
  //     TextEditingController textController = TextEditingController();

  //     // Retrieve saved note and convert to checkbox options
  //     List<String> savedNoteList = [];
  //     if (tableData[uid]!.containsKey(food_name) &&
  //         tableData[uid]![food_name].containsKey('description')) {
  //       String savedNote = tableData[uid]![food_name]['description'];
  //       savedNoteList = savedNote.split(',').map((e) => e.trim()).toList();
  //     }

  //     List<String> options = savedNoteList.isNotEmpty
  //         ? savedNoteList
  //         : ['Option 1', 'Option 2'];
  //     List<bool> checkedValues = List.generate(options.length, (index) => true);

  //     return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(
  //           builder: (context, setState) {
  //             return Dialog(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(16.0),
  //               ),
  //               child: Container(
  //                 width: MediaQuery.of(context).size.width * 0.7,
  //                 padding: EdgeInsets.all(20.0),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text(
  //                       "Add or Edit your custom note",
  //                       style: TextStyle(
  //                           fontSize: 18.0, fontWeight: FontWeight.bold),
  //                     ),
  //                     SizedBox(height: 10),

  //                     // Checkbox List
  //                     Expanded(
  //                       child: ListView.builder(
  //                         itemCount: options.length,
  //                         itemBuilder: (context, index) {
  //                           return CheckboxListTile(
  //                             title: Text(options[index]),
  //                             value: checkedValues[index],
  //                             onChanged: (value) {
  //                               setState(() {
  //                                 checkedValues[index] = value!;
  //                               });
  //                             },
  //                           );
  //                         },
  //                       ),
  //                     ),

  //                     // Input to add new options
  //                     TextField(
  //                       controller: textController,
  //                       decoration: InputDecoration(
  //                         labelText: "Add new option (comma-separated)",
  //                         border: OutlineInputBorder(),
  //                       ),
  //                     ),
  //                     SizedBox(height: 20),

  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         TextButton(
  //                           onPressed: () => Navigator.of(context).pop(),
  //                           style: TextButton.styleFrom(
  //                             backgroundColor: inner_background(),
  //                             foregroundColor: outer_background(),
  //                           ),
  //                           child: Text("Cancel"),
  //                         ),
  //                         SizedBox(width: 10),
  //                         ElevatedButton(
  //                           onPressed: () async {

  //                             // Update checked options
  //                             List<String> selectedOptions = [];
  //                             for (int i = 0; i < options.length; i++) {
  //                               if (checkedValues[i]) {
  //                                 if(options[i] != "Option 1" || options[i] != "Option 2")
  //                                 selectedOptions.add(options[i]);
  //                               }
  //                             }

  //                             // Add new options if any
  //                             if (textController.text.isNotEmpty) {
  //                               List<String> newOptions = textController.text
  //                                   .split(',')
  //                                   .map((e) => e.trim())
  //                                   .toList();
  //                               selectedOptions.addAll(newOptions);
  //                             }

  //                             String finalNote = selectedOptions.join(', ');

  //                             // updateLocally(context, "", food_name, "",
  //                             //     false, true, finalNote);
  //                             print("Final Note Saved: $finalNote");

  //                             // Navigator.of(context).pop();
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             foregroundColor: inner_background(),
  //                             backgroundColor: outer_background(),
  //                           ),
  //                           child: Text("Save Note"),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       },
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text("Block the session!!")));
  //   }
  // }

  Map<String, dynamic> localSessionItems = {};
  Future<void> fetch_menu_data(menu_label) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.hotel_loc)
        .collection("Menu")
        .doc(menu_label)
        .get();
    // print(documentSnapshot.data());

    if (documentSnapshot.exists) {
      data = documentSnapshot.data() as Map<String, dynamic>?;
    }

    print("FFF");
    print(data);

    // copy of data
    // data_with_imagepath = data;

    // for cards of menu items
    // data!.remove('category_image_path');

    // print(data);

    // d has the keys of the menu without category_image_path and provided for card
    docids = data!.keys;
    d = docids!.toList();
    d!.remove("category_image_path");
    food_status_map["food_status"] = data!['food_status'];
    d!.remove("food_status");

    // Retaining only available
    // d = d!.where((food) => data!['food_status'][food] == true).toList();

    // Sorting based on available and not available
    d!.sort((a, b) {
      bool aStatus = food_status_map["food_status"]![a] ?? false;
      bool bStatus = food_status_map["food_status"]![b] ?? false;

      // true items first
      if (aStatus == bStatus) return 0;
      return aStatus ? -1 : 1;
    });

    print("AVAILA");
    print(d);
    print("FOOD STATUS MAP $food_status_map");

    localSessionItems = {};
    tableData = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load the map from SharedPreferences

    String? mapJson = prefs.getString('tableData');

    String? storedUid = prefs.getString("uid_${widget.table_option}");

    String uid =
        (storedUid != null ? storedUid + "_${widget.table_option}" : "");

    globalStoredID = uid;

    print("MAPJOSN");
    print(mapJson);

    if (mapJson != null) {
      Map<String, dynamic> decodedData = jsonDecode(mapJson);

      tableData = decodedData.map((key, value) => MapEntry(
            key,
            Map<String, dynamic>.from(value),
          ));

      // IF NO SESSION,  IT VALIDATES for no error
      if (tableData.keys.length != 0) {
        localSessionItems = Map.fromEntries(tableData[uid]!.entries.where(
            (entry) => entry.key != "status" && entry.key != "timestamp"));
        print("LOADING ITEMS DETAILS");
        print(localSessionItems);
      }
    }

    print("FFF1");
    print(data);

    setState(() {
      data = data;
      _isLoading = false;
      _isfetched = true;
      localSessionItems = localSessionItems;
    });
    // return true;
  }

  void initState() {
    super.initState();
    print("inside menu");
    print(widget.menu_label);
    menu_items = fetch_menu_data(widget.menu_label);
    print(menu_items);

    print("menu items $data");
  }

  // Helper method to check if an item is available
  bool _isItemAvailable(String itemName) {
    // Search through all categories in food_status_map
    for (var categoryMap in food_status_map.values) {
      if (categoryMap.containsKey(itemName)) {
        // Check if the status is true (available)
        return categoryMap[itemName] == true;
      }
    }
    // Default to true if not found (backward compatibility)
    return true;
  }

  // Prepare Button function
  Future<void> navigateToConslidatedView() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? storedStatus = prefs.getBool("isBlocked_${widget.table_option}");
    print(storedStatus);

    // Block or not
    if (storedStatus == null) {
      showBounceSnackBar(context, "Block the session!!", "warning");
    } else if (storedStatus == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Manager_Order_Dashboard(
            table_option: widget.table_option,
            href: widget.hotel_loc,
            screen_label: "mg_menu",
            buttonStatus: "prepare",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // d!.remove("category_image_path");
    // print(d);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            data = {};
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: inner_background()),
        ),
        backgroundColor: outer_background(),
        elevation: 0,
        title: Row(
          children: [
            /// 🏷 MENU LABEL (Flexible & Wrapping)
            Expanded(
              child: Text(
                widget.menu_label,
                maxLines: 2, // IMPORTANT: AppBar height limit
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: TextStyle(
                  color: inner_background(),
                  fontSize: 20, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 8),

            /// 🍽 PREPARE BUTTON (Fixed width)
            InkWell(
              onTap: navigateToConslidatedView,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    color: inner_background(),
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Prepare",
                    style: TextStyle(
                      color: inner_background(),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ProfileButton(
            context: context,
            hotelref: widget.hotel_loc,
            isTablet: isTablet,
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: menu_items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomLoader(message: "Loading menu...");
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error fetching Data"),
            );
          } else if (data == null || !_isfetched) {
            return Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          // only cate no food items
          else if ((data!.containsKey("category_image_path") &&
                  data!.keys.toList().length == 1) ||
              !_isfetched) {
            print("PPP");

            return Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height *
                      0.25, // 70% of the screen height
                  width: MediaQuery.of(context).size.width, // Full width
//
                  child: ClipRRect(
                    child: Image.network(
                      data!['category_image_path'],
                      fit: BoxFit.cover, // Cover the container area
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child; // Image loaded
                        return Center(
                          child: CircularProgressIndicator(
                            color: outer_background(), // Loading indicator
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: outer_background(), // Fallback color on error
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                Center(
                    child: Text(
                  "Add menu items.",
                  style: TextStyle(fontSize: 20),
                )),
              ],
            );
          }
          // data is present
          else {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      // Background Image from Firebase
                      if (data!['category_image_path'] != null)

                        //
                        Container(
                          height: MediaQuery.of(context).size.height *
                              0.25, // 70% of the screen height
                          width:
                              MediaQuery.of(context).size.width, // Full width
                          child: ClipRRect(
                            child: Image.network(
                              data!['category_image_path'],
                              fit: BoxFit.cover, // Cover the container area
                              loadingBuilder: (context, child, progress) {
                                if (progress == null)
                                  return child; // Image loaded
                                return Center(
                                  child: CircularProgressIndicator(
                                    color:
                                        outer_background(), // Loading indicator
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color:
                                      outer_background(), // Fallback color on error
                                );
                              },
                            ),
                          ),
                        ),
                      // Default Background Color
                      if (data!['category_image_path'] == null)
                        Positioned.fill(
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                                color: outer_background(),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(
                                        15))), // Default background color
                          ),
                        ),

                      // Text Content (Always Centered)

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(15),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 15)),

                // The loading indicator
                if (_isLoading)
                  SliverToBoxAdapter(
                      child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: outer_background(),
                      strokeWidth: 2,
                    ),
                  ))
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: outer_background(),
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(20),
                          ),

                          // Cards
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              side: BorderSide(
                                color: outer_background(),
                                width: 2.0,
                              ),
                            ),

                            color: inner_background(),
                            // shadowColor: outer_background(),
                            // margin: EdgeInsets.all(8),
                            child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          d![index].toString().toUpperCase(),
                                          style: TextStyle(fontSize: 16),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // IconButton(
                                      //   icon: Icon(Icons.edit_note,
                                      //       size: 25,
                                      //       color: outer_background()),
                                      //   onPressed: () {
                                      //     //  _showEditDialog(context, index);
                                      //     _showEditDialog(context, d![index]);
                                      //   },
                                      // ),
                                      _isItemAvailable(d![index])
                                          ? IconButton(
                                              icon: Icon(
                                                tableData.containsKey(
                                                            '${globalStoredID}') &&
                                                        tableData[
                                                                '${globalStoredID}']!
                                                            .containsKey(
                                                                d![index]) &&
                                                        tableData['${globalStoredID}']![
                                                                d![index]]
                                                            .containsKey(
                                                                'description') &&
                                                        tableData['${globalStoredID}']![
                                                                    d![index]]
                                                                ['description']
                                                            .isNotEmpty
                                                    ? Icons.edit
                                                    : Icons.edit_note,
                                                size: 25,
                                                color: tableData.containsKey(
                                                            '${globalStoredID}') &&
                                                        tableData[
                                                                '${globalStoredID}']!
                                                            .containsKey(
                                                                d![index]) &&
                                                        tableData['${globalStoredID}']![
                                                                d![index]]
                                                            .containsKey(
                                                                'description') &&
                                                        tableData['${globalStoredID}']![
                                                                    d![index]]
                                                                ['description']
                                                            .isNotEmpty
                                                    ? Colors
                                                        .green // Custom note added
                                                    : outer_background(), // No note added
                                              ),
                                              onPressed: () {
                                                _showEditDialog(
                                                    context, d![index]);
                                              },
                                            )
                                          : SizedBox(),

                                      // Price (Properly aligned)
                                      Expanded(
                                        // flex: 1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.currency_rupee_outlined,
                                                size: 18),
                                            Text(
                                              data![d![index]].toString(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),

                                      _isItemAvailable(d![index])
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      updateLocally(
                                                          context,
                                                          data![d![index]]
                                                              .toString(),
                                                          d![index],
                                                          "-",
                                                          true,
                                                          false,
                                                          "");
                                                    },
                                                    icon: Icon(Icons.remove)),
                                                localSessionItems.containsKey(
                                                            d![index]) &&
                                                        localSessionItems[
                                                                    d![index]]
                                                                ?['quantity'] !=
                                                            null
                                                    ? Text(
                                                        "${localSessionItems[d![index]]['quantity']}")
                                                    : Text("0"),
                                                IconButton(
                                                    onPressed: () {
                                                      print(d![index]);
                                                      print("UPDATE");
                                                      updateLocally(
                                                          context,
                                                          data![d![index]]
                                                              .toString(),
                                                          d![index],
                                                          "+",
                                                          true,
                                                          false,
                                                          "");
                                                    },
                                                    icon: Icon(Icons.add)),
                                              ],
                                            )
                                          : Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.grey[400]!,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.block,
                                                    size: 18,
                                                    color: Colors.grey[700],
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    "Not Available",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.grey[700],
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ])),
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
    );
  }
}
