import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/admin_dashboard.dart';
import 'package:orderease/Manager/considated_bill.dart';
import 'package:orderease/Manager/mg_category_dashboard.dart';
import 'package:orderease/Settlements/analytics_dashboard.dart';
import 'package:orderease/util_components/profile.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Completed_Settlements_Dashboard extends StatefulWidget {
  final String hotel_loc;
  final String table_option;

  const Completed_Settlements_Dashboard({
    super.key,
    required this.hotel_loc,
    required this.table_option,
  });

  @override
  State<Completed_Settlements_Dashboard> createState() =>
      Completed_Settlements_DashboardState();
}

Map<String, dynamic>? data;
late Future<List<Map<String, dynamic>>> menu_items;
bool _isLoading = true;
bool _isfetched = false;
List? d;

class Completed_Settlements_DashboardState
    extends State<Completed_Settlements_Dashboard> {
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

        String mg_email = localSessionItems["email"];
        String mg_name = localSessionItems["mg_name"];
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
              if (itemmap['prepared_status'] == true) {
                itemmap['food_item'] = key;
                itemmap['table_number'] = table_number;
                itemmap['mg_email'] = mg_email;
                itemmap['mg_name'] = mg_name;
                d!.add(itemmap);
              }
            }
          } else {
            print("Skipping key $key: value is not a List");
          }
        }
      }

      d!.sort((a, b) {
        return a['timestamp'].compareTo(b['timestamp']);
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

  }

  @override
  Widget build(BuildContext context) {
    Future<List<Map<String, dynamic>>> getSettlements() async {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.hotel_loc)
          .collection("Settlements")
          .get();

      print("TABLE ${widget.table_option} SETTLEMENTS DATA:");
      List<Map<String, dynamic>> data = [];

      // Table specific filtering
      for (var doc in snapshot.docs) {
        if (widget.table_option != "all") {
          if (doc['table_option'] != widget.table_option) {
            continue;
          }
        }
        data.add(doc.data() as Map<String, dynamic>);
      }

      data.sort(
          (a, b) => int.parse(a["bill_no"]).compareTo(int.parse(b["bill_no"])));
      print("FOD_DATA1");
      for (var doc in data) {
        print(doc);
        break;
      }
      print("FOD_DATA2");

      return data;
    }

    // Refreshing the page
    Future<void> refreshPage() async {
      setState(() {
        menu_items = getSettlements();
      });
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: outer_background(),
        title: Text(
          "Completed Orders",
          style: TextStyle(fontSize: isTablet ? 24 : 20, color: inner_background(), fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
      ),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        color: outer_background(),
        child: FutureBuilder(
          future: getSettlements(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CustomLoader(message: 'Loading completed settlements...');
            }

            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return Center(
                child: Text(
                  "📄 No settlements available yet.\nCheck again later!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              );
            }

            List settlements = snapshot.data as List;
            print("Inside cleared");
            print(settlements);

            return ListView.builder(
              itemCount: settlements.length,
              itemBuilder: (context, index) {
                return settlementCard(settlements[index]);
              },
            );
          },
        ),
      ),
    );
  }

  // Date and Time Formatter

  String formatDate(String iso) {
    return iso.split("T")[0];
  }

  String formatTime(String iso) {
    String t = iso.split("T")[1];
    String hour = t.split(":")[0];
    String time_status = "";
    if (int.parse(hour) >= 12) {
      time_status = " pm";
    } else {
      time_status = " am";
    }
    return t.split(".")[0].substring(0, 5) + time_status; // HH:MM
  }

  Widget buildTimeDetails(Map<String, dynamic> s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date & Time",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        _buildTimeRow(
          icon: Icons.play_circle_fill,
          title: "Session Started",
          date: formatDate(s['session_start_time']),
          time: formatTime(s['session_start_time']),
        ),
        Divider(color: Colors.grey[300]),
        _buildTimeRow(
          icon: Icons.receipt_long,
          title: "Bill Generated",
          date: formatDate(s['generate_bill_time']),
          time: formatTime(s['generate_bill_time']),
        ),
        Divider(color: Colors.grey[300]),
        _buildTimeRow(
          icon: Icons.check_circle,
          title: "Settled At",
          date: formatDate(s['settled_time']),
          time: formatTime(s['settled_time']),
        ),
      ],
    );
  }

// REUSABLE ROW WIDGET
  Widget _buildTimeRow({
    required IconData icon,
    required String title,
    required String date,
    required String time,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 22),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              date,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget settlementCard(Map<String, dynamic> s) {
    // For Food modal sheet
    void get_food_items() {
      List<Map<String, dynamic>> food_data = [];
      print(s);
      for (var key in s.keys.toList()) {
        if (s[key] is Map) {
          s[key]['food_name'] = key;
          food_data.add(s[key]);
        }
      }
      print("food_data3");
      print(food_data);
      showSettledItemsBottomSheet(context, food_data);
    }

    return InkWell(
        onTap: () {
          get_food_items();
        },
        child: Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BILL NO + STATUS BADGE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bill No: ${s['bill_no']}",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: s['paid_status'] == true
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      child: Text(
                        s['paid_status'] == true ? "Settled" : "Pending",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                // TABLE + MANAGER NAME
                Text("Table: ${s['table_option']}",
                    style: TextStyle(fontSize: 15, color: Colors.grey[800])),

                Text("Manager: ${s['mg_name']}",
                    style: TextStyle(fontSize: 15, color: Colors.grey[800])),

                SizedBox(height: 10),

                Divider(),

                SizedBox(height: 10),

                // AMOUNT SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Actual Price:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    Text("₹ ${s['actual_price']}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),

                SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Settled Price:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    Text("₹ ${s['discount_amount']}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),

                SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Mode of Payment:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    Text("${s['mode_of_payment']}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),

                SizedBox(
                  height: 6,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Food items: ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    InkWell(
                      onTap: () {
                        get_food_items();
                      },
                      child: Text("View",
                          style: TextStyle(
                              color: outer_background(),
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Avail Bill: ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    InkWell(
                      onTap: () {
                        showQR(context, widget.hotel_loc, s['table_option'], int.parse(s['bill_no']), "bill_Status", "", true);
                      },
                      child: Text("Show QR",
                          style: TextStyle(
                              color: outer_background(),
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),

                SizedBox(height: 15),

                Divider(),

                SizedBox(height: 12),

                // TIME DETAILS
                buildTimeDetails(s),

                SizedBox(height: 10),

                // REMARK IF EXISTS
                if (s['remark'] != null &&
                    s['remark'].toString().trim().isNotEmpty)
                  Text("Remark: ${s['remark']}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[800])),
              ],
            ),
          ),
        ));
  }

  void showSettledItemsBottomSheet(
      BuildContext context, List<Map<String, dynamic>> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            // MAIN SHEET
            Container(
              margin: const EdgeInsets.only(top: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.6,
                maxChildSize: 0.9,
                minChildSize: 0.4,
                expand: false,
                builder: (_, controller) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          height: 5,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Settled Food Items",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            controller: controller,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black12, width: 1.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item['food_name'],
                                        style: const TextStyle(fontSize: 16)),
                                    Text("× ${item['quantity']}",
                                        style: const TextStyle(fontSize: 16)),
                                    Text("₹${item['price']}",
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ❌ Floating Close Button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
