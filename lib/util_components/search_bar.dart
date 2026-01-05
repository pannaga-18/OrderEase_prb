import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/Manager/confirm_order_dashboard.dart';
import 'package:orderease/util_components/build_category_cards.dart';
import 'package:orderease/util_components/build_menu_items.dart';
import 'package:orderease/util_components/profile.dart';
import 'package:orderease/util_components/util.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AnimatedSearchBar extends StatefulWidget {
  final String hotelref;
  final String role;
  final String table_option;
  AnimatedSearchBar(
      {super.key,
      required this.role,
      required this.hotelref,
      required this.table_option});
  @override
  _AnimatedSearchBarState createState() => _AnimatedSearchBarState();
}

// Items into 3 structure for Searching
List<String> category_list = [];
List<String> total_search_list = [];
Map<String, List<String>> category_items_map = {};
Map<String, List<String>> category_items_selected_map = {};
Map<String, Map<String, dynamic>> food_status_map = {};

// lists of category chips
var loc_hotelref;
List<String> filteredCategories = [];
List<String> selectedCategories = [];

// List of the respective Sections
List<String> categories_Cards = [];
List<String> menu_Cards = [];

bool isBlocked = false;
String? storedUID;

void get_search_items_Manager(
    BuildContext context, String loc_hotelref, String table_option) async {
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // isBlocked = prefs.getBool("isBlocked_${table_option}") ?? false;

  print("In get Manger Search");
  print(loc_hotelref);

  // Session Manager Info
  String? managedEmail;
  DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
      .collection("Hotels")
      .doc(loc_hotelref)
      .get();
  Map<String, dynamic> data;
  if (documentSnapshot.exists) {
    print("FF");
    data = documentSnapshot.data() as Map<String, dynamic>;
    print(data);
    isBlocked = data['table_status'][table_option][0];
    managedEmail = data['table_status'][table_option][1];
  }

  // Block warning
  if (isBlocked == false) {
    showBounceSnackBar(context, "Block the session!!", "warning");
  } else if (isBlocked == true) {
    String? cur_email = FirebaseAuth.instance.currentUser!.email;
    print(cur_email);
    print(managedEmail);
    if (cur_email != managedEmail) {
      showBounceSnackBar(
          context,
          "This session is already being managed by ${managedEmail}",
          "warning");
    }
  }

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("Hotels")
      .doc(loc_hotelref)
      .collection("Menu")
      .get();

  filteredCategories.clear();
  category_list.clear();
  total_search_list.clear();
  category_items_map.clear();
  category_items_selected_map.clear();

// MY Search PROCESS

  for (var doc in querySnapshot.docs) {
    // print(doc.id);
    category_list.add(doc.id);
    // total_search_list.add(doc.id);
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(loc_hotelref)
        .collection("Menu")
        .doc(doc.id)
        .get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      var items_names = data.keys.toList();
      print(items_names);
      print("OBJECT");
      items_names.remove("category_image_path");
      items_names.remove("food_status");
      // Properly cast food_status to Map<String, dynamic>
      if (data.containsKey('food_status') && data['food_status'] != null) {
        food_status_map[doc.id] =
            Map<String, dynamic>.from(data['food_status'] as Map);
      } else {
        food_status_map[doc.id] = <String, dynamic>{};
      }
      // removing unavailable food items from the search process.
      // items_names
      //     .removeWhere((item_name) => data['food_status'][item_name] == false);

      category_items_map[doc.id] = items_names;
      total_search_list.addAll(items_names);
    }
  }

  print(food_status_map);
  print(category_list);
  print(total_search_list);
  print(category_items_map);

  print("FILT");
  print(filteredCategories);
  print("sel");
  print(selectedCategories);
  print("CAT");
  print(categories_Cards);
}

// void get_search_items(
//   String loc_hotelref,
//   bool category_edit_status,
//   bool category_delete_status,
//   bool category_undo_status,
//   bool item_edit_status,
//   bool item_delete_status,
//   bool item_undo_status,
//   String oldCategory,
//   String new_category,
//   Map oldMenuItem,
//   Map newMenuItem,
// ) async {
//   // after Editing locally removing
//   if (category_edit_status == true) {
//     categories_Cards.remove(oldCategory);
//     categories_Cards.add(new_category);
//     selectedCategories.remove(oldCategory);
//     selectedCategories.add(new_category);
//   }

//   if (category_delete_status == true) {
//     // locally deleting
//     print("DELTE STATUS");
//     print(category_delete_status);
//     print(oldCategory);
//     categories_Cards.remove(oldCategory);
//     selectedCategories.remove(oldCategory);
//     filteredCategories.remove(oldCategory);
//   }

//   //   if(category_undo_status == true){
//   //   categories_Cards.add(oldCategory);
//   //   print("TTTT");
//   //   print(selectedCategories);
//   //   // selectedCategories.add(oldCategory);
//   //   filteredCategories.add(oldCategory);
//   // }

//   if (item_edit_status == true) {
//     // print(menu_Cards);

