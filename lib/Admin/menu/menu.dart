import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/Admin/menu/add_category.dart';
import 'package:orderease/util_components/bottom_navbar.dart';
import 'package:orderease/util_components/util.dart';

class Menu extends StatefulWidget {
  // final Map<String, dynamic> menu_data;
  // required this.menu_data,
  final String hotel_loc;
  final String menu_label;
  const Menu({super.key, required this.hotel_loc, required this.menu_label});

  @override
  State<Menu> createState() => _MenuState();
}

Map<String, dynamic>? data;
late Future<void> menu_items;
bool _isLoading = true;
bool _isfetched = false;
Iterable? docids;
List? d;
// bool
// var data_with_imagepath;

class _MenuState extends State<Menu> {
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
    d!.remove("food_status");
    // print(d);

    // print("KEY");

    setState(() {
      data = data;
      _isLoading = false;
      _isfetched = true;
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

  TextEditingController _itemnamecontroller = TextEditingController();
  TextEditingController _pricecontroller = TextEditingController();
  Future<bool> _showInputDialog(
      BuildContext context, String itemName, String price) async {
    //
    print(price);
    _itemnamecontroller.text = itemName;
    _pricecontroller.text = price.toString();
    final _formKey = GlobalKey<FormState>(); // Form key to validate the form
    String _inputValue = ''; // Variable to store the input value

    bool? res = await showDialog(
        context: context,
        builder: (BuildContext context) {
          final orientation = MediaQuery.of(context).orientation;
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final isLandscape = orientation == Orientation.landscape;
          return Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: isLandscape
                  ? screenWidth * 0.25 // More side padding in landscape
                  : screenWidth * 0.1, // Less side padding in portrait
              vertical: 24.0,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 24.0 : 20.0,
                vertical: isLandscape ? 16.0 : 20.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Do you wish to edit menu item?',
                      style: TextStyle(
                        fontSize: isLandscape ? 18 : 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isLandscape ? 20 : 15),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.name,
                            controller: _itemnamecontroller,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Colors.grey), // Color when not focused
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        outer_background()), // Color when focused
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

                          // price
                          TextFormField(
                            keyboardType: TextInputType.numberWithOptions(),
                            controller: _pricecontroller,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Colors.grey), // Color when not focused
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        outer_background()), // Color when focused
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(false); // Close the dialog
                          },

                          // Adding style to button
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
                              // If form is valid, proceed
                              print('Input value: $_inputValue');

                              // Log
                              String email =
                                  FirebaseAuth.instance.currentUser!.email!;
                              await addLogEntry(
                                hotelId: widget.hotel_loc,
                                userEmail: email,
                                action:
                                    "Edited menu item (${itemName.toString().toLowerCase()} -> ${_itemnamecontroller.text.toString().toLowerCase()}).",
                                tableNumber: "",
                                sessionId: "",
                              );

                              if (itemName.toLowerCase() !=
                                      _itemnamecontroller.text.toLowerCase() ||
                                  price !=
                                      _pricecontroller.text.toLowerCase()) {
                                await FirebaseFirestore.instance
                                    .collection("Hotels")
                                    .doc(widget.hotel_loc)
                                    .collection("Menu")
                                    .doc(widget.menu_label)
                                    .update({
                                  itemName: FieldValue.delete(),
                                  "food_status.$itemName": FieldValue
                                      .delete() // Delete item from Firestore
                                });

                                await FirebaseFirestore.instance
                                    .collection("Hotels")
                                    .doc(widget.hotel_loc)
                                    .collection("Menu")
                                    .doc(widget.menu_label)
                                    .update({
                                  _itemnamecontroller.text:
                                      _pricecontroller.text,
                                  "food_status.${_itemnamecontroller.text}":
                                      true
                                });

                                setState(() {
                                  data!.remove(itemName);
                                  data!['food_status'].remove(itemName);
                                  data!['food_status']
                                      [_itemnamecontroller.text] = true;
                                  data!.addAll({
                                    _itemnamecontroller.text:
                                        _pricecontroller.text
                                  });
                                  d = data!.keys.toList();
                                  d!.remove("category_image_path");
                                  d!.remove("food_status");
                                });

                                print(data);
                                print(d);
                                print("DATA");
                              }

                              Navigator.of(context)
                                  .pop(true); // Close the dialog
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: outer_background(),
                            foregroundColor: inner_background(),
                          ),
                          child: Text('Save'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });

    return res ?? false;
  }

  Future<bool> _show_Alert_before_delete(
      BuildContext parentContext, String itemName, String price) async {
    String iname = itemName;
    bool undo_flag = true;

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Delete Food Item"),
              content: Text("Do you want to delete the item?"),
              actions: [
                // Cancel Action
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("No"),
                  style: TextButton.styleFrom(
                      backgroundColor: inner_background(),
                      foregroundColor: outer_background()),
                ),
                // Confirm Delete Action
                ElevatedButton(
                  onPressed: () async {
                    // Close dialog and return true

                    Navigator.of(context).pop();

                    try {
                      // Remove locally
                      setState(() {
                        data!.remove(itemName);
                        data!['food_status'].remove(itemName);

                        d = data!.keys.toList();
                        d!.remove("category_image_path");
                        d!.remove("food_status"); // Avoid showing image path
                      });

                      // Display message
                      ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
                        content: Row(
                          children: [
                            Expanded(
                              child: Text("Menu Item deleted!"),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  // Update local state
                                  setState(() {
                                    data!.addAll({itemName: price});
                                    data!['food_status'][itemName] = true;
                                    undo_flag = false;
                                    d = data!.keys.toList();
                                    d!.remove("category_image_path");
                                    d!.remove("food_status");
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
                        duration: Duration(seconds: 3),
                      ));

                      Timer(Duration(seconds: 5), () async {
                        // Remove from Firestore

                        if (undo_flag)
                          await FirebaseFirestore.instance
                              .collection("Hotels")
                              .doc(widget.hotel_loc)
                              .collection("Menu")
                              .doc(widget.menu_label)
                              .update({
                            itemName: FieldValue.delete(),
                            "food_status.$itemName": FieldValue
                                .delete() // Delete item from Firestore
                          });

                        // Log
                        String email =
                            FirebaseAuth.instance.currentUser!.email!;
                        await addLogEntry(
                          hotelId: widget.hotel_loc,
                          userEmail: email,
                          action:
                              "Deleted menu item (${itemName.toString().toLowerCase()}).",
                          tableNumber: "",
                          sessionId: "",
                        );

                        print("Log and delete");
                      });

                      // print(iname);
                    } catch (error) {
                      // Handle errors
                      showBounceSnackBar(
                          context, "Error deleting item:", "fail");
                    }
                  },
                  child: Text("Yes"),
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

  Future<Map<String, dynamic>> _toggle_food_status(
      bool value, String food_name) async {
    setState(() {
      _isLoading = true;
    });
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.hotel_loc)
        .collection("Menu")
        .doc(widget.menu_label)
        .get();

    if (!documentSnapshot.exists) {
      print("Document does not exist");
    }

    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    if (data.containsKey("food_status") &&
        data["food_status"] is Map<String, dynamic>) {
      data["food_status"][food_name] = value;
    } else {
      print("food_status field does not exist or is not a Map");
    }

    await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.hotel_loc)
        .collection("Menu")
        .doc(widget.menu_label)
        .update({
      "food_status.$food_name": value // Dot notation for nested update
    });

    // Log
    String email = FirebaseAuth.instance.currentUser!.email!;

    String val = (value) ? "Available" : "Unavailable";

    await addLogEntry(
      hotelId: widget.hotel_loc,
      userEmail: email,
      action: "Changed food_status-(${food_name.toString().toLowerCase()}) to $val.",
      tableNumber: "",
      sessionId: "",
    );

    setState(() {
      _isLoading = false;
    });

    return data;
  }

  @override
  Widget build(BuildContext context) {
    // d!.remove("category_image_path");
    // print(d);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;

    // Responsive image height based on orientation
    final imageHeight = isLandscape
        ? screenHeight * 0.35 // Landscape: 35% of height
        : screenHeight * 0.25; // Portrait: 25% of height

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.menu_label,
          style: TextStyle(
              color: inner_background(),
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            data = {};
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          color: inner_background(),
        ),
        backgroundColor: outer_background(),
        actions: [
          ProfileButton(
              context: context, hotelref: widget.hotel_loc, isTablet: isTablet)
        ],
      ),
      body: FutureBuilder<void>(
        future: menu_items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomLoader(message: 'Loading menu...');
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
                  height: imageHeight,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: isLandscape
                        ? BorderRadius.circular(15)
                        : BorderRadius.zero,
                  ),
                  child: ClipRRect(
                    borderRadius: isLandscape
                        ? BorderRadius.circular(15)
                        : BorderRadius.zero,
                    child: Image.network(
                      data!['category_image_path'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: outer_background(),
                            strokeWidth: 3,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: outer_background(),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: isLandscape ? 40 : 100,
                ),
                Center(
                    child: Text(
                  "Add menu items.",
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 20,
                    fontWeight: FontWeight.w500,
                  ),
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
                        Container(
                          height: imageHeight,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: isLandscape
                                ? BorderRadius.circular(15)
                                : BorderRadius.zero,
                          ),
                          child: ClipRRect(
                            borderRadius: isLandscape
                                ? BorderRadius.circular(15)
                                : BorderRadius.zero,
                            child: Image.network(
                              data!['category_image_path'],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: outer_background(),
                                    strokeWidth: 3,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: outer_background(),
                                );
                              },
                            ),
                          ),
                        ),
                      // Default Background Color
                      if (data!['category_image_path'] == null)
                        Positioned.fill(
                          child: Container(
                            height: imageHeight,
                            decoration: BoxDecoration(
                              color: outer_background(),
                              borderRadius: isLandscape
                                  ? BorderRadius.circular(15)
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    ),
                            ),
                          ),
                        ),

                      // Gradient Overlay
                      Container(
                        height: imageHeight,
                        decoration: BoxDecoration(
                          borderRadius: isLandscape
                              ? BorderRadius.circular(15)
                              : BorderRadius.only(
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
                        color: outer_background(),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return
                            // Dismissible(
                            //   key: Key(d![index]),
                            //   direction: DismissDirection.endToStart,
                            //   confirmDismiss: (direction) async {
                            //     return await _show_Alert_before_delete(
                            //         context, d![index]);
                            //   },

                            //   // for dimissible
                            //   background: Container(
                            //     color: Colors.red, // Background color for swipe
                            //     alignment: Alignment.centerRight,
                            //     padding: EdgeInsets.symmetric(horizontal: 20),
                            //     child: Icon(Icons.delete,
                            //         color: Colors.white), // Delete icon
                            //   ),
                            // child:
                            Container(
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
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          d![index].toString().toUpperCase(),
                                          style: TextStyle(fontSize: 16),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // Price (Properly aligned)
                                      Expanded(
                                        flex: 1,
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
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                              onPressed: () async {
                                                // Navigator.of(context).pop();
                                                print(data![d![index]]);
                                                print("PP");
                                                bool res =
                                                    await _showInputDialog(
                                                        context,
                                                        d![index],
                                                        data![d![index]]);
                                                if (res) {
                                                  showSlideFromLeftSnackBar(
                                                      context,
                                                      "Menu item edited successfully!",
                                                      "success");
                                                }
                                              },
                                              icon: Icon(Icons.edit)),
                                          IconButton(
                                              onPressed: () {
                                                // Navigator.of(context).pop();
                                                print(data![d![index]]);
                                                print(d![index]);
                                                _show_Alert_before_delete(
                                                    context,
                                                    d![index],
                                                    data![d![index]]);
                                              },
                                              icon: Icon(Icons.delete)),
                                          Column(
                                            children: [
                                              Switch(
                                                value: (data != null &&
                                                        data!['food_status'] !=
                                                            null &&
                                                        data!['food_status']
                                                                [d?[index]] !=
                                                            null)
                                                    ? data!['food_status']
                                                        [d![index]]
                                                    : false, // Default to false if null
                                                onChanged: (bool value) async {
                                                  if (data != null &&
                                                      data!['food_status'] !=
                                                          null &&
                                                      d != null) {
                                                    Map<String, dynamic>
                                                        result =
                                                        await _toggle_food_status(
                                                            value, d![index]);
                                                    print(result);
                                                    print("After changing");
                                                    setState(() {
                                                      data = result;
                                                    });
                                                  } else {
                                                    print(
                                                        "Error: Data or food status is null");
                                                  }
                                                },
                                                activeColor: outer_background(),
                                                inactiveThumbColor: Colors.grey,
                                                inactiveTrackColor:
                                                    Colors.grey.shade200,
                                              ),
                                              Text(data!['food_status']
                                                      [d![index]]
                                                  ? "Available"
                                                  : "Unavailable")
                                            ],
                                          ),
                                        ],
                                      )
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

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     // Navigate to the AddPage when the button is clicked

      //     // new items in result after adding
      //     final result = await Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) =>
      // NewCategoryPage(
      //                 hotel_loc: widget.hotel_loc,
      //                 label: widget.menu_label,
      //                 page_label: "menu_items",
      //               )),
      //     );

      //     print("RRR");
      //     print(result);

      //     // Adding new category by refreshing
      //     if (result != {}) {
      //       setState(() {
      //         data!.addAll(result);
      //         d = data!.keys.toList();
      //         d!.remove("category_image_path");
      //       });
      //     }
      //   },
      //   backgroundColor: lightenColor(
      //       Color(0xFF397ABC), 0.3), // Background color of the button
      //   child: Icon(
      //     Icons.add,
      //     color: inner_background(), // Color of the plus sign
      //     size: 36, // Adjust the size of the icon
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // bottomNavigationBar: BottomAppBar(
      //   // providing cut out space for dock button
      //   shape: CircularNotchedRectangle(),

      //   // spacing between the button and cut out
      //   notchMargin: 8.0,

      //   color: outer_background(), // Background color of the BottomAppBar
      //   child: SizedBox(
      //     height: 20.0, // Explicit height adjustment
      //     // child: Row(
      //     //   // Add any content inside the BottomAppBar here
      //     //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     //   children: [
      //     //     IconButton(
      //     //       icon: Icon(Icons.menu),
      //     //       onPressed: () {},
      //     //     ),
      //     //     IconButton(
      //     //       icon: Icon(Icons.settings),
      //     //       onPressed: () {},
      //     //     ),
      //     //   ],
      //     // ),
      //   ),
      // ),
    );
  }
}

// Backup card syntax
// Stack(
//                       children: [
//                         Card(
//                           color: inner_background(),
//                           shadowColor: outer_background(),
//                           margin: EdgeInsets.all(8),
//                           child: Padding(
//                               padding: EdgeInsets.all(16),
//                               child: ListTile(
//                                 leading: Text(
//                                   d[index].toString().toUpperCase(),
//                                   style: TextStyle(fontSize: 20),
//                                 ),
//                                 title: Center(
//                                   child: Text(
//                                     "Rs " + widget.menu_data[d[index]].toString().toUpperCase(),
//                                     style: TextStyle(fontSize: 20),
//                                   ),
//                                 ),
//                                 trailing: IconButton(
//                                     onPressed: () {
//                                       // Navigator.of(context).pop();
//                                     },
//                                     icon: Icon(Icons.edit)),
//                               )),
//                         ),
//                       ],
//                     );
