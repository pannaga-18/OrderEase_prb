import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillSummarySection extends StatefulWidget {
  final String subTotal;
  final String itemsLength;
  final String screen_label;
  final String table_option;
  final String href;
  final String gst;
  final VoidCallback orderPlaced;
  final String screen_label_for_bill;
  const BillSummarySection(
      {Key? key,
      required this.subTotal,
      required this.itemsLength,
      required this.screen_label,
      required this.table_option,
      required this.href,
      required this.gst,
      required this.orderPlaced,
      required this.screen_label_for_bill});
  @override
  BillSummarySectionState createState() => BillSummarySectionState();
}

class BillSummarySectionState extends State<BillSummarySection> {
  bool isOperationLoading = false;

  Map<String, Map<String, dynamic>> tableData = {};
  Future<void> updateToBillCollection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? storedStatus = prefs.getBool("isBlocked_${widget.table_option}");
    print(storedStatus);

    // Block or not
    if (storedStatus == null) {
      showBounceSnackBar(context, "Block the session!!", "warning");
    } else if (storedStatus == true) {
      Map<String, dynamic> new_table_data = {};

      tableData = {};
      String? mapJson = prefs.getString('tableData');
      if (mapJson != null) {
        Map<String, dynamic> decodedData = jsonDecode(mapJson);

        tableData = decodedData.map(
            (key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
      }
      String? uid = prefs.getString("uid_${widget.table_option}");

      String docId = uid! + "_${widget.table_option}";
      print("LOADED MAP DATA for BILL");

      // New Data without food items for Next Local Storage
      new_table_data = Map.fromEntries(tableData[docId]!
          .entries
          .where((entry) => entry.key != "status" && entry.key != "timestamp"));

      if (new_table_data.isNotEmpty) {
        // if(new_table_data.)

        var user = FirebaseAuth.instance.currentUser;

        print(user!.email);

        // Adding email to the Map
        tableData[docId]?['email'] = user.email;

        DocumentSnapshot documentSnapshot2 = await FirebaseFirestore.instance
            .collection("Hotels")
            .doc(widget.href)
            .collection("Users")
            .doc(user.email)
            .get();

        if (documentSnapshot2.exists) {
          Map<String, dynamic>? userData =
              documentSnapshot2.data() as Map<String, dynamic>;
          tableData[docId]?['mg_name'] = userData['name'];
        }

        print(tableData);

        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("Hotels")
            .doc(widget.href)
            .collection("Bill")
            .doc(docId)
            .get();

        DocumentSnapshot documentSnapshot1 = await FirebaseFirestore.instance
            .collection("Hotels")
            .doc(widget.href)
            .collection("Cook")
            .doc(docId)
            .get();

         // Log
          String email = FirebaseAuth.instance.currentUser!.email!;
          await addLogEntry(
            hotelId: widget.href,
            userEmail: email,
            action: "Order Placed.",
            tableNumber: widget.table_option,
            sessionId: docId,
          );

        Map<String, dynamic>? billData;
        Map<String, dynamic>? cookData;
        if (documentSnapshot.exists && documentSnapshot1.exists) {
          billData = documentSnapshot.data() as Map<String, dynamic>;
          cookData = documentSnapshot1.data() as Map<String, dynamic>;

         

          // Map<String, dynamic> itemsMap = billData[docId];
          // billData = Map.fromEntries(billData.entries.where((entry) => entry.key != "status" && entry.key != "timestamp" && entry.key != "email"));
          print(cookData);
          print("PP");

          Map<String, dynamic>? localItemsData = tableData[docId];
          // localItemsData = Map.fromEntries(localItemsData!.entries.where((entry) => entry.key != "status" && entry.key != "timestamp" && entry.key != "email"));
          print(localItemsData);
          print("PP11234");
          for (var key in localItemsData!.keys) {
            // Second session data
            // if new item add into billData
            if (!billData.containsKey(key)) {
              billData[key] = localItemsData[key];

              billData[key]['preparing'] = billData[key]['quantity'];
              billData[key]['prepared'] = "0";
              billData[key]['cancelled'] = "0";
              print(billData[key]);

              // print("PP1999");
              // billData[key]['timestamp'] = DateTime.now().toIso8601String();

              // billData[key]['prepared_status'] = false; // Add prepared_status

              Map<String, dynamic> existingCookData = localItemsData[key];
              existingCookData['timestamp'] = DateTime.now().toIso8601String();
              existingCookData['prepared_status'] =
                  false; // Add prepared_status

              print("Already Existing Cook Data 1");

              existingCookData['preparing'] = localItemsData[key]['quantity'];
              existingCookData['prepared'] = "0";
              existingCookData['cancelled'] = "0";

              print(cookData[key]);

              cookData[key] = []..add(existingCookData);

              print("PP112222222");
              print(billData);
              print("PP112222222000000");
              print(billData[key]);
              print("PP112222222555555");
              print(cookData[key]);
              print("Already Existing Cook Data 2");

              // billData[key].remove('timestamp');
              // billData[key].remove('prepared_status');
              // print(billData);
              // print(cookData[key]);
              // print("PP110000000");
            }
            // already containing update it
            // If bill contains the item, then update the details
            else if (billData.containsKey(key) &&
                key != "status" &&
                key != "timestamp" &&
                key != "email" &&
                key != "mg_name") {
              String time = DateTime.now().toIso8601String();
              print(localItemsData[key]);

              if (cookData.containsKey(key)) {
                Map<String, dynamic> existingCookData = localItemsData[key];
                existingCookData['timestamp'] = time;
                existingCookData['prepared_status'] =
                    false; // Add prepared_status

                print("Already Existing Cook Data2");

                existingCookData['preparing'] = localItemsData[key]['quantity'];
                existingCookData['prepared'] = "0";
                existingCookData['cancelled'] = "0";

                cookData[key].add(existingCookData);
                print("Already Existing Cook Data 3");
                print(cookData[key]);
              }

              print("PP11");

              String localItemQuantity = localItemsData[key]['quantity'];

              String localItemDescription = localItemsData[key]['description'];

              String updatedTotalQuantity =
                  (int.parse(billData[key]['quantity']) +
                          int.parse(localItemQuantity))
                      .toString();

              String updatedPreparingQuantity =
                  (int.parse(billData[key]['preparing']) +
                          int.parse(localItemQuantity))
                      .toString();

              billData[key]['quantity'] = updatedTotalQuantity;

              billData[key]['preparing'] = updatedPreparingQuantity;

              billData[key]['description'] =
                  billData[key]['description'] + localItemDescription;
            }
          }
          print("Already Existing");
          print(cookData);

          // Updating Bill Collection
          await FirebaseFirestore.instance
              .collection("Hotels")
              .doc(widget.href)
              .collection("Bill")
              .doc(docId)
              .set(billData, SetOptions(merge: true));

          // Updating Cook Collection
          await FirebaseFirestore.instance
              .collection("Hotels")
              .doc(widget.href)
              .collection("Cook")
              .doc(docId)
              .set(cookData, SetOptions(merge: true));
        }
        // If doc not present
        else {
          print(tableData);

          for (var key in tableData[docId]!.keys) {
            if (key != 'status' &&
                key != "timestamp" &&
                key != "email" &&
                key != "mg_name") {
              tableData[docId]![key]['preparing'] =
                  tableData[docId]![key]['quantity'];
              tableData[docId]![key]['prepared'] = "0";
              tableData[docId]![key]['cancelled'] = "0";
            }
          }

          await FirebaseFirestore.instance
              .collection("Hotels")
              .doc(widget.href)
              .collection("Bill")
              .doc(docId)
              .set(tableData[docId]!, SetOptions(merge: true));

          // Add timestamp to the data
          String time = DateTime.now().toIso8601String();

          tableData[docId]!.entries.forEach((entry) {
            if (entry.key != "status" &&
                entry.key != "timestamp" &&
                entry.key != "email" &&
                entry.key != "mg_name") {
              entry.value['timestamp'] = time;
            }
          });

          tableData[docId] = tableData[docId]!.map((key, value) {
            if (key != "status" &&
                key != "timestamp" &&
                key != "email" &&
                key != "mg_name") {
              value['prepared_status'] = false; // Add prepared_status
              return MapEntry(key, [value]);
            }
            return MapEntry(key, value);
          });

          print(tableData[docId]);
          print("PP11");

          await FirebaseFirestore.instance
              .collection("Hotels")
              .doc(widget.href)
              .collection("Cook")
              .doc(docId)
              .set(tableData[docId]!, SetOptions(merge: true));
        }

        print("Updated to Bill");

        // REMOVE LOCALLY, by removing ALL the items, email from the tableData
        tableData[docId] = Map.fromEntries(tableData[docId]!.entries.where(
            (entry) => entry.key == "status" || entry.key == "timestamp"));

        print(tableData);

        String? mapJson1 = jsonEncode(tableData);

        await prefs.setString('tableData', mapJson1);

        setState(() {
          tableData = tableData;
        });

        // Snackbar
        showSlideFromLeftSnackBar(
            context, "Item added to the bill successfully!", "success");

        widget.orderPlaced();
      } else {
        //
        showBounceSnackBar(
            context,
            "Please add some items to your cart before placing the order.",
            "warning");
      }
    }
  }

  Future<void> createTransactionCollection() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.href)
        .collection("Bill")
        .get();
    String? docId;
    List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    QueryDocumentSnapshot? documentSnapshot;
    if (documents.isNotEmpty) {
      for (var document in documents) {
        if (document.id.split("_")[1] == widget.table_option) {
          // Document exists
          docId = document.id;
          documentSnapshot = document;
          break;
        }
      }
    }