//     print("INISDE MENU EDIT");
//     print(oldMenuItem.keys.toList()[0]);
//     print(newMenuItem.keys.toList()[0]);
//     menu_Cards.remove(oldMenuItem.keys.toList()[0]);
//     menu_Cards.add(newMenuItem.keys.toList()[0]);

//     selectedCategories.remove(oldMenuItem.keys.toList()[0]);
//     selectedCategories.add(newMenuItem.keys.toList()[0]);

//     for (var category in category_items_selected_map.keys.toList()) {
//       if (category_items_selected_map[category]!
//           .contains(oldMenuItem.keys.toList()[0])) {
//         category_items_selected_map[category]!
//             .remove(oldMenuItem.keys.toList()[0]);
//         category_items_selected_map[category]!
//             .add(newMenuItem.keys.toList()[0]);
//         break;
//       }
//     }

//     print(menu_Cards);
//     print("wer");
//     print(selectedCategories);

//     // this is printing but not able to build due TO NULL SOLVE
//     print(category_items_selected_map);

//     print("PPASDAD");
//   }

//   if (item_delete_status == true) {
//     print(oldCategory);
//     menu_Cards.remove(oldCategory);
//     selectedCategories.remove(oldCategory);
//     filteredCategories.remove(oldCategory);
//     for (var category in category_items_selected_map.keys.toList()) {
//       if (category_items_selected_map[category]!.contains(oldCategory)) {
//         category_items_selected_map[category]!.remove(oldCategory);
//         break;
//       }
//     }
//   }

//   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//       .collection("Hotels")
//       .doc(loc_hotelref)
//       .collection("Menu")
//       .get();

//   filteredCategories.clear();
//   category_list.clear();
//   total_search_list.clear();
//   category_items_map.clear();
//   category_items_selected_map.clear();

//   for (var doc in querySnapshot.docs) {
//     print(doc.id);
//     category_list.add(doc.id);
//     total_search_list.add(doc.id);
//   }

//   // Fetch all documents in parallel to improve performance
//   List<Future<DocumentSnapshot>> fetchFutures = category_list.map((categoryId) {
//     return FirebaseFirestore.instance
//         .collection("Hotels")
//         .doc(loc_hotelref)
//         .collection("Menu")
//         .doc(categoryId)
//         .get();
//   }).toList();

//   // Wait for all Firestore fetch operations to complete
//   List<DocumentSnapshot> documentSnapshots = await Future.wait(fetchFutures);

//   for (var docSnapshot in documentSnapshots) {
//     if (docSnapshot.exists) {
//       Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

//       print(data);
//       print("Filtering available food");

//       // Remove "category_image_path" and food_status if it exists
//       List<String> items_names = data.keys.toList();
//       items_names.removeWhere(
//           (key) => key == "category_image_path" || key == "food_status");

//       // Properly cast food_status to Map<String, dynamic>
//       if (data.containsKey('food_status') && data['food_status'] != null) {
//         food_status_map[docSnapshot.id] = Map<String, dynamic>.from(data['food_status'] as Map);
//       } else {
//         food_status_map[docSnapshot.id] = <String, dynamic>{};
//       }

//       // removing unavailable food items from the search process.
//       // items_names.removeWhere((item_name) => data['food_status'][item_name] == false);

//       category_items_map[docSnapshot.id] = items_names;
//       total_search_list.addAll(items_names);
//     }
//   }

//   print(category_list);
//   print(total_search_list);
//   print(category_items_map);

//   print("FILT");
//   print(filteredCategories);
//   print("sel");
//   print(selectedCategories);
//   print("CAT");
//   print(categories_Cards);
//   print(category_items_selected_map);
// }

