// List<String> category_list = [];
// List<String> total_search_list = [];
// Map<String, List<String>> category_items_map = {};

// for (var doc in querySnapshot.docs) {
//   print(doc.id);
//   category_list.add(doc.id);
//   total_search_list.add(doc.id);
// }

// // Fetch all documents in parallel to improve performance
// List<Future<DocumentSnapshot>> fetchFutures = category_list.map((categoryId) {
//   return FirebaseFirestore.instance
//       .collection("Hotels")
//       .doc(hotelref)
//       .collection("Menu")
//       .doc(categoryId)
//       .get();
// }).toList();

// // Wait for all Firestore fetch operations to complete
// List<DocumentSnapshot> documentSnapshots = await Future.wait(fetchFutures);

// for (var docSnapshot in documentSnapshots) {
//   if (docSnapshot.exists) {
//     Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

//     // Remove "category_image_path" if it exists
//     List<String> items_names = data.keys.toList();
//     items_names.removeWhere((key) => key == "category_image_path");

//     category_items_map[docSnapshot.id] = items_names;
//   }
// }

// print(category_list);
// print(total_search_list);
// print(category_items_map);









// MY Search PROCESS

  // for (var doc in querySnapshot.docs) {
  //   // print(doc.id);
  //   category_list.add(doc.id);
  //   total_search_list.add(doc.id);
  //   DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //       .collection("Hotels")
  //       .doc(widget.hotelref)
  //       .collection("Menu")
  //       .doc(doc.id)
  //       .get();

  //   if (documentSnapshot.exists) {
  //     Map<String, dynamic> data =
  //         documentSnapshot.data() as Map<String, dynamic>;
  //     var items_names = data.keys.toList();
  //     items_names.remove("category_image_path");
  //     category_items_map[doc.id] = items_names;
  //     total_search_list.addAll(items_names);
  //   }
  // }
  // print(category_list);
  // print(total_search_list);
  // print(category_items_map);



















  // menu item cards 
  // Stack(
                          //   children: [

                          //     Container(
                          //       margin: EdgeInsets.all(2),
                          //       decoration: BoxDecoration(
                          //         // boxShadow: [
                          //         //   BoxShadow(
                          //         //     color: outer_background(),
                          //         //     // offset: Offset(4, 4),
                          //         //     blurRadius: 0,
                          //         //   ),
                          //         // ],

                          //         borderRadius: BorderRadius.circular(20),
                          //       ),

                          //       // Cards
                          //       child: Card(
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius:
                          //               BorderRadius.all(Radius.circular(15)),
                          //           side: BorderSide(
                          //             color: outer_background(),
                          //             width: 2.0,
                          //           ),
                          //         ),
                          //         color: inner_background(),
                          //         child: Padding(
                          //           padding: const EdgeInsets.all(12),
                          //           child: Row(
                          //             crossAxisAlignment: CrossAxisAlignment.center,
                          //             children: [
                          //               // Menu Name (Expanded to prevent overflow)
                          //               Expanded(
                          //                 flex: 2,
                          //                 child: Text(
                          //                   menu_names[index]
                          //                       .toString()
                          //                       .toUpperCase(),
                          //                   style: TextStyle(
                          //                       fontSize: 16,
                          //                       fontWeight: FontWeight.bold),
                          //                   maxLines: 2,
                          //                   overflow: TextOverflow
                          //                       .ellipsis, // Prevents text overflow
                          //                 ),
                          //               ),

                          //               // Price (Properly aligned)
                          //               Expanded(
                          //                 flex: 1,
                          //                 child: Row(
                          //                   mainAxisAlignment:
                          //                       MainAxisAlignment.center,
                          //                   children: [
                          //                     Icon(Icons.currency_rupee_outlined,
                          //                         size: 18),
                          //                     Text(
                          //                       menuCardsData[index]
                          //                               [menu_names[index]]
                          //                           .toString(),
                          //                       style: TextStyle(
                          //                           fontSize: 16,
                          //                           fontWeight: FontWeight.w500),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ),

                          //               // Edit & Delete Icons
                          //               Row(
                          //                 mainAxisSize: MainAxisSize.min,
                          //                 children: [
                          //                   IconButton(
                          //                     onPressed: () {
                          //                       print(data![d![index]]);
                          //                       print("PP");
                          //                     },
                          //                     icon: Icon(Icons.edit),
                          //                   ),
                          //                   IconButton(
                          //                     onPressed: () {
                          //                       print(data![d![index]]);
                          //                       print(d![index]);
                          //                     },
                          //                     icon: Icon(Icons.delete),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     Positioned(
                          //               top: 15,
                          //               right: 15,
                          //               child: GestureDetector(
                          //                 onTap: () {
                          //                   // print(categories_Cards);
                          //                   // print(selectedCategories);
                          //                   // print("Close icon tapped!");
                          //                   // setState(() {
                          //                   //   _isTapped[index] =
                          //                   //       true; // Mark it as tapped
                          //                   //   categories_Cards
                          //                   //       .remove(cardTitles[index]);
                          //                   //   selectedCategories
                          //                   //       .remove(cardTitles[index]);
                          //                   // });
                          //                   // Future.delayed(
                          //                   //     Duration(milliseconds: 300), () {
                          //                   //   setState(() {
                          //                   //     _isTapped[index] =
                          //                   //         false; // Reset after the delay
                          //                   //   });
                          //                   // });
                          //                 },
                          //                 child: MouseRegion(
                          //                   onEnter: (_) => setState(() {
                          //                   //   if (!_isTapped[index]) {
                          //                   //     // Only change on hover if it's not tapped
                          //                   //     _isHovered[index] = true;
                          //                   //   }
                          //                   // }),
                          //                   // onExit: (_) => setState(() {
                          //                   //   if (!_isTapped[index]) {
                          //                   //     // Only reset hover if it's not tapped
                          //                   //     _isHovered[index] = false;
                          //                   //   }
                          //                   }),
                          //                   child: Icon(
                          //                     Icons.close,
                          //                     // color: _isTapped[index]
                          //                     //     ? Colors
                          //                     //         .red // If tapped, color it red
                          //                     //     : (_isHovered[index]
                          //                     //         ? Colors.red
                          //                     //         : inner_background()), // If hovered, color it red
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //   ],
                          // );