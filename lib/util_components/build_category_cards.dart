import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/menu/add_category.dart';
import 'package:orderease/Admin/menu/menu.dart';
import 'package:orderease/Admin/menu/menu_dashboard.dart';
import 'package:orderease/util_components/bottom_navbar.dart';
import 'package:orderease/util_components/search_bar.dart';
import 'package:orderease/util_components/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class build_category_cards extends StatefulWidget {
  final String href;
  final List<String> categories_Cards;
  // final Function(List<String>) onCategoriesUpdate; // New callback function
  const build_category_cards({
    super.key,
    required this.href,
    required this.categories_Cards,
  });

  @override
  _BuildCategoryCardsState createState() => _BuildCategoryCardsState();
}

List<String> cardTitles = [];
Map imagePaths = {};
// Map imagePaths

Future<void> get_data(
    String label, String href, List<String> searched_category_cards) async {
  Dash_label = label;
  hotel_loc = href;

  var i = 0;
  print("Inside get_data searched data ${searched_category_cards}");

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("Hotels")
      .doc(hotel_loc)
      .collection("Menu")
      .get();

  if (querySnapshot.size != 0) {
    show_text_status = false;

    cardTitles = [];
    imagePaths = {};
    for (var doc in querySnapshot.docs) {
      if (searched_category_cards.contains(doc.id)) {
        cardTitles.add(doc.id);

        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("Hotels")
            .doc(hotel_loc)
            .collection("Menu")
            .doc(doc.id)
            .get();
        var data = documentSnapshot.data() as Map<String, dynamic>;

        imagePaths[doc.id] = data['category_image_path'];
      }
    }

    i += 1;
    print("df $i");
    print(imagePaths);

    print("CARD TITLES");
    print(cardTitles);

    // print("MEnu idid00");
  } else {
    cardTitles = [];
    show_text_status = true;
    print("MEnu bbbbbbb00");
  }
}

TextEditingController editCategoryController = TextEditingController();
// Future<Map<String, dynamic>> _showInputDialog(
//     BuildContext context, String msg, String category) async {
//   final _formKey = GlobalKey<FormState>(); // Form key to validate the form
//   String _inputValue = ''; // Variable to store the input value

