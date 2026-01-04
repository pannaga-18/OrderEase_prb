import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/menu/add_category.dart';
import 'package:orderease/util_components/bottom_navbar.dart';
import 'package:orderease/util_components/search_bar.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class build_menu_cards extends StatefulWidget {
  // final Map<String, dynamic> menu_data;
  // required this.menu_data,
  final String hotel_loc;
  final Map<String, List<String>> selected_menu_map;
  final String role;
  final String table_option;
  final Map<String, Map<String, dynamic>> food_status_map;
  const build_menu_cards(
      {super.key,
      required this.hotel_loc,
      required this.selected_menu_map,
      required this.role,
      required this.table_option,
      required this.food_status_map});

  @override
  State<build_menu_cards> createState() => _MenuState();
}

List<Map<String, dynamic>> data = [];
List menuCardsData = [];
List menu_names = [];

late Future<void> menu_items;
bool _isLoading = true;
bool _isfetched = false;
Iterable? docids;
List? d;
// bool
// var data_with_imagepath;
String globalStoredID = "";

class _MenuState extends State<build_menu_cards> {
  Map<String, dynamic> localSessionItems = {};
  Map<String, Map<String, dynamic>> tableData = {};
  Timer? _deleteTimer; // Store timer reference to cancel on dispose

  // Helper method to check if an item is available
  bool _isItemAvailable(String itemName) {
    // Search through all categories in food_status_map
    for (var categoryMap in widget.food_status_map.values) {
      if (categoryMap.containsKey(itemName)) {
        // Check if the status is true (available)
        return categoryMap[itemName] == true;
      }
    }
    // Default to true if not found (backward compatibility)
    return true;
  }

  Future<Map<String, Map<String, dynamic>>> getTableData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    tableData = {};

    // TO CLEAR LOCAL STORGAE
    // await prefs.remove("isBlocked_${widget.table_option}");
    // await prefs.remove("uid_${widget.table_option}");
    // await prefs.remove("tableData");

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
    // Early return if widget is disposed
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check mounted after async operation
    if (!mounted) return;

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
        // Check mounted after async
        if (!mounted) return;
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
        // Check mounted after async
        if (!mounted) return;
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

      if (tableData.containsKey(uid) && tableData[uid] != null) {
        localSessionItems = Map.fromEntries(tableData[uid]!.entries.where(
            (entry) => entry.key != "status" && entry.key != "timestamp"));

        print(localSessionItems);
      }

      print("LOADED MAP DATA for UPDATE 2");
      print(tableData);

