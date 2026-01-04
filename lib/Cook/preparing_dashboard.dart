import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/admin_dashboard.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/Manager/considated_bill.dart';
import 'package:orderease/Manager/mg_category_dashboard.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cook_Preparing_Dashboard extends StatefulWidget {
  final String hotel_loc;

  const Cook_Preparing_Dashboard({
    super.key,
    required this.hotel_loc,
  });

  @override
  State<Cook_Preparing_Dashboard> createState() =>
      Cook_Preparing_DashboardState();
}

Map<String, dynamic>? data;
late Future<void> menu_items;
bool _isLoading = true;
bool _isfetched = false;
List? d;


class Cook_Preparing_DashboardState extends State<Cook_Preparing_Dashboard> {
  Map<String, dynamic> localSessionItems = {};
  int itemsLength = 0;

  Future<void> fetch_menu_data_locally() async {
    d = [];
    localSessionItems = {};

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.hotel_loc)
        .collection("Cook")
        .get();

    print("SNAP");
    print(querySnapshot.size);

    if (querySnapshot.size != 0) {
      for (var doc in querySnapshot.docs) {
        String table_number = doc.id.split("_")[1];
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("Hotels")
            .doc(widget.hotel_loc)
            .collection("Cook")
            .doc(doc.id)
            .get();

        localSessionItems = documentSnapshot.data() as Map<String, dynamic>;
        print("LOCAL SESSION ITEMS");
        print(localSessionItems);




      // GETT TABLE UID FOR LOG



        String mg_email = localSessionItems["email"];
        String mg_name = localSessionItems["mg_name"];
        String table_uid = doc.id;

        localSessionItems =
            Map.fromEntries(localSessionItems.entries.where((entry) {
          return entry.key != "status" && entry.key != "timestamp";
        }));
        itemsLength = localSessionItems.length;

        print("LOCAL SESSION ITEMS");
        print(localSessionItems);

        Map<String, dynamic> copyLocalSessionItems =
            Map.from(localSessionItems); // Create a copy of the map

        print("COPY LOCAL SESSION ITEMS");
        print(copyLocalSessionItems.keys.toList());

        for (var key in copyLocalSessionItems.keys) {
          var value = copyLocalSessionItems[key];
          if (value is List) {
            for (var itemmap in value) {
              if (itemmap['prepared_status'] == false) {
                itemmap['food_item'] = key;
                itemmap['table_number'] = table_number;
                itemmap['mg_email'] = mg_email;
                itemmap['mg_name'] = mg_name;
                itemmap['table_uid'] = table_uid;
                d!.add(itemmap);
              }
            }
          } else {
            print("Skipping key $key: value is not a List");
          }
        }
      }

      d!.sort((a, b) {
        DateTime timeA = DateTime.parse(a['timestamp']);
        DateTime timeB = DateTime.parse(b['timestamp']);
        return timeA.compareTo(timeB); // oldest → newest
      });

      print(d);
      print("LOCAL SESSION ITEM333");

      setState(() {
        d = d;
        _isLoading = false;
        _isfetched = true;
        localSessionItems = localSessionItems;
        itemsLength = itemsLength;
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
    Future<void> updatePreparedStatus(BuildContext dialogContext,
        String food_name, String table_no, String preparing_qty) async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.hotel_loc)
          .collection("Cook")
          .get();

      String? docId;
      for (var doc in querySnapshot.docs) {
        if (doc.id.split("_")[1] == table_no) {
          docId = doc.id;
          break;
        }
      }

      if (querySnapshot.size != 0) {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection("Hotels")
            .doc(widget.hotel_loc)
            .collection("Cook")
            .doc(docId);

        DocumentSnapshot documentSnapshot = await docRef.get();

        Map<String, dynamic>? data;
        if (documentSnapshot.exists) {
          data = documentSnapshot.data() as Map<String, dynamic>;
        }

        List<dynamic> foodSessionItems = data![food_name] ?? [];

        if (foodSessionItems.isNotEmpty) {
          for (var item in foodSessionItems) {
            if (item['prepared_status'] == false &&
                item['preparing'] == preparing_qty.toString()) {
              item['prepared_status'] = true;

              item['prepared_time'] = DateTime.now().hour.toString() +
                  ":" +
                  DateTime.now().minute.toString();
              item['prepared'] = preparing_qty;
              item['preparing'] = "0";
              break;
            }
          }
        }

        data[food_name] = foodSessionItems;

        print("DATA");
        print(data);

        await docRef.set(data, SetOptions(merge: true));
        DocumentSnapshot documentSnapshot1 = await FirebaseFirestore.instance
            .collection("Hotels")
            .doc(widget.hotel_loc)
            .collection("Bill")
            .doc(docId)
            .get();

        Map<String, dynamic>? data1 =
            documentSnapshot1.data() as Map<String, dynamic>?;

        int preparing_qty_to_update =
            int.parse(data1![food_name]['preparing']) -
                int.parse(preparing_qty);

        int preparied_qty_to_update =
            int.parse(data1![food_name]['prepared']) + int.parse(preparing_qty);

        await FirebaseFirestore.instance
            .collection("Hotels")
            .doc(widget.hotel_loc)
            .collection("Bill")
            .doc(docId)
            .update({
          "$food_name.prepared": preparied_qty_to_update.toString(),
          "$food_name.preparing": preparing_qty_to_update.toString(),
        });

        showSlideFromLeftSnackBar(context, "Food Status Updated!", "success");

        // Navigator.of(dialogContext).pop();

        setState(() {
          menu_items = fetch_menu_data_locally();
        });
      }
    }

    // Edit for Prepared status
    Future<bool> _showConfirmDialog(BuildContext context, String food_name,
        String table_no, String preparing_qty, String tableUid) async {
      return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          bool isOperationLoading = false;

          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: dark_outer_background(), size: 30),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              "Mark '${food_name.toUpperCase()}' as prepared and ready to serve?",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),