//   // Setting edit category to existing value
//   editCategoryController = TextEditingController(text: category);
//   return await showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text(
//                 msg,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 overflow: TextOverflow.clip,
//                 softWrap: true,
//               ),
//               content: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextFormField(
//                       controller: editCategoryController,
//                       decoration: InputDecoration(
//                         enabledBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Colors.grey), // Color when not focused
//                         ),
//                         focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(
//                               color: outer_background()), // Color when focused
//                         ),
//                         labelText: "New Category Name",
//                       ),
//                       validator: (value) {
//                         if ((value == null || value.isEmpty)) {
//                           return 'Field should not be empty';
//                         }
//                         return null;
//                       },
//                       onChanged: (value) async {
//                         _inputValue = value;
//                       },
//                     )
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(
//                       {
//                         'edit_status': false,
//                         "old_cat": "",
//                         "new_cat": ""
//                       }
//                     ); // Close the dialog
//                   },

//                   // Adding style to button
//                   style: TextButton.styleFrom(
//                     backgroundColor: inner_background(),
//                     foregroundColor: outer_background(),
//                   ),
//                   child: Text(
//                     'Cancel',
//                     style: TextStyle(color: outer_background()),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (_formKey.currentState!.validate()) {
//                       // If form is valid, proceed

//                       // getting old record
//                       var oldCate = category;
//                       DocumentSnapshot documentSnapshot =
//                           await FirebaseFirestore.instance
//                               .collection("Hotels")
//                               .doc(hotel_loc)
//                               .collection("Menu")
//                               .doc(category)
//                               .get();
//                       Map<String, dynamic>? oldMenuData;
//                       if (documentSnapshot.exists) {
//                         oldMenuData =
//                             documentSnapshot.data() as Map<String, dynamic>?;
//                       }

//                       // setting new record
//                       await FirebaseFirestore.instance
//                           .collection("Hotels")
//                           .doc(hotel_loc)
//                           .collection("Menu")
//                           .doc(_inputValue)
//                           .set(oldMenuData!);

//                       // Deleting old record after editing to new
//                       await FirebaseFirestore.instance
//                           .collection("Hotels")
//                           .doc(hotel_loc)
//                           .collection("Menu")
//                           .doc(category)
//                           .delete();

//                       print("Edited Suce");

//                       // Updating UI
//                       cardTitles[cardTitles.indexOf(oldCate)] = _inputValue;
//                       cardTitles.remove(oldCate);

//                       var oldCategory = category;
//                       var newCategory = _inputValue;

//                       // Updating UI after renaming category
//                       if (imagePaths.containsKey(oldCategory)) {
//                         imagePaths[newCategory] = imagePaths[oldCategory];
//                         imagePaths.remove(oldCategory);
//                       }

//                       // toggleCa
//                       //tegorySelection(oldCategory, newCategory, true);

//                       Navigator.of(context).pop({
//                         'edit_status': true,
//                         "old_cat": oldCategory,
//                         "new_cat": newCategory
//                       }); // Close the dialog with true status after editting
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: outer_background(),
//                     foregroundColor: inner_background(),
//                   ),
//                   child: Text('Save'),
//                 ),
//               ],
//             );
//           }) ??
//       false;
// }

Future<Map<String, dynamic>> _showInputDialog(
    BuildContext context, String msg, String category) async {
  final _formKey = GlobalKey<FormState>();
  String _inputValue = '';

  editCategoryController = TextEditingController(text: category);

  return await showDialog(
    context: context,
    // barrierDismissible: false,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape =
                MediaQuery.of(context).orientation == Orientation.landscape;

            // Dialog max dimensions (does NOT prevent scrolling)
            final double maxDialogWidth = isLandscape
                ? constraints.maxWidth * 0.70
                : constraints.maxWidth * 0.90;

            final double maxDialogHeight = isLandscape
                ? constraints.maxHeight * 0.75
                : constraints.maxHeight * 0.50;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxDialogWidth,
                maxHeight: maxDialogHeight,
              ),
              child: SingleChildScrollView(
                // ⭐ Scrollable dialog
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- TITLE ---------- //
                      Text(
                        msg,
                        style: TextStyle(
                          fontSize: isLandscape ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // ---------- INPUT ---------- //
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: editCategoryController,
                          decoration: InputDecoration(
                            labelText: "New Category Name",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: outer_background()),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Field should not be empty";
                            }
                            return null;
                          },
                          onChanged: (value) => _inputValue = value,
                        ),
                      ),

                      SizedBox(height: 40),

                      // ---------- BUTTONS ---------- //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: inner_background(),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop({
                                'edit_status': false,
                                "old_cat": "",
                                "new_cat": ""
                              });
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: outer_background()),
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: outer_background(),
                              foregroundColor: inner_background(),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                var oldCate = category;

                                // FETCH OLD DATA
                                DocumentSnapshot snap = await FirebaseFirestore
                                    .instance
                                    .collection("Hotels")
                                    .doc(hotel_loc)
                                    .collection("Menu")
                                    .doc(category)
                                    .get();

                                Map<String, dynamic>? oldData =
                                    snap.data() as Map<String, dynamic>?;

                                // WRITE NEW CATEGORY
                                await FirebaseFirestore.instance
                                    .collection("Hotels")
                                    .doc(hotel_loc)
                                    .collection("Menu")
                                    .doc(_inputValue)
                                    .set(oldData!);

                                // DELETE OLD CATEGORY
                                await FirebaseFirestore.instance
                                    .collection("Hotels")
                                    .doc(hotel_loc)
                                    .collection("Menu")
                                    .doc(category)
                                    .delete();

                                // UPDATE LISTS
                                cardTitles[cardTitles.indexOf(oldCate)] =
                                    _inputValue;

                                if (imagePaths.containsKey(oldCate)) {
                                  imagePaths[_inputValue] =
                                      imagePaths[oldCate]!;
                                  imagePaths.remove(oldCate);
                                }

                                Navigator.of(context).pop({
                                  'edit_status': true,
                                  'old_cat': oldCate,
                                  'new_cat': _inputValue
                                });
                              }
                            },
                            child: Text("Save"),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class _BuildCategoryCardsState extends State<build_category_cards> {
  Offset? _tapposition;

  // Sample data for the cards
  void _edit_category_name(BuildContext context, String cate) {
    _showInputDialog(context, "Do you wish to edit category name?", cate);
    // Navigator.pop.of(context);
  }

  // To store data that is being deleted
  var data;

  // Undo function
  void undo_the_category(var data, var category_name) async {
    print(data);

    await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(hotel_loc)
        .collection("Menu")
        .doc(category_name)
        .set(data);
    print("unoed");
  }

  // Delete function
  void _delete_category(var category_name, BuildContext context) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(hotel_loc)
        .collection("Menu")
        .doc(category_name)
        .get();

    // var data;
    if (documentSnapshot.exists) {
      data = documentSnapshot.data();
    }

    try {
      // Extract the file path from the URL
      final RegExp regExp = RegExp(r'o/(.*)\?alt=media');
      final RegExpMatch? match = regExp.firstMatch(data['category_image_path']);

      if (match != null) {
        String filePath =
            Uri.decodeFull(match.group(1)!); // Decode the file path

        // Reference to the file in Firebase Storage
        Reference fileRef = FirebaseStorage.instance.ref().child(filePath);

        // Delete the file
        await fileRef.delete();
        print("File deleted successfully: $filePath");
      } else {
        print("Invalid Firebase Storage URL.");
      }
    } catch (e) {
      print("Error while deleting file: $e");
    }

    await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(hotel_loc)
        .collection("Menu")
        .doc(category_name)
        .delete();

    print("${category_name} deleted");
    // Menu_Dashboard(href: hotel_loc,label: "Menu",);

    // Deleting and updating the
    if (mounted) {
      setState(() {
        cardTitles.remove(category_name);
        get_search_items(widget.href, false, true, false, false, false, false,
            category_name, "", {}, {});
      });
    }
  }

  // Delete and Undo functionality
  // Future<bool> alert_before_deleting(
  //     BuildContext context, String message, String category_name) async {
  //   var flag_delete = 0;
  //   return await showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               title: Text("Delete ${category_name}"),
  //               content: Text(message),
  //               actions: [
  //                 TextButton(
  //                     onPressed: () {
  //                       Navigator.pop(context, true);
  //                     },
  //                     style: TextButton.styleFrom(
  //                       backgroundColor: inner_background(),
  //                       foregroundColor: outer_background(),
  //                     ),
  //                     child: Text('Cancel')),
  //                 TextButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       // setState(() {
  //                       //   cardTitles.remove(
  //                       //       category_name); // Remove the deleted item from the list
  //                       // });

  //                       // Undo function
  //                       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //                       //   content: Row(
  //                       //     children: [
  //                       //       Expanded(
  //                       //         child: Text("Category deleted!"),
  //                       //       ),
  //                       //       ElevatedButton(
  //                       //           onPressed: () {
  //                       //             undo_the_category(data, category_name);
  //                       //             flag_delete = 1;

  //                       //             // Add the category to card Titles if undoed..
  //                       //             setState(() {
  //                       //               cardTitles.add(category_name);
  //                       //               get_search_items(widget.href, false,
  //                       //                   false, true, category_name, "");
  //                       //             });
  //                       //           },

  //                       //           // Style
  //                       //           style: ElevatedButton.styleFrom(
  //                       //               backgroundColor: outer_background(),
  //                       //               foregroundColor: inner_background()),
  //                       //           //
  //                       //           child: Text(
  //                       //             "Undo",
  //                       //             style:
  //                       //                 TextStyle(color: (inner_background())),
  //                       //           ))
  //                       //     ],
  //                       //   ),
  //                       //   backgroundColor: lightenColor(Color(0xFF397ABC), 0.3),
  //                       //   // action: SnackBarAction(label: "Undo", onPressed: () {}),
  //                       //   duration: Duration(seconds: 3),
  //                       // ));

  //                       // delete the doc
  //                       if (flag_delete == 0) {
  //                         _delete_category(category_name, context);
  //                       }

  //                       // Timer(Duration(seconds: 5), () {

  //                       // });
  //                     },
  //                     style: TextButton.styleFrom(
  //                       backgroundColor: outer_background(),
  //                       foregroundColor: inner_background(),
  //                     ),

  //                     // Delete function
  //                     child: Text("Delete")),
  //               ],
  //             );
  //           }) ??
  //       false;
  // }

  Future<bool> alert_before_deleting(
      BuildContext context, String message, String category_name) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              insetPadding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = MediaQuery.of(context).orientation ==
                      Orientation.landscape;

                  final double maxDialogWidth = isLandscape
                      ? constraints.maxWidth * 0.65
                      : constraints.maxWidth * 0.90;

                  final double maxDialogHeight = isLandscape
                      ? constraints.maxHeight * 0.65
                      : constraints.maxHeight * 0.45;

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxDialogWidth,
                      maxHeight: maxDialogHeight,
                    ),
                    child: SingleChildScrollView(
                      // ⭐ makes entire dialog scrollable
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ------------ TITLE ------------ //
                            Text(
                              "Delete $category_name",
                              style: TextStyle(
                                fontSize: isLandscape ? 20 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),

                            // ------------ MESSAGE ------------ //
                            Text(
                              message,
                              style: TextStyle(fontSize: 15),
                            ),

                            SizedBox(height: 36),

                            // ------------ BUTTONS ------------ //
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // CANCEL BUTTON
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: inner_background(),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(color: outer_background()),
                                  ),
                                ),

                                SizedBox(width: 12),

                                // DELETE BUTTON
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: outer_background(),
                                    foregroundColor: inner_background(),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);

                                    // DELETE CATEGORY
                                    _delete_category(category_name, context);
                                  },
                                  child: Text("Delete"),
                                ),
                              ],
                            ),

                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ) ??
        false;
  }

  List<String> localCategories = [];

  // For close icon in the search hover color
  List<bool> _isHovered = [];
  List<bool> _isTapped = [];

  @override
  void initState() {
    super.initState();
    print("ASDASD");
    print(widget.categories_Cards);

    // Starting
    cardTitles = [];
    // localCategories = widget.categories_Cards;
    // get_data("", widget.href, widget.categories_Cards);
    fetchMenuData();

    // filling default to false
    _isHovered = List.filled(widget.categories_Cards.length, false);
    _isTapped = List.filled(widget.categories_Cards.length, false);
  }

  //   void updateCategories(List<String> newCategories) {
  //   setState(() {
  //     localCategories = newCategories;
  //   });
  //   widget.onCategoriesUpdate(newCategories);
  // }

  // Build cards for selected chip status
  bool build_card_status = true;

  Future<void> fetchMenuData() async {
    // Call get_data to fetch menu information

    await get_data("", widget.href, widget.categories_Cards);
    print("456");
    print(widget.categories_Cards);
    if (mounted) {
      setState(() {
        build_card_status = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenHeight < screenWidth;

    // Responsive card sizing
    double cardWidth;
    double cardHeight;
    double fontSize;
    double padding;

    if (isLandscape) {
      // Landscape mode - cards are wider
      cardWidth = isTablet ? 200 : 160;
      cardHeight = isTablet ? 140 : 120;
      fontSize = isTablet ? 18 : 16;
      padding = 8.0;
    } else {
      // Portrait mode
      if (isTablet) {
        cardWidth = (screenWidth - 64.0) / 3; // 3 cards per row on tablets
        cardHeight = 160;
        fontSize = 20;
        padding = 12.0;
      } else {
        cardWidth = (screenWidth - 48.0) / 2; // 2 cards per row on phones
        cardHeight = 130;
        fontSize = 18;
        padding = 8.0;
      }
    }

    return build_card_status
        ? Center(
            child: SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  color: outer_background(),
                )))
        : Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Horizontally Scrollable Section
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(cardTitles.length, (index) {
                      String title = cardTitles[index];

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: GestureDetector(
                          onTapDown: (TapDownDetails details) async {
                            _tapposition = details.globalPosition;
                          },
                          onTapUp: (TapUpDetails details) {
                            print("Tap ended at: ${details.globalPosition}");
                            _tapposition = details.globalPosition;
                            print("PRessed Category ${cardTitles[index]}");

                            print("href ${widget.href}");
                          },
                          onLongPress: () {
                            print("FFFGD");
                            showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                    _tapposition!.dx,
                                    _tapposition!.dy,
                                    _tapposition!.dx,
                                    _tapposition!.dy),
                                items: [
                                  PopupMenuItem(
                                      child: TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            // _edit_category_name(
                                            //     context, cardTitles[index]);

                                            var result = await _showInputDialog(
                                                context,
                                                "Do you wish to edit category name",
                                                cardTitles[index]);

                                            print("SADSAdasfdg");
                                            print(result);
                                            // result coming after the edit
                                            if (result != null &&
                                                result
                                                    is Map<String, dynamic>) {
                                              var editResult =
                                                  result['edit_status'] ??
                                                      false;
                                              String oldCategory =
                                                  result['old_cat'] ?? "";
                                              String newCategory =
                                                  result['new_cat'] ?? "";

                                              get_search_items(
                                                  widget.href,
                                                  editResult,
                                                  false,
                                                  false,
                                                  false,
                                                  false,
                                                  false,
                                                  oldCategory,
                                                  newCategory, {}, {});
                                            }

                                            // Snack bar

                                            showSlideFromLeftSnackBar(
                                                context,
                                                "Category edited successfully!",
                                                "success");
                                          },
                                          child: Text(
                                            "Edit name",
                                            style: TextStyle(
                                                color: outer_background()),
                                          ))),
                                  PopupMenuItem(
                                      child: TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            var result1 =
                                                await alert_before_deleting(
                                                    context,
                                                    "This category will be permanently deleted from the menu. Do you want to delete?",
                                                    cardTitles[index]);

                                            // if (result1 == true) {
                                            //   setState(() {

                                            //   });
                                            // }

                                            // _delete_category(cardTitles[index]);
                                            // setState(() {});
                                            Future.delayed(Duration(seconds: 2),
                                                () {
                                              showSlideFromLeftSnackBar(
                                                  context,
                                                  "Category deleted successfully!",
                                                  "success");
                                            });
                                          },
                                          child: Text("Delete",
                                              style: TextStyle(
                                                  color: outer_background()))))
                                ]);
                          },
                          child: SizedBox(
                            height: cardHeight,
                            width: cardWidth,
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Stack(
                                children: [
                                  // 🔹 Background Image from Firebase

                                  if (imagePaths[title] != null)
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15)),
                                        child: Image.network(
                                          imagePaths[title],
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (context, child, progress) {
                                            if (progress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: outer_background(),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                                color: outer_background());
                                          },
                                        ),
                                      ),
                                    ),

                                  // Default Background Color
                                  if (imagePaths[cardTitles[index]] == "")
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: outer_background(),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                bottomRight: Radius.circular(
                                                    15))), // Default background color
                                      ),
                                    ),

                                  // close icon

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
                                  // 🔹 Text on the card
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: isTablet ? 12.0 : 8.0),
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!mounted) return;
                                        print(categories_Cards);
                                        print(selectedCategories);
                                        print("Close icon tapped!");
                                        setState(() {
                                          _isTapped[index] =
                                              true; // Mark it as tapped
                                          categories_Cards
                                              .remove(cardTitles[index]);
                                          selectedCategories
                                              .remove(cardTitles[index]);
                                        });
                                        Future.delayed(
                                            Duration(milliseconds: 300), () {
                                          if (mounted) {
                                            setState(() {
                                              _isTapped[index] =
                                                  false; // Reset after the delay
                                            });
                                          }
                                        });
                                      },
                                      child: MouseRegion(
                                        onEnter: (_) {
                                          if (mounted) {
                                            setState(() {
                                              if (!_isTapped[index]) {
                                                // Only change on hover if it's not tapped
                                                _isHovered[index] = true;
                                              }
                                            });
                                          }
                                        },
                                        onExit: (_) {
                                          if (mounted) {
                                            setState(() {
                                              if (!_isTapped[index]) {
                                                // Only reset hover if it's not tapped
                                                _isHovered[index] = false;
                                              }
                                            });
                                          }
                                        },
                                        child: Icon(
                                          Icons.close,
                                          size: isTablet ? 22 : 18,
                                          color: _isTapped[index]
                                              ? Colors
                                                  .red // If tapped, color it red
                                              : (_isHovered[index]
                                                  ? Colors.red
                                                  : inner_background()), // If hovered, color it red
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
  }
}