void get_search_items(
  String loc_hotelref,
  bool category_edit_status,
  bool category_delete_status,
  bool category_undo_status,
  bool item_edit_status,
  bool item_delete_status,
  bool item_undo_status,
  String oldCategory,
  String new_category,
  Map oldMenuItem,
  Map newMenuItem,
) async {
  // after Editing locally removing
  if (category_edit_status == true) {
    categories_Cards.remove(oldCategory);
    categories_Cards.add(new_category);
    selectedCategories.remove(oldCategory);
    selectedCategories.add(new_category);
  }

  if (category_delete_status == true) {
    // locally deleting
    print("DELETE STATUS");
    print(category_delete_status);
    print(oldCategory);
    categories_Cards.remove(oldCategory);
    selectedCategories.remove(oldCategory);
    filteredCategories.remove(oldCategory);
  }

  if (item_edit_status == true) {
    print("INSIDE MENU EDIT");
    String oldItemName = oldMenuItem.keys.toList()[0];
    String newItemName = newMenuItem.keys.toList()[0];

    print("Old Item: $oldItemName");
    print("New Item: $newItemName");

    // Update menu_Cards
    menu_Cards.remove(oldItemName);
    menu_Cards.add(newItemName);

    // Update selectedCategories
    selectedCategories.remove(oldItemName);
    selectedCategories.add(newItemName);

    // Update category_items_selected_map
    String? categoryKey;
    for (var category in category_items_selected_map.keys.toList()) {
      if (category_items_selected_map[category]!.contains(oldItemName)) {
        category_items_selected_map[category]!.remove(oldItemName);
        category_items_selected_map[category]!.add(newItemName);
        categoryKey = category;
        break;
      }
    }

    print("Updated menu_Cards: $menu_Cards");
    print("Updated selectedCategories: $selectedCategories");
    print("Updated category_items_selected_map: $category_items_selected_map");

    // DON'T fetch from Firestore immediately - just update local state
    // The calling function will handle the Firestore fetch with proper delay
    return;
  }

  if (item_delete_status == true) {
    print(oldCategory);
    menu_Cards.remove(oldCategory);
    selectedCategories.remove(oldCategory);
    filteredCategories.remove(oldCategory);
    for (var category in category_items_selected_map.keys.toList()) {
      if (category_items_selected_map[category]!.contains(oldCategory)) {
        category_items_selected_map[category]!.remove(oldCategory);
        break;
      }
    }
  }

  // Fetch from Firestore for all other cases
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("Hotels")
      .doc(loc_hotelref)
      .collection("Menu")
      .get();

  filteredCategories.clear();
  category_list.clear();
  total_search_list.clear();
  category_items_map.clear();
  // DON'T clear category_items_selected_map here - it needs to persist

  for (var doc in querySnapshot.docs) {
    print(doc.id);
    category_list.add(doc.id);
    total_search_list.add(doc.id);
  }

  // Fetch all documents in parallel to improve performance
  List<Future<DocumentSnapshot>> fetchFutures = category_list.map((categoryId) {
    return FirebaseFirestore.instance
        .collection("Hotels")
        .doc(loc_hotelref)
        .collection("Menu")
        .doc(categoryId)
        .get();
  }).toList();

  // Wait for all Firestore fetch operations to complete
  List<DocumentSnapshot> documentSnapshots = await Future.wait(fetchFutures);

  for (var docSnapshot in documentSnapshots) {
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      print(data);
      print("Filtering available food");

      // Remove "category_image_path" and food_status if it exists
      List<String> items_names = data.keys.toList();
      items_names.removeWhere(
          (key) => key == "category_image_path" || key == "food_status");

      // Properly cast food_status to Map<String, dynamic>
      if (data.containsKey('food_status') && data['food_status'] != null) {
        food_status_map[docSnapshot.id] =
            Map<String, dynamic>.from(data['food_status'] as Map);
      } else {
        food_status_map[docSnapshot.id] = <String, dynamic>{};
      }

      category_items_map[docSnapshot.id] = items_names;
      total_search_list.addAll(items_names);
    }
  }

  print("Updated category_list: $category_list");
  print("Updated total_search_list: $total_search_list");
  print("Updated category_items_map: $category_items_map");
  print("Updated food_status_map: $food_status_map");
  print("Final category_items_selected_map: $category_items_selected_map");
}