                      // BUTTONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              backgroundColor: inner_background(),
                              foregroundColor: outer_background(),
                            ),
                            child: Text("Cancel"),
                          ),

                          SizedBox(width: 10),

                          // READY TO SERVE
                          ElevatedButton(
                            onPressed: isOperationLoading
                                ? null
                                : () async {
                                    setState(() => isOperationLoading = true);

                                    // Log
                                    String email = FirebaseAuth
                                        .instance.currentUser!.email!;
                                    await addLogEntry(
                                      hotelId: widget.hotel_loc,
                                      userEmail: email,
                                      action: "Food served",
                                      tableNumber: table_no.toLowerCase(),
                                      sessionId: tableUid,
                                    );

                                    await updatePreparedStatus(context,
                                        food_name, table_no, preparing_qty);

                                    Navigator.of(context).pop(
                                        true); // CLOSE DIALOG & RETURN VALUE
                                  },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: inner_background(),
                              backgroundColor: outer_background(),
                            ),
                            child: isOperationLoading
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Serving..."),
                                      SizedBox(width: 8),
                                      ...getCircularProgressIndicator() // Correct usage
                                    ],
                                  )
                                : Text("Ready to Serve"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ).then((value) => value ?? false);
    }

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

    String getTime(String timestamp) {
      int hour = timestamp != null && timestamp.contains(":")
          ? int.parse(timestamp.split(":")[0])
          : 0;
      int minute = timestamp != null && timestamp.contains(":")
          ? int.parse(timestamp.split(":")[1])
          : 0;
      if (hour > 12) {
        hour = hour - 12;
        return "${hour}:$minute PM";
      } else {
        return "${hour}:$minute AM";
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: outer_background(),
        title: Text(
          "Ongoing Orders",
          style: TextStyle(
              fontSize: 23,
              color: inner_background(),
              fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: inner_background()),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          ProfileButton(
              context: context, hotelref: widget.hotel_loc, isTablet: isTablet)
        ],
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       // Profile icon action
        //       logout(context);
        //     },
        //     icon:
        //         Icon(Icons.account_circle, size: 30, color: inner_background()),
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        color: outer_background(),
        child: FutureBuilder<void>(
          future: menu_items,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CustomLoader(message: 'Loading items...');
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
                        "🧑‍🍳 All caught up!\nYou'll see new orders here once they’re sent to the kitchen.",
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
                        child: CustomLoader(
                            message: 'Loading items to be prepared...'))
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              padding: EdgeInsets.all(4),
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
                                padding: const EdgeInsets.all(2.0),
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // 🧾 Main info column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // 🔹 Food item name
                                              Text(
                                                d![index]['food_item']
                                                    .toString()
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),

                                              // 🔹 Food item description

                                              d![index]['description'] != ""
                                                  ? Text(
                                                      "Note: ${d![index]['description']}"
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                      ),
                                                    )
                                                  : Container(),
                                              const SizedBox(height: 4),

                                              // 🔹 Table number and Quantity
                                              Row(
                                                children: [
                                                  Icon(Icons.table_restaurant,
                                                      size: 16,
                                                      color: Colors.grey[700]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${d![index]['table_number']}",
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Icon(Icons.restaurant_menu,
                                                      size: 18,
                                                      color: Colors.grey[700]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Qty: ${d![index]['preparing']}",
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 4),

                                              // 🔹 Manager email
                                              Text(
                                                "Manager: ${d![index]['mg_name']}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              // 🔹 Timestamp
                                              Text(
                                                "Ordered at: ${getTime(d![index]['timestamp'].toString().split("T")[1].substring(0, 5))}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ✅ Action button
                                        IconButton(
                                          icon: Icon(
                                              Icons
                                                  .check_circle_outline_rounded,
                                              color: dark_outer_background(),
                                              size: 28),
                                          onPressed: () async {
                                            bool res = await _showConfirmDialog(
                                                context,
                                                d![index]['food_item']
                                                    .toString(),
                                                d![index]['table_number']
                                                    .toString(),
                                                d![index]['preparing']
                                                    .toString(),
                                                d![index]['table_uid']);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ));
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
