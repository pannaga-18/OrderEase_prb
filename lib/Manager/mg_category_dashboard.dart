import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:orderease/util_components/bottom_navbar.dart';
import 'package:orderease/util_components/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var hotelref, Dash_label, hotel_loc;

bool show_text_status = true;
bool _isLoading = true;

List<String> cardTitles = [];
Map imagePaths = {};
// Map imagePaths

Future<void> get_data(String label, String href) async {
  Dash_label = label;
  hotel_loc = href;

  print("Inside menu_dah ${Dash_label}, ${hotel_loc}");

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("Hotels")
      .doc(hotel_loc)
      .collection("Menu")
      .get();

  if (querySnapshot.size != 0) {
    show_text_status = false;

    cardTitles = [];
    for (var doc in querySnapshot.docs) {
      cardTitles.add(doc.id);

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(hotel_loc)
          .collection("Menu")
          .doc(doc.id)
          .get();
      var data = documentSnapshot.data() as Map<String, dynamic>;
      // print(data);

      imagePaths[doc.id] = data['category_image_path'];
    }
  } else {
    cardTitles = [];
    show_text_status = true;
    print("MEnu bbbbbbb00");
  }
}

class Manager_Menu_Dashboard extends StatefulWidget {
  final String label;
  final String href;
  final String table_option;
  Manager_Menu_Dashboard(
      {super.key,
      required this.label,
      required this.href,
      required this.table_option});

  @override
  Dashboard createState() => Dashboard();
}

class Dashboard extends State<Manager_Menu_Dashboard> {
  @override
  void initState() {
    super.initState();
    fetchMenuData();
    print('Hreee');
  }