    if (docId != null) {
      // Document exists, update it
      Map<String, dynamic> bill_data =
          documentSnapshot!.data() as Map<String, dynamic>;
      bill_data['paid_status'] = false;
      bill_data['generate_bill_time'] = DateTime.now().toIso8601String();
      bill_data['table_option'] = widget.table_option;
      bill_data['status'] = "Pending";
      bill_data['session_start_time'] = bill_data['timestamp'];
      bill_data.remove("timestamp");

      await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.href)
          .collection("Transactions")
          .doc(docId)
          .set(bill_data, SetOptions(merge: true));

      // Log
      String email = FirebaseAuth.instance.currentUser!.email!;
      await addLogEntry(
          hotelId: widget.href,
          userEmail: email,
          action: "Bill Generated.",
          tableNumber: widget.table_option,
          sessionId: docId ?? "");

      print("Transaction Collection Updated");
    }
  }

  // Bill Generation
  Future<bool> _show_Alert_before_bill(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Generate Bill!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text("Do you want to generate bill?"),
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
                    Navigator.of(context)
                        .pop(true); // Close dialog and return true
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Subtotal, Discount, Tax, Split Bill
          _buildRow(Icons.receipt_long, "Subtotal", widget.subTotal),
          _buildRow(Icons.local_offer, "Discount", "- 0"),
          _buildRow(Icons.percent, "Tax (${double.parse(widget.gst)}%)",
              "${((double.parse(widget.gst) / 100) * double.parse(widget.subTotal)).toStringAsFixed(2)}"),

          // 🔹 Dotted line separator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: Colors.grey,
              thickness: 2,
              indent: 5,
              endIndent: 5,
            ),
          ),

          // 🔹 Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Grand Total",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.currency_rupee_outlined,
                    size: 18,
                    color: Colors.orange,
                  ),
                  Text(
                    "${(double.parse(widget.subTotal) + 0.05 * double.parse(widget.subTotal)).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 5),

          // // 🔹 Bill per Person
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       "Bill/Person",
          //       style: TextStyle(
          //         fontSize: 16,
          //         color: Colors.black87,
          //       ),
          //     ),
          //     Text(
          //       "Rp 277.750",
          //       style: TextStyle(
          //         fontSize: 16,
          //         color: Colors.black87,
          //       ),
          //     ),
          //   ],
          // ),

          SizedBox(height: 15),

          // 🔹 Place Order Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: dark_outer_background(), // Slightly darker blue
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: isOperationLoading
                ? null
                : () async {
                    setState(() {
                      isOperationLoading = true;
                    });
                    print("Order Placed!");
                    if (widget.screen_label_for_bill ==
                        "mg_items_consolidated") {
                      await updateToBillCollection();
                    } else if (widget.screen_label_for_bill == "mg_bill") {
                      // Show confirmation dialog
                      _show_Alert_before_bill(context).then((value) async {
                        if (value == true) {
                          // setting the Document
                          createTransactionCollection();
                          showSlideFromLeftSnackBar(
                              context, "Bill Generated!", "success");
                        }
                      });
                    }
                    setState(() {
                      isOperationLoading = false;
                    });
                  },
            child: Center(
                child: widget.screen_label_for_bill == "mg_items_consolidated"
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (int.parse(widget.itemsLength) > 0)
                                ? isOperationLoading
                                    ? "Placing Order..."
                                    : "Place Order (${widget.itemsLength} items)"
                                : isOperationLoading
                                    ? "Placing Order..."
                                    : "Place Order",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          if (isOperationLoading)
                            ...getCircularProgressIndicator()
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Generate Bill",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          if (isOperationLoading)
                            ...getCircularProgressIndicator()
                        ],
                      )),
          ),
          SizedBox(height: 10),

          widget.screen_label_for_bill == "mg_items_consolidated"
              ? TextButton(
                  style: TextButton.styleFrom(
                    // backgroundColor: outer_background(), // Slightly darker blue
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // WANT TO ADD MORE.. POPPING
                    if (widget.screen_label == "mg_menu") {
                      Future.delayed(Duration(milliseconds: 10), () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });
                    } else if (widget.screen_label == "mg_search_bar") {
                      Future.delayed(Duration(milliseconds: 10), () {
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: Center(
                    child: Text(
                      "Want to add more?",
                      style: TextStyle(
                        fontSize: 16,
                        color: outer_background(),
                      ),
                    ),
                  ),
                )
              : SizedBox(height: 0),
        ],
      ),
    );
  }

  // 🔹 Helper method for rows
  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon),
              SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.currency_rupee_outlined, size: 18),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