// Also add this helper function to manually refresh search items after edit
Future<void> refresh_search_items_after_edit(String loc_hotelref) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("Hotels")
      .doc(loc_hotelref)
      .collection("Menu")
      .get();

  filteredCategories.clear();
  category_list.clear();
  total_search_list.clear();
  category_items_map.clear();
  food_status_map.clear();

  for (var doc in querySnapshot.docs) {
    category_list.add(doc.id);
    total_search_list.add(doc.id);
  }

  // Fetch all documents in parallel
  List<Future<DocumentSnapshot>> fetchFutures = category_list.map((categoryId) {
    return FirebaseFirestore.instance
        .collection("Hotels")
        .doc(loc_hotelref)
        .collection("Menu")
        .doc(categoryId)
        .get();
  }).toList();

  List<DocumentSnapshot> documentSnapshots = await Future.wait(fetchFutures);

  for (var docSnapshot in documentSnapshots) {
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      List<String> items_names = data.keys.toList();
      items_names.removeWhere(
          (key) => key == "category_image_path" || key == "food_status");

      if (data.containsKey('food_status') && data['food_status'] != null) {
        food_status_map[docSnapshot.id] =
            Map<String, dynamic>.from(data['food_status'] as Map);
      } else {
        food_status_map[docSnapshot.id] = <String, dynamic>{};
      }

      category_items_map[docSnapshot.id] = items_names;
      total_search_list.addAll(items_names);
    }
  }

  print("Refreshed search items successfully");
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  final List<String> hints = [
    "Search here...",
    "Find items...",
    "Explore categories..."
  ];
  int _currentHintIndex = 0;
  TextEditingController _searchController = TextEditingController();
  Timer? _hintTimer; // Store timer reference to cancel on dispose
  Timer? _debounceTimer; // Timer for debouncing search

  // Preprocess
  String searched_category_upon_items = "";
  String searched_menu_item = "";

  // QR Status
  bool qr_status = false;
  String previous_table_session_id = "";

  @override
  void dispose() {
    // Cancel any pending timers to prevent setState after dispose
    _hintTimer?.cancel();
    _hintTimer = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    // Properly remove the listener
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void toggleCategorySelection(String category) {
    if (!mounted) return;
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
        categories_Cards.remove(category);
        menu_Cards.remove(category);

        // category_items_selected_map.remove(categ)
        print("FFFFFF11111");

        // selected map inda deselect maddu
        for (var i in category_items_selected_map.keys.toList()) {
          if (category_items_selected_map[i]!.contains(category)) {
            category_items_selected_map[i]!.remove(category);
          }
        }
        print(category_items_selected_map);
      }

      // initially selected cards will be empty comes here
      // and checks here if it is category adds into category cards list
      // else adds into menu_items_list
      else {
        // category alli idre
        if (category_list.contains(category)) {
          categories_Cards.add(category);
          print("FFFFFF");
          print(categories_Cards);
        }
        // menu_items in total_list
        else if (total_search_list.contains(category)) {
          menu_Cards.add(category);
          searched_category_upon_items = "";
          searched_menu_item = "";
          for (var i in category_items_map.keys.toList()) {
            if (category_items_map[i]!.contains(category)) {
              searched_category_upon_items = i;
              searched_menu_item = category;

              // idre append maadu
              if (category_items_selected_map
                      .containsKey(searched_category_upon_items) &&
                  !category_items_selected_map[searched_category_upon_items]!
                      .contains(searched_menu_item)) {
                //
                category_items_selected_map[searched_category_upon_items]!
                    .add(searched_menu_item);
              }
              // insert new
              else {
                //
                print("object");
                category_items_selected_map[searched_category_upon_items] = [
                  searched_menu_item
                ];
              }
              break;
            }
          }
        }
        print("MENU ITEMS");
        print(searched_category_upon_items);
        print(searched_menu_item);
        print(category_items_selected_map);
        selectedCategories.add(category);
      }
    });
  }

  late bool isBlocked = false;

  void get_table_status() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.hotelref)
        .get();
    if (documentSnapshot.exists) {
      var data = documentSnapshot.data();
      Map<String, dynamic> hotel_data = data as Map<String, dynamic>;
      if (hotel_data.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          isBlocked = hotel_data['table_status'][widget.table_option][0];
        });
      }
      print("ASDsdewer");
      print(data['table_status'][widget.table_option]);
    }
  }

  @override
  void initState() {
    super.initState();

    loc_hotelref = widget.hotelref;

    // selectedCategories = [];
    // categories_Cards = [];
    // filteredCategories = [];
    // menu_Cards = [];

    selectedCategories.clear();
    categories_Cards.clear();
    filteredCategories.clear();
    menu_Cards.clear();
    qr_status = false;
    print(loc_hotelref);
    print("LOCAL");

    if (widget.role == "Admin") {
      get_search_items(loc_hotelref, false, false, false, false, false, false,
          "", "", {}, {});
    } else if (widget.role == "Manager") {
      // get_table_status();

      get_search_items_Manager(context, loc_hotelref, widget.table_option);
      _loadStoredData();
    }

    _hintTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      // Check if timer was cancelled (widget disposed)
      if (_hintTimer == null || !_hintTimer!.isActive) {
        return;
      }
      if (mounted) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % hints.length;
        });
      } else {
        timer.cancel();
        _hintTimer = null;
      }
    });

    // Event Listener with debouncing
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (!mounted) return; // Early return if widget is disposed
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      if (mounted) {
        filterCategories(_searchController.text);
      }
    });
  }

  void filterCategories(String query) {
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        filteredCategories.clear(); // Hide categories when input is empty
      } else {
        filteredCategories = total_search_list
            .where((category) => isNearlyEquivalent(category, query))
            .toSet()
            .toList();
      }
    });
  }

  bool isNearlyEquivalent(String category, String query) {
    query = query.toLowerCase();
    category = category.toLowerCase();

    if (category.startsWith(query)) {
      return true; // Direct match or starts with query
    }

    int matchCount = 0;
    for (int i = 0; i < query.length; i++) {
      if (category.contains(query[i])) {
        matchCount++;
      }
    }

    double similarity = matchCount / category.length;
    return similarity >= 0.6; // Show if at least 60% similar
  }

  // Structure S3 for local Storing and Updation
  Map<String, Map<String, dynamic>> tableData = {};

// Save Data to Local (SharedPreferences and Map)
  Future<void> _saveToLocal(bool status, String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save the basic data
    await prefs.setBool("isBlocked_${widget.table_option}", status);
    await prefs.setString("uid_${widget.table_option}", uid);

    // Create composite key
    String mapKey = "${uid}_${widget.table_option}";

    // Check if a session already exists for the table
    bool alreadyCreated =
        tableData.keys.any((key) => key.split("_")[1] == widget.table_option);

    // If no session exists, create one
    if (!alreadyCreated) {
      tableData[mapKey] = {
        "status": status,
        "timestamp": DateTime.now().toIso8601String(),
      };
    }

    // Save the updated map to SharedPreferences
    String mapJson = jsonEncode(tableData);
    await prefs.setString('tableData', mapJson);

    print("Data Saved: $mapKey -> ${tableData[mapKey]}");
  }