  // fetching category, each time when
  Future<void> fetchMenuData() async {
    // Call get_data to fetch menu information
    await get_data(widget.label, widget.href);
    setState(() {
      _isLoading =
          false; // Data has been loaded, stop showing the loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: inner_background(),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: outer_background(),
        elevation: 0,
        title: Text(
          isLandscape ? "Menu" : "",
          style: TextStyle(
            fontSize: isTablet ? 28 : 18,
            fontWeight: FontWeight.w600,
            color: inner_background(),
          ),
        ),
        centerTitle: isLandscape ? true : false,
        actions: [
          ProfileButton(
              context: context, hotelref: widget.href, isTablet: isTablet)
        ],
      ),
      body: _isLoading
          ? CustomLoader(message: 'Loading...')
          : show_text_status
              ? Padding(
                  padding: EdgeInsets.only(top: 20),
                  //
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isLandscape) ...[
                            Container(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.1,
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                                minWidth: 200, // smaller screens
                              ),

                              //
                              padding: EdgeInsets.all(16),
                              //
                              alignment: Alignment.center,
                              //
                              decoration: BoxDecoration(
                                  color: outer_background(),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15))),

                              //
                              child: Text(
                                Dash_label,
                                style: TextStyle(
                                  color: inner_background(),
                                  fontSize: 28,
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 25),
                          child: Text(
                            "Currently no Menu is added",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ))
              :

              // FALSE ADRE
              Padding(
                  padding: EdgeInsets.only(top: isLandscape ? 0 : 30),
                  //
                  child: Column(
                    children: [
                      if (!isLandscape) ...[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.1,
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                  minWidth: 200, // smaller screens
                                ),

                                decoration: BoxDecoration(
                                    color: outer_background(),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        topRight: Radius.circular(15))),

                                //
                                padding: EdgeInsets.all(16),
                                //
                                alignment: Alignment.center,
                                //

                                //
                                child: Text(
                                  Dash_label,
                                  style: TextStyle(
                                    color: inner_background(),
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ]),
                        Padding(padding: EdgeInsets.only(top: 30)),
                      ],
                      Expanded(
                        child: build_category_cards(
                          href: widget.href,
                          table_option: widget.table_option,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class build_category_cards extends StatefulWidget {
  final String href;
  final String table_option;
  const build_category_cards({required this.href, required this.table_option});

  @override
  _BuildCategoryCardsState createState() => _BuildCategoryCardsState();
}

TextEditingController editCategoryController = TextEditingController();

class _BuildCategoryCardsState extends State<build_category_cards> {
  Offset? _tapposition;

  // Sample data for the cards
  // void _edit_category_name(BuildContext context, String cate) {

  //   // Navigator.pop.of(context);

  // }

  void _showInputDialog(BuildContext context, String msg, String category) {
    final _formKey = GlobalKey<FormState>();
    String _inputValue = category;

    editCategoryController = TextEditingController(text: category);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(msg),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: editCategoryController,
                decoration: InputDecoration(labelText: "New Category Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field should not be empty';
                  }
                  return null;
                },
                onChanged: (value) {
                  _inputValue = value;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                style:
                    TextButton.styleFrom(foregroundColor: outer_background()),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: inner_background(),
                    backgroundColor: outer_background()),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var oldCate = category;
                    DocumentSnapshot documentSnapshot = await FirebaseFirestore
                        .instance
                        .collection("Hotels")
                        .doc(hotel_loc)
                        .collection("Menu")
                        .doc(category)
                        .get();

                    Map<String, dynamic>? oldMenuData =
                        documentSnapshot.data() as Map<String, dynamic>?;

                    if (oldMenuData != null) {
                      await FirebaseFirestore.instance
                          .collection("Hotels")
                          .doc(hotel_loc)
                          .collection("Menu")
                          .doc(_inputValue)
                          .set(oldMenuData);

                      await FirebaseFirestore.instance
                          .collection("Hotels")
                          .doc(hotel_loc)
                          .collection("Menu")
                          .doc(category)
                          .delete();
                    }

                    // Updating UI
                    var oldCategory = category;
                    var newCategory = _inputValue;

                    setState(() {
                      int index = cardTitles.indexOf(oldCate);
                      if (index != -1) {
                        cardTitles[index] = _inputValue;
                        print("PPPP");
                        print(imagePaths);
                      }
                      // Updating UI after renaming category
                      if (imagePaths.containsKey(oldCategory)) {
                        imagePaths[newCategory] = imagePaths[oldCategory];
                        imagePaths.remove(oldCategory);
                      }
                    });

                    Navigator.of(context).pop(); // Close dialog
                  }
                },
                child: Text('Save'),
              ),
            ],
          );
        });
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
    setState(() {
      cardTitles.remove(category_name); // Remove the deleted item from the list
    });
  }

  // Delete and Undo functionality
  void alert_before_deleting(
      BuildContext context, String message, String category_name) {
    var flag_delete = 0;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete ${category_name}"),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: inner_background(),
                    foregroundColor: outer_background(),
                  ),
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      cardTitles.remove(
                          category_name); // Remove the deleted item from the list
                    });

                    // Undo function
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(
                        children: [
                          Expanded(
                            child: Text("Category deleted!"),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                undo_the_category(data, category_name);
                                flag_delete = 1;
                                // Add the category to card Titles if undoed..
                                setState(() {
                                  cardTitles.add(category_name);
                                });
                              },

                              // Style
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: outer_background(),
                                  foregroundColor: inner_background()),
                              //
                              child: Text(
                                "Undo",
                                style: TextStyle(color: (inner_background())),
                              ))
                        ],
                      ),
                      backgroundColor: lightenColor(Color(0xFF397ABC), 0.3),
                      // action: SnackBarAction(label: "Undo", onPressed: () {}),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ));

                    // delete the doc
                    Timer(Duration(seconds: 5), () {
                      if (flag_delete == 0)
                        _delete_category(category_name, context);
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: outer_background(),
                    foregroundColor: inner_background(),
                  ),

                  // Delete function
                  child: Text("Delete")),
            ],
          );
        });
  }

  // @override
  // Widget build(BuildContext context) {

  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: GridView.builder(
  //       padding: EdgeInsets.zero,

  //       //
  //       shrinkWrap: true, // Important to make it work inside a ScrollView

  //       //
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 2, // Two cards per row
  //         crossAxisSpacing: 3.0, // Space between cards
  //         mainAxisSpacing: 3.0, // Space between rows
  //         mainAxisExtent: 130,
  //       ),

  //       //
  //       itemCount: cardTitles.length,

  //       //
  //       // child: SizedBox(
  //       // height: 20,
  //       // width: 40, // Decreased height for the card
  //       itemBuilder: (context, index) {
  //         return GestureDetector(
  //           onTapDown: (TapDownDetails details) async {
  //             _tapposition = details.globalPosition;
  //           },
  //           onTapUp: (TapUpDetails details) {
  //             print("Tap ended at: ${details.globalPosition}");
  //             _tapposition = details.globalPosition;
  //             // print("PRessed Category ${cardTitles[index]}");

  //             print("href ${widget.href}");
  //             Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => SwipableNavBar(
  //                     role: "Manager",
  //                     page1: "Order",
  //                     page2: "MG_Menu_Items",
  //                     label: cardTitles[index],
  //                     href: widget.href,
  //                     table_option: widget.table_option,
  //                   ),
  //                 ));
  //           },
  //           child: Card(
  //             elevation: 4.0,
  //             shape: RoundedRectangleBorder(
  //               borderRadius:
  //                   BorderRadius.circular(15), // Optional: Rounded corners
  //             ),
  //             child: Stack(
  //               children: [
  //                 // Background Image from Firebase
  //                 if (imagePaths[cardTitles[index]] != null)
  //                   Positioned.fill(
  //                     child: ClipRRect(
  //                       borderRadius: BorderRadius.only(
  //                           topLeft: Radius.circular(15),
  //                           bottomRight: Radius.circular(15)),
  //                       child: Image.network(
  //                         imagePaths[cardTitles[index]],

  //                         fit: BoxFit
  //                             .cover, // Ensures the image covers the card area
  //                         loadingBuilder: (context, child, progress) {
  //                           if (progress == null) return child; // Image loaded
  //                           return Center(
  //                             child: CircularProgressIndicator(
  //                               strokeWidth: 3.0,
  //                               backgroundColor: outer_background(),
  //                             ),
  //                           );
  //                         },
  //                         errorBuilder: (context, error, stackTrace) {
  //                           return Container(
  //                             color:
  //                                 outer_background(), // Fallback color on error
  //                           );
  //                         },
  //                       ),
  //                     ),
  //                     // Image with loading and error handling
  //                   ),

  //                 // Default Background Color
  //                 if (imagePaths[cardTitles[index]] == "")
  //                   Positioned.fill(
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                           color: outer_background(),
  //                           borderRadius: BorderRadius.only(
  //                               topLeft: Radius.circular(15),
  //                               bottomRight: Radius.circular(
  //                                   15))), // Default background color
  //                     ),
  //                   ),

  //                 // Text Content (Always Centered)

  //                 Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.only(
  //                       bottomRight: Radius.circular(15),
  //                     ),
  //                     gradient: LinearGradient(
  //                       colors: [
  //                         Colors.black.withOpacity(0.5),
  //                         Colors.transparent,
  //                       ],
  //                       begin: Alignment.bottomCenter,
  //                       end: Alignment.topCenter,
  //                     ),
  //                   ),
  //                 ),

  //                 // Text on the card
  //                 Center(
  //                   child: Padding(
  //                     padding: const EdgeInsets.symmetric(
  //                         vertical: 4.0, horizontal: 8.0),
  //                     child: Text(
  //                       cardTitles[index],
  //                       style: TextStyle(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.white,
  //                       ),
  //                       textAlign:
  //                           TextAlign.center, // Ensures centered alignment
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isTablet = screenWidth > 600;

    // Determine grid columns based on screen size and orientation
    int crossAxisCount;
    if (isTablet) {
      crossAxisCount = isLandscape ? 4 : 3;
    } else {
      crossAxisCount = isLandscape ? 3 : 2;
    }

    // Adjust card height based on orientation
    double cardHeight = isLandscape ? 110 : 130;

    return Padding(
      padding: EdgeInsets.all(isLandscape ? 12.0 : 16.0),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true, // Important to make it work inside a ScrollView
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // Responsive columns
          crossAxisSpacing: 3.0, // Space between cards
          mainAxisSpacing: 3.0, // Space between rows
          mainAxisExtent: cardHeight, // Responsive height
        ),
        itemCount: cardTitles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTapDown: (TapDownDetails details) async {
              _tapposition = details.globalPosition;
            },
            onTapUp: (TapUpDetails details) {
              print("Tap ended at: ${details.globalPosition}");
              _tapposition = details.globalPosition;

              print("href ${widget.href}");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SwipableNavBar(
                      role: "Manager",
                      page1: "Order",
                      page2: "MG_Menu_Items",
                      label: cardTitles[index],
                      href: widget.href,
                      table_option: widget.table_option,
                    ),
                  ));
            },
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15), // Optional: Rounded corners
              ),
              child: Stack(
                children: [
                  // Background Image from Firebase
                  if (imagePaths[cardTitles[index]] != null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                        child: Image.network(
                          imagePaths[cardTitles[index]],
                          fit: BoxFit
                              .cover, // Ensures the image covers the card area
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child; // Image loaded
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3.0,
                                backgroundColor: outer_background(),
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

                  // Gradient overlay
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

                  // Text on the card
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: isLandscape ? 6.0 : 8.0,
                      ),
                      child: Text(
                        cardTitles[index],
                        style: TextStyle(
                          fontSize: isTablet ? 20 : (isLandscape ? 18 : 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign:
                            TextAlign.center, // Ensures centered alignment
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