      // Final mounted check before setState
      if (mounted) {
        setState(() {
          localSessionItems = localSessionItems;
        });
      }
    }
    // Session not blocked Then Display MESG
    else {
      showBounceSnackBar(context, "Block the session!!", "warning");
    }
  }

  Future<void> _showEditDialog(BuildContext context, String food_name) async {
    if (!mounted) return; // Early return if widget is disposed

    print(food_name);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check mounted after async operation
    if (!mounted) return;

    bool? storedStatus = prefs.getBool("isBlocked_${widget.table_option}");
    tableData = await getTableData();

    // Check mounted after async operation
    if (!mounted) return;

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

        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isTablet = screenWidth > 600;
        final isLandscape = screenHeight < screenWidth;

        return showDialog(
          context: context,
          builder: (BuildContext context) {
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
                                      // Check if dialog context is still valid
                                      if (!context.mounted) return;

                                      // Updating Custom Note
                                      updateLocally(context, "", food_name, "",
                                          false, true, textController.text);

                                      // Check if dialog context is still valid
                                      if (!context.mounted) return;

                                      tableData = await getTableData();

                                      // Check if dialog context is still valid
                                      if (!context.mounted) return;

                                      if (tableData[uid]!
                                              .containsKey(food_name) &&
                                          tableData[uid]![food_name]
                                              .containsKey('description')) {
                                        // Updating UI - using StatefulBuilder's setState
                                        setState(() {
                                          savedNote = tableData[uid]![food_name]
                                              ['description'];
                                        });
                                      }

                                      print(
                                          "Added Note: ${textController.text}");
                                      print(tableData[uid]![food_name]
                                          ['description']);
                                      Navigator.of(context).pop();
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

  List<Map<String, dynamic>> category_item_status_map = [];

  Map<String, dynamic> items_status_map = {};

  Future<List<Map<String, dynamic>>> fetch_menu_data(
      Map<String, List<String>> menu_map, String role) async {
    List<Map<String, dynamic>> fetchedDataList = [];

    print("Fetching menu data...");
    print(menu_map);

    // Guard: If menu_map is empty, return empty list
    if (menu_map.isEmpty) {
      if (mounted) {
        setState(() {
          data = fetchedDataList;
          menuCardsData.clear();
          menu_names.clear();
          _isLoading = false;
          _isfetched = true;
        });
      }
      return fetchedDataList;
    }

    List<String> all_available_items = [];
    for (var i in menu_map.keys) {
      if (menu_map[i] != null && menu_map[i]!.isNotEmpty) {
        all_available_items.addAll(menu_map[i]!.toList());
      }
    }

    print("TRUE ITEMS");
    print(all_available_items);

    category_item_status_map = [];
    items_status_map = {};

    for (var category in menu_map.keys) {
      // Skip empty categories
      if (menu_map[category] == null || menu_map[category]!.isEmpty) {
        continue;
      }
      // Check mounted before async operation
      if (!mounted) break;
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.hotel_loc)
          .collection("Menu")
          .doc(category)
          .get();

      // Check mounted after async operation
      if (!mounted) break;

      if (documentSnapshot.exists) {
        Map<String, dynamic> fetchedData =
            documentSnapshot.data() as Map<String, dynamic>;

        fetchedData.removeWhere((key, value) =>
            key != "food_status" && !menu_map[category]!.contains(key));

        Map<String, dynamic> status_map = {};
        print("object");
        print(fetchedData);
        print(menu_map);

        // S1
        // Ensure "food_status" contains only the relevant items
        if (fetchedData.containsKey("food_status")) {
          fetchedData["food_status"] = Map.fromEntries(
              (fetchedData["food_status"] as Map<String, dynamic>)
                  .entries
                  .where((entry) => all_available_items.contains(entry.key)));
        } else {
          fetchedData["food_status"] = {}; // Ensure it's always a Map
        }

        // Store category-wise food status
        status_map[category] = fetchedData["food_status"];
        category_item_status_map.add(status_map);

        // S2
        items_status_map.addAll(fetchedData["food_status"]);

        print("object11111");
        print(category_item_status_map);
        print(items_status_map);

        fetchedDataList.add(fetchedData);
        print("zz");
        print(fetchedDataList);
      }
    }

    if (role == "Manager") {
      // Check mounted before async operation
      if (!mounted) return fetchedDataList;

      localSessionItems = {};
      tableData = {};
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Check mounted after async operation
      if (!mounted) return fetchedDataList;

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

        print("LOADING ITEMS DETAILS");

        // IF NO SESSION,  IT VALIDATES for no error
        if (tableData.keys.length != 0 &&
            tableData.containsKey(uid) &&
            tableData[uid] != null) {
          localSessionItems = Map.fromEntries(tableData[uid]!.entries.where(
              (entry) => entry.key != "status" && entry.key != "timestamp"));

          print(localSessionItems);
        }
      }
    }

    // Only update state if widget is still mounted
    if (mounted) {
      setState(() {
        data = fetchedDataList;
        menuCardsData.clear();
        menu_names.clear();

        for (var map in data) {
          map.forEach((key, value) {
            if (key != "food_status") {
              menuCardsData.add({key: value});
              menu_names.add(key);
            }
          });
        }

        _isLoading = false;
        _isfetched = true;
        localSessionItems = localSessionItems;
      });
    }

    if (menu_names.isNotEmpty && menuCardsData.isNotEmpty) {
      print(menu_names[0]);
      print(menuCardsData);
      print("asdasdad1234");
      print(menuCardsData[0][menu_names[0]]);
    }

    return data;
  }

  @override
  void initState() {
    super.initState();
    menuCardsData = [];
    menu_names = [];
    data = [];
    menu_items = fetch_menu_data(widget.selected_menu_map, widget.role);
    print(menu_items);
    print("INIT00");
  }

  @override
  void dispose() {
    // Cancel any pending timers to prevent setState after dispose
    _deleteTimer?.cancel();
    _deleteTimer = null;
    super.dispose();
  }

  TextEditingController _itemnamecontroller = TextEditingController();
  TextEditingController _pricecontroller = TextEditingController();

  // Future<Map<String, dynamic>?> _showInputDialog(
  //     BuildContext context, String itemName, String price) async {
  //   //
  //   print(price);
  //   _itemnamecontroller.text = itemName;
  //   _pricecontroller.text = price.toString();
  //   final _formKey = GlobalKey<FormState>(); // Form key to validate the form
  //   String _inputValue = ''; // Variable to store the input value

  //   final result = await showDialog<Map<String, dynamic>>(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text(
  //             "Edit item details",
  //             style: TextStyle(
  //               fontSize: 16,
  //             ),
  //             overflow: TextOverflow.clip,
  //             softWrap: true,
  //           ),
  //           content: Form(
  //             key: _formKey,
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextFormField(
  //                   keyboardType: TextInputType.name,
  //                   controller: _itemnamecontroller,
  //                   decoration: InputDecoration(
  //                     enabledBorder: UnderlineInputBorder(
  //                       borderSide: BorderSide(
  //                           color: Colors.grey), // Color when not focused
  //                     ),
  //                     focusedBorder: UnderlineInputBorder(
  //                       borderSide: BorderSide(
  //                           color: outer_background()), // Color when focused
  //                     ),
  //                     labelText: "Name",
  //                   ),
  //                   validator: (value) {
  //                     if ((value == null || value.isEmpty)) {
  //                       return 'Field should not be empty';
  //                     }
  //                     return null;
  //                   },
  //                   onChanged: (value) {
  //                     _inputValue = value;
  //                   },
  //                 ),

  //                 // price
  //                 TextFormField(
  //                   keyboardType: TextInputType.numberWithOptions(),
  //                   controller: _pricecontroller,
  //                   decoration: InputDecoration(
  //                     enabledBorder: UnderlineInputBorder(
  //                       borderSide: BorderSide(
  //                           color: Colors.grey), // Color when not focused
  //                     ),
  //                     focusedBorder: UnderlineInputBorder(
  //                       borderSide: BorderSide(
  //                           color: outer_background()), // Color when focused
  //                     ),
  //                     labelText: "Price",
  //                   ),
  //                   validator: (value) {
  //                     if ((value == null || value.isEmpty)) {
  //                       return 'Field should not be empty';
  //                     }
  //                     return null;
  //                   },
  //                   onChanged: (value) {
  //                     _inputValue = value;
  //                   },
  //                 )
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop(); // Close the dialog
  //               },

  //               // Adding style to button
  //               style: TextButton.styleFrom(
  //                 backgroundColor: inner_background(),
  //                 foregroundColor: outer_background(),
  //               ),
  //               child: Text(
  //                 'Cancel',
  //                 style: TextStyle(color: outer_background()),
  //               ),
  //             ),
  //             ElevatedButton(
  //               onPressed: () async {
  //                 if (_formKey.currentState!.validate()) {
  //                   // If form is valid, proceed
  //                   print('Input value: $itemName');
  //                   print(widget.selected_menu_map.keys);

  //                   // Fetching category value
  //                   var category_to_search;
  //                   for (var category in widget.selected_menu_map.keys) {
  //                     if (widget.selected_menu_map[category]!
  //                         .contains(itemName)) {
  //                       category_to_search = category;
  //                       break;
  //                     }
  //                   }

  //                   print("price");
  //                   print(_pricecontroller.text);

  //                   if (itemName.toLowerCase() !=
  //                           _itemnamecontroller.text.toLowerCase() ||
  //                       price != _pricecontroller.text.toLowerCase()) {
  //                     // Get the current food_status for this item before deleting
  //                     DocumentSnapshot docSnapshot = await FirebaseFirestore
  //                         .instance
  //                         .collection("Hotels")
  //                         .doc(widget.hotel_loc)
  //                         .collection("Menu")
  //                         .doc(category_to_search)
  //                         .get();

  //                     Map<String, dynamic>? currentFoodStatus;
  //                     if (docSnapshot.exists) {
  //                       Map<String, dynamic> docData =
  //                           docSnapshot.data() as Map<String, dynamic>;
  //                       if (docData.containsKey('food_status') &&
  //                           docData['food_status'] is Map &&
  //                           (docData['food_status'] as Map)
  //                               .containsKey(itemName)) {
  //                         currentFoodStatus = {
  //                           _itemnamecontroller.text:
  //                               (docData['food_status'] as Map)[itemName]
  //                         };
  //                       }
  //                     }

  //                     // Delete old item
  //                     await FirebaseFirestore.instance
  //                         .collection("Hotels")
  //                         .doc(widget.hotel_loc)
  //                         .collection("Menu")
  //                         .doc(category_to_search)
  //                         .update({itemName: FieldValue.delete()});

  //                     // Add new item with price
  //                     Map<String, dynamic> updateData = {
  //                       _itemnamecontroller.text: _pricecontroller.text
  //                     };

  //                     // Preserve food_status if it existed
  //                     if (currentFoodStatus != null) {
  //                       updateData['food_status.${_itemnamecontroller.text}'] =
  //                           currentFoodStatus[_itemnamecontroller.text];
  //                       // Also delete old food_status entry
  //                       updateData['food_status.$itemName'] =
  //                           FieldValue.delete();
  //                     }

  //                     await FirebaseFirestore.instance
  //                         .collection("Hotels")
  //                         .doc(widget.hotel_loc)
  //                         .collection("Menu")
  //                         .doc(category_to_search)
  //                         .update(updateData);

  //                     print(menu_names);

  //                     var oldMenuitem = {itemName: price};
  //                     var newMenuItem = {_inputValue: _pricecontroller.text};

  //                     print("SADA1234");
  //                     print(menuCardsData);

  //                     // removing  old and adding new

  //                     // setState(() {
  //                     menuCardsData
  //                         .removeWhere((map) => map.containsKey(itemName));
  //                     menuCardsData.add(
  //                         {_itemnamecontroller.text: _pricecontroller.text});
  //                     menu_names.remove(itemName);
  //                     menu_names.add(itemName);
  //                     print("SADA");
  //                     print(menuCardsData);

  //                     // });

  //                     if (mounted) {
  //                       setState(() {});
  //                     }

  //                     Navigator.of(context).pop({
  //                       'edit_status': true,
  //                       "old_cat": oldMenuitem,
  //                       "new_cat": newMenuItem
  //                     });
  //                   }

  //                   // Close the dialog
  //                 }
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: outer_background(),
  //                 foregroundColor: inner_background(),
  //               ),
  //               child: Text('Save'),
  //             ),
  //           ],
  //         );
  //       });

  //   return result;
  // }

  Future<Map<String, dynamic>?> _showInputDialog(
      BuildContext context, String itemName, String price) async {
    print(price);
    _itemnamecontroller.text = itemName;
    _pricecontroller.text = price.toString();
    final _formKey = GlobalKey<FormState>();
    String _inputValue = '';

    final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Edit item details",
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.clip,
              softWrap: true,
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.name,
                    controller: _itemnamecontroller,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: outer_background()),
                      ),
                      labelText: "Name",
                    ),
                    validator: (value) {
                      if ((value == null || value.isEmpty)) {
                        return 'Field should not be empty';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _inputValue = value;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.numberWithOptions(),
                    controller: _pricecontroller,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: outer_background()),
                      ),
                      labelText: "Price",
                    ),
                    validator: (value) {
                      if ((value == null || value.isEmpty)) {
                        return 'Field should not be empty';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _inputValue = value;
                    },
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: inner_background(),
                  foregroundColor: outer_background(),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: outer_background()),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    print('Input value: $itemName');
                    print(widget.selected_menu_map.keys);

                    // Save context before async operations
                    final dialogContext = context;

                    // Fetching category value
                    var category_to_search;
                    for (var category in widget.selected_menu_map.keys) {
                      if (widget.selected_menu_map[category]!
                          .contains(itemName)) {
                        category_to_search = category;
                        break;
                      }
                    }

                    print("price");
                    print(_pricecontroller.text);

                    if (itemName.toLowerCase() !=
                            _itemnamecontroller.text.toLowerCase() ||
                        price != _pricecontroller.text.toLowerCase()) {
                      try {
                        // Get the current food_status for this item before deleting
                        DocumentSnapshot docSnapshot = await FirebaseFirestore
                            .instance
                            .collection("Hotels")
                            .doc(widget.hotel_loc)
                            .collection("Menu")
                            .doc(category_to_search)
                            .get();

                        bool? currentFoodStatus;
                        if (docSnapshot.exists) {
                          Map<String, dynamic> docData =
                              docSnapshot.data() as Map<String, dynamic>;
                          if (docData.containsKey('food_status') &&
                              docData['food_status'] is Map &&
                              (docData['food_status'] as Map)
                                  .containsKey(itemName)) {
                            currentFoodStatus = (docData['food_status']
                                as Map)[itemName] as bool?;
                          }
                        }

                        // Use the preserved status or default to true
                        bool statusToUse = currentFoodStatus ?? true;

                        // Prepare update data
                        Map<String, dynamic> updateData = {
                          _itemnamecontroller.text: _pricecontroller.text,
                          itemName: FieldValue.delete(),
                          'food_status.${_itemnamecontroller.text}':
                              statusToUse,
                          'food_status.$itemName': FieldValue.delete(),
                        };

                        print("updateData $updateData");

                        // Single update to Firestore
                        await FirebaseFirestore.instance
                            .collection("Hotels")
                            .doc(widget.hotel_loc)
                            .collection("Menu")
                            .doc(category_to_search)
                            .update(updateData);

                        print("Successfully updated item in Firestore");

                        var oldMenuitem = {itemName: price};
                        var newMenuItem = {
                          _itemnamecontroller.text: _pricecontroller.text
                        };

                        // Check if dialog context is still mounted before popping
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop({
                            'edit_status': true,
                            "old_cat": oldMenuitem,
                            "new_cat": newMenuItem
                          });
                        }
                      } catch (e) {
                        print("Error updating item: $e");
                        // Check if context is still mounted before showing snackbar
                        if (dialogContext.mounted) {
                          showBounceSnackBar(
                              dialogContext, "Error updating item: $e", "fail");
                        }
                      }
                    } else {
                      // Check if context is still mounted before popping
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: outer_background(),
                  foregroundColor: inner_background(),
                ),
                child: Text('Save'),
              ),
            ],
          );
        });

    return result;
  }

  Future<bool> _show_Alert_before_delete(
      BuildContext context, String itemName, String price) async {
    String iname = itemName;
    bool undo_flag = true;

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Delete Food Item"),
              content: Text("Do you want to delete ${itemName}?"),
              actions: [
                // Cancel Action
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel"),
                  style: TextButton.styleFrom(
                      backgroundColor: inner_background(),
                      foregroundColor: outer_background()),
                ),
                // Confirm Delete Action
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Return true to confirm deletion
                  },
                  child: Text("Delete"),
                  style: ElevatedButton.styleFrom(
                      foregroundColor: inner_background(),
                      backgroundColor: outer_background()),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed without action
  }

  // Future<Map<String, dynamic>> _toggle_food_status(
  //     bool value, String food_name) async {
  // DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //     .collection("Hotels")
  //     .doc(widget.hotel_loc)
  //     .collection("Menu")
  //     .doc(widget.menu_label)
  //     .get();

  // if (!documentSnapshot.exists) {
  //   print("Document does not exist");
  // }

  // Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

  // if (data.containsKey("food_status") &&
  //     data["food_status"] is Map<String, dynamic>) {
  //   data["food_status"][food_name] = value;
  // } else {
  //   print("food_status field does not exist or is not a Map");
  // }

  // await FirebaseFirestore.instance
  //     .collection("Hotels")
  //     .doc(widget.hotel_loc)
  //     .collection("Menu")
  //     .doc(widget.)
  //     .update({
  //   "food_status.$food_name": value // Dot notation for nested update
  // });

  //   return data;
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenHeight < screenWidth;

    return FutureBuilder<void>(
      future: menu_items,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: outer_background(),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Error fetching Data ${snapshot.error}",
                style: TextStyle(fontSize: isTablet ? 18 : 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        // data is present
        else {
          return CustomScrollView(
            slivers: [
              // The loading indicator
              if (_isLoading)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        color: outer_background(),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (widget.role == "Manager") {
                        return Stack(
                          children: [
                            // Main Card Container
                            Container(
                              margin: EdgeInsets.only(
                                  left: isTablet ? 20 : 2,
                                  right: isTablet ? 20 : 2,
                                  bottom: isTablet ? 7 : 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  side: BorderSide(
                                    color: _isItemAvailable(menu_names[index])
                                        ? outer_background()
                                        : Colors.grey[400]!,
                                    width: isTablet ? 2.5 : 2.0,
                                  ),
                                ),
                                color: _isItemAvailable(menu_names[index])
                                    ? inner_background()
                                    : Colors.grey[100],
                                child: Padding(
                                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Menu Name (Handles long text)
                                      Expanded(
                                        flex: isLandscape && !isTablet ? 2 : 1,
                                        child: Text(
                                          menu_names[index]
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(
                                              fontSize: isTablet
                                                  ? 18
                                                  : (isLandscape ? 15 : 16),
                                              fontWeight: FontWeight.bold),
                                          maxLines: isLandscape ? 1 : 2,
                                          overflow: TextOverflow
                                              .ellipsis, // Prevents text overflow
                                        ),
                                      ),

                                      IconButton(
                                        icon: Icon(
                                          tableData.containsKey(
                                                      '${globalStoredID}') &&
                                                  tableData[
                                                          '${globalStoredID}']!
                                                      .containsKey(
                                                          menu_names[index]) &&
                                                  tableData['${globalStoredID}']![
                                                          menu_names[index]]
                                                      .containsKey(
                                                          'description') &&
                                                  tableData['${globalStoredID}']![
                                                              menu_names[index]]
                                                          ['description']
                                                      .isNotEmpty
                                              ? Icons.edit
                                              : Icons.edit_note,
                                          size: isTablet
                                              ? 28
                                              : (isLandscape ? 22 : 25),
                                          color: tableData.containsKey(
                                                      '${globalStoredID}') &&
                                                  tableData[
                                                          '${globalStoredID}']!
                                                      .containsKey(
                                                          menu_names[index]) &&
                                                  tableData['${globalStoredID}']![
                                                          menu_names[index]]
                                                      .containsKey(
                                                          'description') &&
                                                  tableData['${globalStoredID}']![
                                                              menu_names[index]]
                                                          ['description']
                                                      .isNotEmpty
                                              ? Colors
                                                  .green // Custom note added
                                              : outer_background(), // No note added
                                        ),
                                        onPressed: () {
                                          _showEditDialog(
                                              context, menu_names[index]);
                                        },
                                      ),

                                      // Price Section
                                      Expanded(
                                        flex: isLandscape && !isTablet ? 1 : 1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.currency_rupee_outlined,
                                                size: isTablet
                                                    ? 20
                                                    : (isLandscape ? 16 : 18),
                                                color: _isItemAvailable(
                                                        menu_names[index])
                                                    ? Colors.black87
                                                    : Colors.grey[600]),
                                            Flexible(
                                              child: Text(
                                                menuCardsData[index]
                                                        [menu_names[index]]
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: isTablet
                                                        ? 18
                                                        : (isLandscape
                                                            ? 15
                                                            : 16),
                                                    fontWeight: FontWeight.w500,
                                                    color: _isItemAvailable(
                                                            menu_names[index])
                                                        ? Colors.black87
                                                        : Colors.grey[600]),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      if (widget.role == "Manager")
                                        _isItemAvailable(menu_names[index])
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    onPressed: () async {
                                                      print(menuCardsData[index]
                                                          [menu_names[index]]);
                                                      print(menu_names[index]);
                                                      print("PP");

                                                      updateLocally(
                                                          context,
                                                          menuCardsData[index][
                                                                  menu_names[
                                                                      index]]
                                                              .toString(),
                                                          menu_names[index],
                                                          "-",
                                                          true,
                                                          false,
                                                          "");
                                                    },
                                                    icon: Icon(Icons.remove),
                                                    iconSize: isTablet
                                                        ? 28
                                                        : (isLandscape
                                                            ? 22
                                                            : 25),
                                                  ),
                                                  localSessionItems.containsKey(
                                                              menu_names[
                                                                  index]) &&
                                                          localSessionItems[
                                                                      menu_names[
                                                                          index]]
                                                                  ?[
                                                                  'quantity'] !=
                                                              null
                                                      ? Text(
                                                          "${localSessionItems[menu_names[index]]['quantity']}",
                                                          style: TextStyle(
                                                            fontSize: isTablet
                                                                ? 18
                                                                : (isLandscape
                                                                    ? 15
                                                                    : 16),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                      : Text(
                                                          "0",
                                                          style: TextStyle(
                                                            fontSize: isTablet
                                                                ? 18
                                                                : (isLandscape
                                                                    ? 15
                                                                    : 16),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                  IconButton(
                                                    onPressed: () {
                                                      print("UPDATE");
                                                      updateLocally(
                                                          context,
                                                          menuCardsData[index][
                                                                  menu_names[
                                                                      index]]
                                                              .toString(),
                                                          menu_names[index],
                                                          "+",
                                                          true,
                                                          false,
                                                          "");
                                                    },
                                                    icon: Icon(Icons.add),
                                                    iconSize: isTablet
                                                        ? 28
                                                        : (isLandscape
                                                            ? 22
                                                            : 25),
                                                  ),
                                                ],
                                              )
                                            : Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: isTablet
                                                        ? 14
                                                        : (isLandscape
                                                            ? 10
                                                            : 12),
                                                    vertical: isTablet
                                                        ? 10
                                                        : (isLandscape
                                                            ? 6
                                                            : 8)),
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.block,
                                                      size: isTablet
                                                          ? 20
                                                          : (isLandscape
                                                              ? 16
                                                              : 18),
                                                      color: Colors.grey[700],
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            isTablet ? 8 : 6),
                                                    Text(
                                                      "Not Available",
                                                      style: TextStyle(
                                                        fontSize: isTablet
                                                            ? 15
                                                            : (isLandscape
                                                                ? 12
                                                                : 13),
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

                                      // Column(
                                      //   children: [
                                      //     Switch(
                                      //       value: (data != null &&
                                      //               data!['food_status'] !=
                                      //                   null &&
                                      //               data!['food_status']
                                      //                       [d?[index]] !=
                                      //                   null)
                                      //           ? data!['food_status']
                                      //               [d![index]]
                                      //           : false, // Default to false if null
                                      //       onChanged: (bool value) async {
                                      //         if (data != null &&
                                      //             data!['food_status'] !=
                                      //                 null &&
                                      //             d != null) {
                                      //           Map<String, dynamic> result =
                                      //               await _toggle_food_status(
                                      //                   value, d![index]);
                                      //           print(result);
                                      //           print("After changing");
                                      //           setState(() {
                                      //             data = result;
                                      //           });
                                      //         } else {
                                      //           print(
                                      //               "Error: Data or food status is null");
                                      //         }
                                      //       },
                                      //       activeColor: outer_background(),
                                      //       inactiveThumbColor: Colors.grey,
                                      //       inactiveTrackColor:
                                      //           Colors.grey.shade200,
                                      //     ),
                                      //     Text(data!['food_status'][d![index]]
                                      //         ? "Available"
                                      //         : "Unavailable")
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Positioned Close Icon at Top Right
                            Positioned(
                              top: 0, // Adjust vertical positioning
                              right: isLandscape
                                  ? 13
                                  : 3, // Adjust horizontal positioning
                              child: GestureDetector(
                                onTap: () {
                                  if (menu_names.isNotEmpty &&
                                      index >= 0 &&
                                      index < menu_names.length) {
                                    String removedItem = menu_names[
                                        index]; // Store the item before removing

                                    if (mounted) {
                                      setState(() {
                                        // Clear list safely
                                        selectedCategories.remove(removedItem);
                                        filteredCategories.remove(removedItem);
                                        menu_names.removeAt(index);
                                        menu_Cards.removeAt(index);
                                        menuCardsData.removeWhere((map) =>
                                            map.containsKey(removedItem));

                                        for (var category
                                            in category_items_selected_map.keys
                                                .toList()) {
                                          if (category_items_selected_map[
                                                  category]!
                                              .contains(removedItem)) {
                                            category_items_selected_map[
                                                    category]!
                                                .remove(removedItem);
                                          }
                                        }
                                      });
                                    }

                                    print("Removed Item: $removedItem");
                                  } else {
                                    print(
                                        "Error: Trying to remove from an empty list or invalid index.");
                                  }
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          Colors.red, // Close button background
                                    ),
                                    // padding: EdgeInsets.all(1),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white, // Close icon color
                                      size: isTablet
                                          ? 20
                                          : (isLandscape ? 16 : 18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (widget.role == "Admin") {
                        return Stack(
                          children: [
                            // Main Card Container
                            Container(
                              margin: EdgeInsets.all(isTablet ? 4 : 2),
                              decoration: BoxDecoration(
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: outer_background(),
                                //     offset: Offset(4, 4),
                                //     blurRadius: 0,
                                //   ),
                                // ],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  side: BorderSide(
                                    color: outer_background(),
                                    width: isTablet ? 2.5 : 2.0,
                                  ),
                                ),
                                color: inner_background(),
                                child: Padding(
                                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Menu Name (Handles long text)
                                      Expanded(
                                        flex: isLandscape && !isTablet ? 2 : 1,
                                        child: Text(
                                          menu_names[index]
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(
                                              fontSize: isTablet
                                                  ? 18
                                                  : (isLandscape ? 15 : 16),
                                              fontWeight: FontWeight.bold),
                                          maxLines: isLandscape ? 1 : 2,
                                          overflow: TextOverflow
                                              .ellipsis, // Prevents text overflow
                                        ),
                                      ),

                                      // Price Section
                                      Expanded(
                                        flex: isLandscape && !isTablet ? 1 : 2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.currency_rupee_outlined,
                                                size: isTablet
                                                    ? 20
                                                    : (isLandscape ? 16 : 18)),
                                            Flexible(
                                              child: Text(
                                                menuCardsData[index]
                                                        [menu_names[index]]
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: isTablet
                                                        ? 18
                                                        : (isLandscape
                                                            ? 15
                                                            : 16),
                                                    fontWeight:
                                                        FontWeight.w500),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Edit & Delete Icons

                                      if (widget.role == "Admin")
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                // var result =
                                                //     await _showInputDialog(
                                                //         context,
                                                //         menu_names[index],
                                                //         menuCardsData[index][
                                                //             menu_names[index]]);

                                                // // result coming after the edit
                                                // if (result != null) {
                                                //   var editResult =
                                                //       result['edit_status'] ??
                                                //           false;
                                                //   Map oldMenuItem =
                                                //       result['old_cat'] ?? {};
                                                //   Map newMenuItem =
                                                //       result['new_cat'] ?? {};

                                                //   if (editResult &&
                                                //       oldMenuItem.isNotEmpty &&
                                                //       newMenuItem.isNotEmpty) {
                                                //     // Update the selected_menu_map
                                                //     String oldItemName =
                                                //         oldMenuItem.keys.first;
                                                //     String newItemName =
                                                //         newMenuItem.keys.first;

                                                //     // Find and update the category in selected_menu_map
                                                //     String? updatedCategory;
                                                //     for (var category in widget
                                                //         .selected_menu_map
                                                //         .keys) {
                                                //       if (widget
                                                //           .selected_menu_map[
                                                //               category]!
                                                //           .contains(
                                                //               oldItemName)) {
                                                //         widget
                                                //             .selected_menu_map[
                                                //                 category]!
                                                //             .remove(
                                                //                 oldItemName);
                                                //         widget
                                                //             .selected_menu_map[
                                                //                 category]!
                                                //             .add(newItemName);
                                                //         updatedCategory =
                                                //             category;
                                                //         break;
                                                //       }
                                                //     }

                                                //     // Save context reference before async operations
                                                //     final currentContext =
                                                //         context;

                                                //     // Show loading immediately
                                                //     if (mounted) {
                                                //       setState(() {
                                                //         _isLoading = true;
                                                //       });
                                                //     }

                                                //     // Update local state immediately to show the change
                                                //     if (mounted) {
                                                //       setState(() {
                                                //         // Update menu_names
                                                //         int itemIndex =
                                                //             menu_names.indexOf(
                                                //                 oldItemName);
                                                //         if (itemIndex != -1) {
                                                //           menu_names[
                                                //                   itemIndex] =
                                                //               newItemName;
                                                //         }

                                                //         // Update menuCardsData
                                                //         menuCardsData =
                                                //             menuCardsData
                                                //                 .map((map) {
                                                //           if (map.containsKey(
                                                //               oldItemName)) {
                                                //             return {
                                                //               newItemName:
                                                //                   newMenuItem
                                                //                       .values
                                                //                       .first
                                                //             };
                                                //           }
                                                //           return map;
                                                //         }).toList();

                                                //         // Update items_status_map if it exists
                                                //         if (items_status_map
                                                //             .containsKey(
                                                //                 oldItemName)) {
                                                //           bool oldStatus =
                                                //               items_status_map[
                                                //                       oldItemName] ??
                                                //                   true;
                                                //           items_status_map
                                                //               .remove(
                                                //                   oldItemName);
                                                //           items_status_map[
                                                //                   newItemName] =
                                                //               oldStatus;
                                                //         }

                                                //         // Update category_item_status_map
                                                //         for (var map
                                                //             in category_item_status_map) {
                                                //           for (var category
                                                //               in map.keys) {
                                                //             if (map[category]
                                                //                     is Map<
                                                //                         String,
                                                //                         dynamic> &&
                                                //                 map[category]
                                                //                     .containsKey(
                                                //                         oldItemName)) {
                                                //               bool oldStatus =
                                                //                   map[category][
                                                //                           oldItemName] ??
                                                //                       true;
                                                //               map[category].remove(
                                                //                   oldItemName);
                                                //               map[category][
                                                //                       newItemName] =
                                                //                   oldStatus;
                                                //             }
                                                //           }
                                                //         }
                                                //       });
                                                //     }

                                                //     // Update global search maps (only local state, no Firestore fetch)
                                                //     get_search_items(
                                                //         widget.hotel_loc,
                                                //         false,
                                                //         false,
                                                //         false,
                                                //         true, // item_edit_status = true
                                                //         false,
                                                //         false,
                                                //         "",
                                                //         "",
                                                //         oldMenuItem,
                                                //         newMenuItem);

                                                //     // Wait for Firestore to propagate changes (3 seconds delay)
                                                //     await Future.delayed(
                                                //         Duration(seconds: 3));

                                                //     // Refresh search items from Firestore
                                                //     await refresh_search_items_after_edit(
                                                //         widget.hotel_loc);

                                                //     // Fetch fresh menu data
                                                //     if (widget.selected_menu_map
                                                //         .isNotEmpty) {
                                                //       try {
                                                //         await fetch_menu_data(
                                                //             widget
                                                //                 .selected_menu_map,
                                                //             widget.role);

                                                //         // Check both mounted AND context.mounted before showing snackbar
                                                //         if (mounted &&
                                                //             currentContext
                                                //                 .mounted) {
                                                //           showBounceSnackBar(
                                                //               currentContext,
                                                //               "Item updated successfully!",
                                                //               "success");
                                                //         }
                                                //       } catch (e) {
                                                //         print(
                                                //             "Error fetching menu data: $e");
                                                //         // Check both mounted AND context.mounted before showing snackbar
                                                //         if (mounted &&
                                                //             currentContext
                                                //                 .mounted) {
                                                //           showBounceSnackBar(
                                                //               currentContext,
                                                //               "Item updated but refresh failed. Please reload.",
                                                //               "warning");
                                                //         }
                                                //       }
                                                //     } else {
                                                //       // If map is empty, clear the UI
                                                //       if (mounted) {
                                                //         setState(() {
                                                //           menu_names.clear();
                                                //           menuCardsData.clear();
                                                //           data.clear();
                                                //         });
                                                //       }
                                                //     }

                                                //     if (mounted) {
                                                //       setState(() {
                                                //         _isLoading = false;
                                                //       });
                                                //     }
                                                //   }
                                                // }

                                                print("Edit Implemented later");
                                              },
                                              icon: Icon(Icons.edit),
                                              iconSize: isTablet
                                                  ? 28
                                                  : (isLandscape ? 22 : 25),
                                            ),
                                            // IconButton(
                                            //   onPressed: () async {
                                            //     var result =
                                            //         await _showInputDialog(
                                            //             context,
                                            //             menu_names[index],
                                            //             menuCardsData[index][
                                            //                 menu_names[index]]);

                                            //     // result coming after the edit
                                            //     if (result != null) {
                                            //       var editResult =
                                            //           result['edit_status'] ??
                                            //               false;
                                            //       Map oldMenuItem =
                                            //           result['old_cat'] ?? {};
                                            //       Map newMenuItem =
                                            //           result['new_cat'] ?? {};

                                            //       if (editResult &&
                                            //           oldMenuItem.isNotEmpty &&
                                            //           newMenuItem.isNotEmpty) {
                                            //         // Update the selected_menu_map
                                            //         String oldItemName =
                                            //             oldMenuItem.keys.first;
                                            //         String newItemName =
                                            //             newMenuItem.keys.first;

                                            //         // Find and update the category in selected_menu_map
                                            //         String? updatedCategory;
                                            //         for (var category in widget
                                            //             .selected_menu_map
                                            //             .keys) {
                                            //           if (widget
                                            //               .selected_menu_map[
                                            //                   category]!
                                            //               .contains(
                                            //                   oldItemName)) {
                                            //             widget
                                            //                 .selected_menu_map[
                                            //                     category]!
                                            //                 .remove(
                                            //                     oldItemName);
                                            //             widget
                                            //                 .selected_menu_map[
                                            //                     category]!
                                            //                 .add(newItemName);
                                            //             updatedCategory =
                                            //                 category;
                                            //             break;
                                            //           }
                                            //         }

                                            //         // Show loading immediately
                                            //         if (mounted) {
                                            //           setState(() {
                                            //             _isLoading = true;
                                            //           });
                                            //         }

                                            //         // Update local state immediately to show the change
                                            //         if (mounted) {
                                            //           setState(() {
                                            //             // Update menu_names
                                            //             int itemIndex =
                                            //                 menu_names.indexOf(
                                            //                     oldItemName);
                                            //             if (itemIndex != -1) {
                                            //               menu_names[
                                            //                       itemIndex] =
                                            //                   newItemName;
                                            //             }

                                            //             // Update menuCardsData
                                            //             menuCardsData =
                                            //                 menuCardsData
                                            //                     .map((map) {
                                            //               if (map.containsKey(
                                            //                   oldItemName)) {
                                            //                 return {
                                            //                   newItemName:
                                            //                       newMenuItem
                                            //                           .values
                                            //                           .first
                                            //                 };
                                            //               }
                                            //               return map;
                                            //             }).toList();

                                            //             // Update items_status_map if it exists
                                            //             if (items_status_map
                                            //                 .containsKey(
                                            //                     oldItemName)) {
                                            //               bool oldStatus =
                                            //                   items_status_map[
                                            //                           oldItemName] ??
                                            //                       true;
                                            //               items_status_map
                                            //                   .remove(
                                            //                       oldItemName);
                                            //               items_status_map[
                                            //                       newItemName] =
                                            //                   oldStatus;
                                            //             }

                                            //             // Update category_item_status_map
                                            //             for (var map
                                            //                 in category_item_status_map) {
                                            //               for (var category
                                            //                   in map.keys) {
                                            //                 if (map[category]
                                            //                         is Map<
                                            //                             String,
                                            //                             dynamic> &&
                                            //                     map[category]
                                            //                         .containsKey(
                                            //                             oldItemName)) {
                                            //                   bool oldStatus =
                                            //                       map[category][
                                            //                               oldItemName] ??
                                            //                           true;
                                            //                   map[category].remove(
                                            //                       oldItemName);
                                            //                   map[category][
                                            //                           newItemName] =
                                            //                       oldStatus;
                                            //                 }
                                            //               }
                                            //             }
                                            //           });
                                            //         }

                                            //         // Update global search maps (only local state, no Firestore fetch)
                                            //         get_search_items(
                                            //             widget.hotel_loc,
                                            //             false,
                                            //             false,
                                            //             false,
                                            //             true, // item_edit_status = true
                                            //             false,
                                            //             false,
                                            //             "",
                                            //             "",
                                            //             oldMenuItem,
                                            //             newMenuItem);

                                            //         // Wait for Firestore to propagate changes (3 seconds delay)
                                            //         await Future.delayed(
                                            //             Duration(seconds: 3));

                                            //         // Refresh search items from Firestore
                                            //         await refresh_search_items_after_edit(
                                            //             widget.hotel_loc);

                                            //         // Fetch fresh menu data
                                            //         if (widget.selected_menu_map
                                            //             .isNotEmpty) {
                                            //           try {
                                            //             await fetch_menu_data(
                                            //                 widget
                                            //                     .selected_menu_map,
                                            //                 widget.role);

                                            //             if (mounted) {
                                            //               showStatusSnackBar(
                                            //                   context,
                                            //                   "Item updated successfully!",
                                            //                   "success");
                                            //             }
                                            //           } catch (e) {
                                            //             print(
                                            //                 "Error fetching menu data: $e");
                                            //             if (mounted) {
                                            //               showStatusSnackBar(
                                            //                   context,
                                            //                   "Item updated but refresh failed. Please reload.",
                                            //                   "warning");
                                            //             }
                                            //           }
                                            //         } else {
                                            //           // If map is empty, clear the UI
                                            //           if (mounted) {
                                            //             setState(() {
                                            //               menu_names.clear();
                                            //               menuCardsData.clear();
                                            //               data.clear();
                                            //             });
                                            //           }
                                            //         }

                                            //         if (mounted) {
                                            //           setState(() {
                                            //             _isLoading = false;
                                            //           });
                                            //         }
                                            //       }
                                            //     }
                                            //   },
                                            //   icon: Icon(Icons.edit),
                                            // ),
                                            IconButton(
                                              onPressed: () async {
                                                bool? shouldDelete =
                                                    await _show_Alert_before_delete(
                                                        context,
                                                        menu_names[index],
                                                        menuCardsData[index][
                                                            menu_names[index]]);

                                                if (shouldDelete == true) {
                                                  String itemName =
                                                      menu_names[index];
                                                  String itemPrice =
                                                      menuCardsData[index][
                                                              menu_names[index]]
                                                          .toString();

                                                  // Find the category for this item
                                                  String? categoryToUpdate;
                                                  for (var category in widget
                                                      .selected_menu_map.keys) {
                                                    if (widget
                                                        .selected_menu_map[
                                                            category]!
                                                        .contains(itemName)) {
                                                      categoryToUpdate =
                                                          category;
                                                      break;
                                                    }
                                                  }

                                                  if (categoryToUpdate !=
                                                      null) {
                                                    // Remove from local state immediately
                                                    if (mounted) {
                                                      setState(() {
                                                        menu_names
                                                            .remove(itemName);
                                                        menuCardsData
                                                            .removeWhere((map) =>
                                                                map.containsKey(
                                                                    itemName));
                                                      });
                                                    }

                                                    // Update selected_menu_map
                                                    widget.selected_menu_map[
                                                            categoryToUpdate]!
                                                        .remove(itemName);

                                                    // If category is now empty, remove it
                                                    if (widget
                                                        .selected_menu_map[
                                                            categoryToUpdate]!
                                                        .isEmpty) {
                                                      widget.selected_menu_map
                                                          .remove(
                                                              categoryToUpdate);
                                                    }

                                                    // Update global search maps
                                                    get_search_items(
                                                        widget.hotel_loc,
                                                        false,
                                                        true,
                                                        false,
                                                        false,
                                                        false,
                                                        false,
                                                        categoryToUpdate,
                                                        "", {}, {});

                                                    // Show undo snackbar
                                                    bool undoFlag = true;
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                                "Menu Item deleted!"),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              undoFlag = false;

                                                              // Cancel the delete timer since we're undoing
                                                              _deleteTimer
                                                                  ?.cancel();
                                                              _deleteTimer =
                                                                  null;

                                                              // Restore item
                                                              if (categoryToUpdate !=
                                                                  null) {
                                                                widget.selected_menu_map[
                                                                    categoryToUpdate] ??= [];
                                                                widget
                                                                    .selected_menu_map[
                                                                        categoryToUpdate]!
                                                                    .add(
                                                                        itemName);
                                                              }

                                                              // Refresh widget
                                                              if (mounted) {
                                                                setState(() {
                                                                  _isLoading =
                                                                      true;
                                                                });
                                                              }

                                                              if (widget
                                                                  .selected_menu_map
                                                                  .isNotEmpty) {
                                                                fetch_menu_data(
                                                                        widget
                                                                            .selected_menu_map,
                                                                        widget
                                                                            .role)
                                                                    .then((_) {
                                                                  if (mounted) {
                                                                    setState(
                                                                        () {
                                                                      _isLoading =
                                                                          false;
                                                                    });
                                                                  }
                                                                });
                                                              } else {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    menu_names
                                                                        .clear();
                                                                    menuCardsData
                                                                        .clear();
                                                                    data.clear();
                                                                    _isLoading =
                                                                        false;
                                                                  });
                                                                }
                                                              }

                                                              if (mounted &&
                                                                  context
                                                                      .mounted) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .hideCurrentSnackBar();
                                                              }
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    outer_background(),
                                                                foregroundColor:
                                                                    inner_background()),
                                                            child: Text("Undo"),
                                                          )
                                                        ],
                                                      ),
                                                      backgroundColor:
                                                          lightenColor(
                                                              Color(0xFF397ABC),
                                                              0.3),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      duration:
                                                          Duration(seconds: 3),
                                                    ));

                                                    // Delete from Firestore after delay if not undone
                                                    final currentContext =
                                                        context;
                                                    final currentCategory =
                                                        categoryToUpdate;

                                                    // Cancel any existing timer
                                                    _deleteTimer?.cancel();

                                                    _deleteTimer = Timer(
                                                        Duration(seconds: 5),
                                                        () async {
                                                      // Check if timer was cancelled or widget disposed
                                                      if (_deleteTimer ==
                                                              null ||
                                                          !_deleteTimer!
                                                              .isActive) {
                                                        return;
                                                      }

                                                      if (undoFlag && mounted) {
                                                        try {
                                                          // Also delete food_status if it exists
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "Hotels")
                                                              .doc(widget
                                                                  .hotel_loc)
                                                              .collection(
                                                                  "Menu")
                                                              .doc(
                                                                  currentCategory)
                                                              .update({
                                                            itemName: FieldValue
                                                                .delete(),
                                                            'food_status.$itemName':
                                                                FieldValue
                                                                    .delete(),
                                                          });

                                                          // Check mounted after async operation
                                                          if (!mounted) return;

                                                          // Refresh widget after Firestore deletion
                                                          if (mounted) {
                                                            setState(() {
                                                              _isLoading = true;
                                                            });
                                                          }

                                                          // Only refresh if selected_menu_map is not empty
                                                          if (widget
                                                              .selected_menu_map
                                                              .isNotEmpty) {
                                                            await fetch_menu_data(
                                                                widget
                                                                    .selected_menu_map,
                                                                widget.role);

                                                            // Check mounted after async operation
                                                            if (!mounted)
                                                              return;
                                                          } else {
                                                            // If map is empty, clear the UI
                                                            if (mounted) {
                                                              setState(() {
                                                                menu_names
                                                                    .clear();
                                                                menuCardsData
                                                                    .clear();
                                                                data.clear();
                                                                _isLoading =
                                                                    false;
                                                              });
                                                            }
                                                          }

                                                          if (mounted) {
                                                            setState(() {
                                                              _isLoading =
                                                                  false;
                                                            });
                                                          }
                                                        } catch (error) {
                                                          if (mounted &&
                                                              currentContext
                                                                  .mounted) {
                                                            showBounceSnackBar(
                                                                currentContext,
                                                                "Error deleting item: $error",
                                                                "fail");
                                                          }
                                                        }
                                                      }
                                                    });
                                                  }
                                                }
                                              },
                                              icon: Icon(Icons.delete),
                                              iconSize: isTablet
                                                  ? 28
                                                  : (isLandscape ? 22 : 25),
                                            ),
                                            Column(
                                              children: [
                                                Switch(
                                                  value: items_status_map[
                                                          menu_names[index]] ??
                                                      false,
                                                  onChanged:
                                                      (bool value) async {
                                                    print("IN SWITCH");
                                                    print(menu_names[index]);

                                                    if (items_status_map
                                                        .containsKey(menu_names[
                                                            index])) {
                                                      items_status_map[
                                                          menu_names[
                                                              index]] = value;
                                                    }

                                                    String category_to_edit =
                                                        "";
                                                    for (var map
                                                        in category_item_status_map) {
                                                      for (var category
                                                          in map.keys) {
                                                        if (map[category]
                                                                is Map<String,
                                                                    dynamic> &&
                                                            map[category]
                                                                .containsKey(
                                                                    menu_names[
                                                                        index])) {
                                                          map[category][
                                                                  menu_names[
                                                                      index]] =
                                                              value;
                                                          category_to_edit =
                                                              category;
                                                        }
                                                      }
                                                    }

                                                    if (category_to_edit
                                                        .isNotEmpty) {
                                                      // Check mounted before async operation
                                                      if (!mounted) return;

                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("Hotels")
                                                          .doc(widget.hotel_loc)
                                                          .collection("Menu")
                                                          .doc(category_to_edit)
                                                          .update({
                                                        "food_status.${menu_names[index]}":
                                                            value
                                                      });

                                                      // Check mounted after async operation
                                                      if (!mounted) return;

                                                      print(category_to_edit);
                                                      print(items_status_map);
                                                      print(
                                                          category_item_status_map);

                                                      // Add a loading state before fetching data
                                                      if (mounted) {
                                                        setState(() {
                                                          _isLoading =
                                                              true; // Set loading flag
                                                        });
                                                      }

                                                      await fetch_menu_data(
                                                          widget
                                                              .selected_menu_map,
                                                          widget.role);

                                                      // Check mounted after async operation
                                                      if (!mounted) return;

                                                      // After fetching, update the UI
                                                      if (mounted) {
                                                        setState(() {
                                                          _isLoading = false;
                                                        });
                                                      }
                                                    } else {
                                                      print(
                                                          "Error: Category not found!");
                                                    }
                                                  },
                                                  activeColor:
                                                      outer_background(),
                                                  inactiveThumbColor:
                                                      Colors.grey,
                                                  inactiveTrackColor:
                                                      Colors.grey.shade200,
                                                ),

                                                // Text("${items_status_map[menu_names[index]]}")
                                                Text(
                                                  items_status_map[
                                                          menu_names[index]]
                                                      ? "Available"
                                                      : "Unavailable",
                                                  style: TextStyle(
                                                    fontSize: isTablet
                                                        ? 14
                                                        : (isLandscape
                                                            ? 12
                                                            : 13),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Positioned Close Icon at Top Right
                            Positioned(
                              top: 1, // Adjust vertical positioning
                              right: 4, // Adjust horizontal positioning
                              child: GestureDetector(
                                onTap: () {
                                  if (menu_names.isNotEmpty &&
                                      index >= 0 &&
                                      index < menu_names.length) {
                                    String removedItem = menu_names[
                                        index]; // Store the item before removing

                                    if (mounted) {
                                      setState(() {
                                        // Clear list safely
                                        selectedCategories.remove(removedItem);
                                        filteredCategories.remove(removedItem);
                                        menu_names.removeAt(index);
                                        menu_Cards.removeAt(index);
                                        menuCardsData.removeWhere((map) =>
                                            map.containsKey(removedItem));

                                        for (var category
                                            in category_items_selected_map.keys
                                                .toList()) {
                                          if (category_items_selected_map[
                                                  category]!
                                              .contains(removedItem)) {
                                            category_items_selected_map[
                                                    category]!
                                                .remove(removedItem);
                                          }
                                        }
                                      });
                                    }

                                    print("Removed Item: $removedItem");
                                  } else {
                                    print(
                                        "Error: Trying to remove from an empty list or invalid index.");
                                  }
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          Colors.red, // Close button background
                                    ),
                                    // padding: EdgeInsets.all(1),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white, // Close icon color
                                      size: isTablet
                                          ? 20
                                          : (isLandscape ? 16 : 18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                    childCount: menu_names.length,
                  ),
                ),
            ],
          );
        }
      },
    );
  }
}