// Remove Data from Local (SharedPreferences and Map)
  Future<void> _removeFromLocal() async {
    if (!mounted) return; // Early return if widget is disposed

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check again after async operation
    if (!mounted) return;

    storedUID = prefs.getString("uid_${widget.table_option}");
    print(storedUID);
    print("UID TO DELETE");

    if (storedUID != null) {
      // Form composite key to remove from map
      String mapKey = "${storedUID}_${widget.table_option}";

      print("MP $mapKey");
      // tableData.remove(mapKey);

      // Load the map from SharedPreferences
      String? mapJson = prefs.getString('tableData');
      print("MPJSON $mapJson");
      if (mapJson != null) {
        print("clear data 3");
        Map<String, dynamic> decodedData = jsonDecode(mapJson);

        // NOTE
        // MAP ENTRY IS A CONSTRUCTOR providing key and value as the OUTPUT
        // .from method helps to retain the value as MAP itself instead of object.

        tableData = decodedData.map((key, value) => MapEntry(
              key,
              Map<String, dynamic>.from(value),
            ));
        tableData.remove(mapKey);
      }

      print(tableData);
      print("After 3");

      // Update SharedPreferences
      String mapJson1 = jsonEncode(tableData);
      await prefs.setString('tableData', mapJson1);

      // Check again after async operation
      if (!mounted) return;

      print("Data Removed: $mapKey");
      previous_table_session_id = mapKey;

      await prefs.remove("isBlocked_${widget.table_option}");
      await prefs.remove("uid_${widget.table_option}");

      // Final check before setState
      if (!mounted) return;
      setState(() {
        isBlocked = false;
        storedUID = null;
        tableData = tableData;
        qr_status = true;
        previous_table_session_id = previous_table_session_id;
      });
    }
  }

// Load Data from Local (Fetch from SharedPreferences or Map)
  // Future<void> _loadStoredData() async {
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
    
  //   DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //       .collection("Hotels")
  //       .doc(loc_hotelref)
  //       .get();
  //   Map<String, dynamic> data;
  //   if (documentSnapshot.exists) {
  //     print("FF");
  //     print("PPP status");
  //     data = documentSnapshot.data() as Map<String, dynamic>;
  //     print(data);
  //     storedStatus = data['table_status'][widget.table_option][0];
  //   }

  //   print("LOADED MAP DATA");
  //   print(tableData);
  //   print(storedStatus);
  //   print(uid);

  //   if (storedStatus != null && uid != null) {
  //     String mapKey = "${uid}_${widget.table_option}";
  //     print("Clear data 1");
  //     DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //         .collection("Hotels")
  //         .doc(widget.hotelref)
  //         .get();
  //     Map<String, dynamic> data = {};
  //     if (documentSnapshot.exists) {
  //       data = documentSnapshot.data() as Map<String, dynamic>;
  //     }

  //     print("DATA FROM FIREBASE");
  //     print(data);

  //     // Clearing from manager's device
  //     if (data['table_status'][widget.table_option][0] == false) {
  //       print("clear data 2");
  //       await _removeFromLocal();
  //       return;
  //     }

  //     if (tableData.containsKey(mapKey)) {
  //       // Load from map if available
  //       if (!mounted) return;
  //       setState(() {
  //         isBlocked = tableData[mapKey]!['status'];
  //         storedUID = uid;
  //       });
  //       print("Data Loaded from Map: $mapKey -> ${tableData[mapKey]}");
  //     } else {
  //       // Fallback to SharedPreferences if not in map
  //       if (!mounted) return;
  //       setState(() {
  //         isBlocked = storedStatus;
  //         storedUID = uid;
  //       });
  //       print("Data Loaded from SharedPreferences for ${widget.table_option}");
  //     }
  //   } else {
  //     if (!mounted) return;
  //     setState(() {
  //       isBlocked = false;
  //       storedUID = null;
  //     });
  //     print("No Data Found for ${widget.table_option}");
  //   }
  // }

   Future<void> _loadStoredData() async {
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
    bool storedStatus = prefs.getBool("isBlocked_${widget.table_option}") ?? false;
    String? uid = prefs.getString("uid_${widget.table_option}");
    print("1 st $storedStatus");

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(loc_hotelref)
        .get();
    Map<String, dynamic> data;
    if (documentSnapshot.exists) {
      print("FF");
      print("PPP status");
      data = documentSnapshot.data() as Map<String, dynamic>;
      print(data);
      storedStatus = data['table_status'][widget.table_option][0];
    }

    print("LOADED MAP DATA");
    print(tableData);
    print(storedStatus);
    print(uid);

    if (storedStatus != null && uid != null) {
      String mapKey = "${uid}_${widget.table_option}";
      print("Clear data 1");
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.hotelref)
          .get();
      Map<String, dynamic> data = {};
      if (documentSnapshot.exists) {
        data = documentSnapshot.data() as Map<String, dynamic>;
      }

      print("DATA FROM FIREBASE");
      print(data);

      // Clearing from manager's device
      if (data['table_status'][widget.table_option][0] == false) {
        print("clear data 2");
        await _removeFromLocal();
        return;
      }

      if (tableData.containsKey(mapKey)) {
        // Load from map if available
        if (!mounted) return;
        setState(() {
          isBlocked = tableData[mapKey]!['status'];
          storedUID = uid;
        });
        print("Data Loaded from Map: $mapKey -> ${tableData[mapKey]}");
      } else {
        // Fallback to SharedPreferences if not in map
        if (!mounted) return;
        setState(() {
          isBlocked = storedStatus;
          storedUID = uid;
        });

        print("Data Loaded from SharedPreferences for ${widget.table_option}");
      }
    } else {
      if (!mounted) return;
      setState(() {
        isBlocked = storedStatus;
        storedUID = storedUID;
      });
      print("No Data Found for ${widget.table_option}");
    }
  }


  Future<void> _deletePreferences() async {
    // TO CLEAR LOCAL STORGAE

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("isBlocked_${widget.table_option}");
    await prefs.remove("uid_${widget.table_option}");
    await prefs.remove("tableData");
    print("CLEARED ALL PREFS");
  }

  Future<void> _toggleSwitch() async {
    if (!mounted) return;
    setState(() {
      isBlocked = !isBlocked;
    });
    print("coming");
    print(isBlocked);
    String? email = FirebaseAuth.instance.currentUser!.email;
    String msg = (isBlocked) ? "blocked" : "unblocked";
    if (isBlocked) {
      // Generate a new UID and store data
      String uniqueID = Uuid().v4();
      await _saveToLocal(true, uniqueID);
      if (!mounted) return; // Check after async
      print("Table Blocked with UID: $uniqueID");

      // Update Firestore
      DocumentReference hotelRef =
          FirebaseFirestore.instance.collection("Hotels").doc(widget.hotelref);
      DocumentSnapshot snapshot = await hotelRef.get();
      if (!mounted) return; // Check after async

      print("Current MAnager $email");

      // Log
      String session_id = "${uniqueID}_${widget.table_option}";

      await addLogEntry(
        hotelId: widget.hotelref,
        userEmail: email ?? "",
        action: "${widget.table_option} $msg.",
        tableNumber: widget.table_option,
        sessionId: session_id,
      );

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey("table_status") &&
            data["table_status"] is Map<String, dynamic>) {
          await hotelRef.update({
            "table_status.${widget.table_option}": [true, email]
          });
        }
      }
    } else {
      // Retrieve stored UID and remove data

      // Check if data exists in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!mounted) return; // Check after async
      bool? storedStatus = prefs.getBool("isBlocked_${widget.table_option}");
      String? storedUID = prefs.getString("uid_${widget.table_option}");
      String? uniqueID = storedUID;
      print("coming1");
      print(uniqueID);

      // Log
      String session_id = "${uniqueID}_${widget.table_option}";

      await addLogEntry(
        hotelId: widget.hotelref,
        userEmail: email ?? "",
        action: "${widget.table_option} $msg.",
        tableNumber: widget.table_option,
        sessionId: session_id,
      );

      if (uniqueID != null) {
        await _removeFromLocal();
        if (!mounted) return; // Check after async

        print("After settlements1");

        // Update Firestore
        DocumentReference hotelRef = FirebaseFirestore.instance
            .collection("Hotels")
            .doc(widget.hotelref);
        DocumentSnapshot snapshot = await hotelRef.get();
        if (!mounted) return; // Check after async

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          if (data.containsKey("table_status") &&
              data["table_status"] is Map<String, dynamic>) {
            await hotelRef.update({
              "table_status.${widget.table_option}": [false, ""]
            });
          }
        }

        // DocumentSnapshot documentSnapshot1 = await FirebaseFirestore.instance
        //     .collection("Hotels")
        //     .doc(widget.hotelref)
        //     .collection("Bill")
        //     .doc("${uniqueID}_${widget.table_option}")
        //     .get();

        // if (documentSnapshot1.exists) {
        //   await hotelRef
        //       .collection("Bill")
        //       .doc("${uniqueID}_${widget.table_option}")
        //       .delete();
        //   print("DOC DEELTED FROM BILL");
        // }

        // DocumentSnapshot documentSnapshot2 = await FirebaseFirestore.instance
        //     .collection("Hotels")
        //     .doc(widget.hotelref)
        //     .collection("Cook")
        //     .doc("${uniqueID}_${widget.table_option}")
        //     .get();

        // if (documentSnapshot1.exists) {
        //   await hotelRef
        //       .collection("Cook")
        //       .doc("${uniqueID}_${widget.table_option}")
        //       .delete();
        //   print("DOC DEELTED FROM COOK");
        // }

        // DocumentSnapshot documentSnapshot3 = await FirebaseFirestore.instance
        //     .collection("Hotels")
        //     .doc(widget.hotelref)
        //     .collection("Transactions")
        //     .doc("${uniqueID}_${widget.table_option}")
        //     .get();

        // if (documentSnapshot3.exists) {
        //   await hotelRef
        //       .collection("Transactions")
        //       .doc("${uniqueID}_${widget.table_option}")
        //       .delete();
        //   print("DOC DEELTED FROM COOK");
        // }

        print("Table Unblocked and removed from Firestore: $uniqueID");
      }
    }
  }

  // bool search_click_status = true;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenHeight < screenWidth;
    final padding = isTablet ? 12.0 : 16.0;
    print(isTablet);
    print("ISTAB");

    return Scaffold(
      backgroundColor: inner_background(),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: outer_background(),
        elevation: 0,
        title: Text(
          widget.table_option,
          style: TextStyle(
              fontSize: isTablet ? 24 : (isLandscape ? 18 : 20),
              color: inner_background(),
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          if (widget.role == "Manager")
            Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: isBlocked
                          ? [
                              Color(0xFFC0392B),
                              Color(0xFFE74C3C)
                            ] // Red Gradient
                          : [
                              Color(0xFF27AE60),
                              Color(0xFF2ECC71)
                            ], // Green Gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : (isLandscape ? 20 : 30),
                          vertical: isLandscape ? 8 : 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext dialogContext) => AlertDialog(
                          title: Text(
                              isBlocked ? "Unblock Table?" : "Block Table?"),
                          content: Text(
                            isBlocked
                                ? "Do you want to mark this table as Vacant?"
                                : "Do you want to Block this table?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text("No"),
                              style: TextButton.styleFrom(
                                  foregroundColor: outer_background()),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: outer_background(),
                                  foregroundColor: inner_background()),
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                _toggleSwitch();
                                // _deletePreferences();
                              },
                              child: Text("Yes"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isBlocked ? Icons.lock : Icons.lock_open,
                          color: Colors.white,
                          size: isLandscape ? 16 : 20,
                        ),
                        SizedBox(width: isLandscape ? 6 : 10),
                        Text(
                          isBlocked ? "Blocked" : "Vacant",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isLandscape ? 14 : 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

          // Clear Local Storage
          if (qr_status)
            IconButton(
                onPressed: () {
                  // _deletePreferences();
                  // showStatusSnackBar(context, "Deleted PREF", "warning");
                  print("PREV ID");
                  print(previous_table_session_id);
                  showQR(context, widget.hotelref, widget.table_option, 0,
                      "bill_status", previous_table_session_id, true);
                  setState(() {
                    qr_status = false;
                  });
                },
                icon: Icon(
                  Icons.qr_code_2_rounded,
                  color: inner_background(),
                )),

          ProfileButton(
              context: context, hotelref: widget.hotelref, isTablet: isTablet)
        ],
      ),
      body: isLandscape
          ? landscapeLayout(padding, isTablet)
          : portraitLayout(padding, isTablet),
    );
  }

  Widget portraitLayout(double padding, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final availableHeight = constraints.maxHeight - keyboardHeight;
        // Increased from 0.6 to 0.75 to show more menu cards (was showing only 1-1.5 cards)
        final menuMaxHeight = availableHeight > 500
            ? (availableHeight * 0.75)
            : (availableHeight * 0.7);

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: availableHeight,
            ),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: padding, vertical: padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Bar
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: isTablet ? 800 : 600),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            fontSize: isTablet ? 18 : 16, color: Colors.grey),
                        hintText: hints[_currentHintIndex], // Dynamic hint text
                        contentPadding: EdgeInsets.symmetric(
                            vertical: isTablet ? 18 : 15, horizontal: 16),
                      ),
                      style: TextStyle(fontSize: isTablet ? 18 : 16),
                    ),
                  ),
                  SizedBox(height: isTablet ? 24 : 20),

                  // Category Section (Only appears when there are matches)
                  if (filteredCategories.isNotEmpty &&
                      widget.role == "Admin") ...[
                    Text(
                      "Top Searches",
                      style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: isTablet ? 12 : 10),
                    Wrap(
                      spacing: isTablet ? 12 : 8,
                      runSpacing: isTablet ? 12 : 8,
                      children: filteredCategories
                          .map((category) => ChoiceChip(
                                label: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 8 : 4),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                selected: selectedCategories.contains(category),
                                onSelected: (selected) {
                                  toggleCategorySelection(category);
                                },
                                selectedColor: outer_background(),
                                labelStyle: TextStyle(
                                  color: selectedCategories.contains(category)
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                backgroundColor: Colors.grey[200],
                                padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 8 : 4),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: isTablet ? 24 : 20),
                  ],

                  // Selected Categories Section (Horizontal Scrolling)
                  if (categories_Cards.isNotEmpty &&
                      widget.role == "Admin") ...[
                    Text(
                      "Selected Category",
                      style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: isTablet ? 12 : 10),
                    // Horizontal Scroll
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          build_category_cards(
                            key: ValueKey(categories_Cards.length),
                            href: widget.hotelref,
                            categories_Cards: categories_Cards,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                  ],

                  // Menu Items Section (Vertical Scrolling inside a limited height)
                  if (menu_Cards.isNotEmpty && widget.role == "Admin") ...[
                    // Vertical Scroll
                    Text(
                      "Your Meals..",
                      style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: isTablet ? 12 : 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: menuMaxHeight,
                        minHeight:
                            250, // Increased from 200 to show more content
                      ),
                      child: build_menu_cards(
                        key: ValueKey(menu_Cards.length),
                        hotel_loc: widget.hotelref,
                        selected_menu_map: category_items_selected_map,
                        role: "Admin",
                        table_option: "",
                        food_status_map: food_status_map,
                      ),
                    ),
                  ],

                  if (filteredCategories.isNotEmpty &&
                      widget.role == "Manager") ...[
                    Text(
                      "Top Searches",
                      style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: isTablet ? 12 : 10),
                    Wrap(
                      spacing: isTablet ? 12 : 8,
                      runSpacing: isTablet ? 12 : 8,
                      children: filteredCategories
                          .map((category) => ChoiceChip(
                                label: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 8 : 4),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                selected: selectedCategories.contains(category),
                                onSelected: (selected) {
                                  toggleCategorySelection(category);
                                },
                                selectedColor: outer_background(),
                                labelStyle: TextStyle(
                                  color: selectedCategories.contains(category)
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                backgroundColor: Colors.grey[200],
                                padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 8 : 4),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: isTablet ? 12 : 10),
                  ],

                  if (menu_Cards.isNotEmpty && widget.role == "Manager") ...[
                    // Vertical Scroll
                    Text(
                      "Your Meals..",
                      style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: isTablet ? 12 : 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: menuMaxHeight,
                        minHeight:
                            250, // Increased from 200 to show more content
                      ),
                      child: build_menu_cards(
                        key: ValueKey(menu_Cards.length),
                        hotel_loc: widget.hotelref,
                        selected_menu_map: category_items_selected_map,
                        role: "Manager",
                        table_option: widget.table_option,
                        food_status_map: food_status_map,
                      ),
                    ),
                  ],

                  SizedBox(height: 70),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget landscapeLayout(double padding, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Bar
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                      maxWidth: isTablet ? 1200 : constraints.maxWidth),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          fontSize: isTablet ? 18 : 16, color: Colors.grey),
                      hintText: hints[_currentHintIndex],
                      contentPadding: EdgeInsets.symmetric(
                          vertical: isTablet ? 16 : 12, horizontal: 16),
                    ),
                    style: TextStyle(fontSize: isTablet ? 18 : 16),
                  ),
                ),

                SizedBox(height: 16),

                // Top Searches Section
                if (filteredCategories.isNotEmpty) ...[
                  Text(
                    "Top Searches",
                    style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filteredCategories
                        .map((category) => ChoiceChip(
                              label: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                      fontSize: isTablet ? 15 : 13,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              selected: selectedCategories.contains(category),
                              onSelected: (selected) {
                                toggleCategorySelection(category);
                              },
                              selectedColor: outer_background(),
                              labelStyle: TextStyle(
                                color: selectedCategories.contains(category)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              backgroundColor: Colors.grey[200],
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 16),
                ],

                /// ---------------------------
                /// CATEGORY SELECTOR (HORIZONTAL)
                /// ---------------------------
                if (categories_Cards.isNotEmpty) ...[
                  Text(
                    "Selected Category",
                    style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  /// Horizontal scroll container
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories_Cards.isNotEmpty
                          ? [
                              build_category_cards(
                                key: ValueKey(categories_Cards.length),
                                href: widget.hotelref,
                                categories_Cards: categories_Cards,
                              )
                            ]
                          : [],
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                /// ---------------------------
                /// MENU ITEMS (VERTICAL LIST)
                /// ---------------------------
                if (menu_Cards.isNotEmpty) ...[
                  Text(
                    "Your Meals",
                    style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  /// Vertical scroll list INSIDE main scroll
                  ///
                  /// Need bounded height for CustomScrollView
                  LayoutBuilder(
                    builder: (context, menuConstraints) {
                      // Increased from 0.6 to 0.75 to show more menu cards in landscape
                      final maxHeight = constraints.maxHeight;
                      final minHeight =
                          maxHeight > 250 ? 250.0 : maxHeight * 0.5;
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: maxHeight,
                          minHeight: minHeight,
                        ),
                        child: build_menu_cards(
                          key: ValueKey(menu_Cards.length),
                          hotel_loc: widget.hotelref,
                          selected_menu_map: category_items_selected_map,
                          role: widget.role,
                          table_option: widget.table_option,
                          food_status_map: food_status_map,
                        ),
                      );
                    },
                  ),
                ],

                SizedBox(height: 70),
              ],
            ),
          ),
        );
      },
    );
  }
}
