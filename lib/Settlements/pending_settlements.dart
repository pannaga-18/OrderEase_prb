import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/Review_System/review_system.dart';
import 'package:orderease/Settlements/Bill_Print/print_bill.dart';
import 'package:orderease/util_components/profile.dart';
import 'package:orderease/util_components/util.dart';
import 'package:intl/intl.dart';

import '../util_components/QR_Code/qr_code.dart';

class PendingSettlements extends StatefulWidget {
  final String href;
  final String table_option;
  const PendingSettlements(
      {super.key, required this.href, required this.table_option});

  @override
  State<PendingSettlements> createState() => _PendingSettlementsState();
}

TextEditingController _discountAmountController = TextEditingController();

class _PendingSettlementsState extends State<PendingSettlements> {
  bool isOperationLoading = false;

  //Edit Access
  Future<bool> _show_Alert_before_edit(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                edit_status!
                    ? "Lock Edit Discount Amount!"
                    : "Unlock Edit Discount Amount!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content:
                  edit_status! ? null : Text("Do you want to edit the total?"),
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

  void showUpiQrDialogStatic({
    required BuildContext context,
    required String hotelName,
    required String upiId,
    required double amount,
  }) {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final media = MediaQuery.of(context);
              final isLandscape = media.orientation == Orientation.landscape;

              // ---- Responsive width ----
              final double dialogWidth = media.size.width < 400
                  ? media.size.width * 0.95
                  : isLandscape
                      ? media.size.width * 0.50
                      : media.size.width * 0.85;

              // ---- Responsive QR size (key part) ----
              final double qrSize = dialogWidth * 0.55 > 220
                  ? 220
                  : dialogWidth * 0.55 < 140
                      ? 140
                      : dialogWidth * 0.55;

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: dialogWidth,
                  maxHeight: media.size.height * 0.85,
                ),

                // ---- SCROLL SAFE ----
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ---------- TITLE ----------
                        Text(
                          "Pay via UPI",
                          style: TextStyle(
                            fontSize: media.textScaleFactor > 1.1 ? 20 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ---------- HOTEL ----------
                        Text(
                          hotelName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ---------- AMOUNT ----------
                        Text(
                          "₹ ${amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ---------- QR BOX ----------
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              // 🔳 STATIC QR IMAGE (RESPONSIVE)
                              Image.asset(
                                'assets/images/qr_code.png',
                                width: qrSize,
                                height: qrSize,
                                fit: BoxFit.contain,
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "Scan with any UPI app",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ---------- UPI ID ----------
                        Text(
                          "UPI ID: $upiId",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ---------- ACTIONS ----------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
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

  void _showPaymentOptions(BuildContext rootContext) {
    final TextEditingController _remarksController = TextEditingController();
    final GlobalKey<FormState> amountKey = GlobalKey<FormState>();
    String? _selectedPaymentMode;
    edit_status = false;

    showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 40), // space for the X button
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 50,
                                height: 4,
                                margin: EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            Text('Select Payment Mode',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            ListTile(
                              leading: Icon(Icons.account_balance_wallet),
                              title: Text('UPI'),
                              trailing: _selectedPaymentMode == 'UPI'
                                  ? Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : null,
                              onTap: () {
                                showUpiQrDialogStatic(
                                    context: context,
                                    hotelName:
                                        widget.href.split("_")[1].toUpperCase(),
                                    upiId: "sgs_demo@ibl",
                                    amount: double.parse(
                                        _discountAmountController.text));
                                setModalState(() {
                                  _selectedPaymentMode = 'UPI';
                                });
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.credit_card),
                              title: Text('Card'),
                              trailing: _selectedPaymentMode == 'Card'
                                  ? Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : null,
                              onTap: () {
                                setModalState(() {
                                  _selectedPaymentMode = 'Card';
                                });
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.money),
                              title: Text('Cash'),
                              trailing: _selectedPaymentMode == 'Cash'
                                  ? Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : null,
                              onTap: () {
                                setModalState(() {
                                  _selectedPaymentMode = 'Cash';
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            Text('Enter Remarks',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _remarksController,
                              decoration: InputDecoration(
                                hintText: 'Enter any remarks...',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 20),
                            Text('Enter Discounted Amount',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Form(
                              key: amountKey,
                              child: TextFormField(
                                readOnly: !edit_status!,
                                controller: _discountAmountController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a discount amount.";
                                  }
                                  final parsed = double.tryParse(value);
                                  if (parsed == null || parsed < 0) {
                                    return "Amount must be a positive number.";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter final bill amount...',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      _show_Alert_before_edit(context)
                                          .then((value) {
                                        if (value) {
                                          setModalState(() {
                                            edit_status = !edit_status!;
                                          });
                                          showSlideFromLeftSnackBar(
                                              context,
                                              "You can now edit the total!!",
                                              "success");
                                        }
                                      });
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      color: edit_status! ? Colors.green : null,
                                    ),
                                  ),
                                  fillColor: Colors.grey[100],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: isOperationLoading
                                    ? null
                                    : () async {
                                        if (_selectedPaymentMode == null) {
                                          Navigator.pop(context);

                                          showBounceSnackBar(
                                              context,
                                              "Please select a payment method",
                                              "warning");

                                          return;
                                        }

                                        if (amountKey.currentState!
                                            .validate()) {
                                          setState(() {
                                            isOperationLoading = true;
                                          });

                                          var remark = _remarksController.text;
                                          final discount =
                                              _discountAmountController.text;
                                          print(_selectedPaymentMode);
                                          print(discount);
                                          print(remark);

                                          if (remark.length == 0) {
                                            remark = "";
                                          }

                                          // List<FoodItem> food_items_list = [];

                                          // final Map<String, dynamic>
                                          //     sessionSnapshot =
                                          //     Map.from(localSessionItems);

                                          // int id = 0;
                                          // for (var food in sessionSnapshot.keys
                                          //     .toList()) {
                                          //   id += 1;
                                          //   food_items_list.add(FoodItem(
                                          //       id: id.toString(),
                                          //       name: food,
                                          //       category: ""));
                                          // }

                                          Map<String, dynamic> result_data =
                                              await createSettlementsCollection(
                                                  remark,
                                                  discount,
                                                  _selectedPaymentMode);
                                          setState(() {
                                            isOperationLoading = false;
                                          });

                                          Navigator.pop(context);

                                          showSlideFromLeftSnackBar(
                                              context,
                                              "Order Settled Successfully",
                                              "success");

                                          print("Food for review");
                                          print(localSessionItems);

                                          if (result_data['res']) {
                                            print("RESUL");
                                            print(result_data);

                                            // showQR(
                                            //     context,
                                            //     widget.href,
                                            //     widget.table_option,
                                            //     int.parse(
                                            //         result_data['bill_no']),
                                            //     "bill_status",
                                            //     "");

                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TableQRWidget(
                                                    hotelId: widget.href,
                                                    tableId:
                                                        widget.table_option,
                                                    bill_no: int.parse(
                                                        result_data['bill_no']),
                                                    qr_status: "bill_status",
                                                    session_table_id: "",
                                                    modal_status: false,
                                                  ),
                                                ));
                                           
                                          }
                                        } else {
                                          return;
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: outer_background(),
                                  foregroundColor: inner_background(),
                                ),
                                child: Text(isOperationLoading
                                    ? "Settling Order..."
                                    : 'Settle Order'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // child:  <-- PLACE YOUR WIDGET HERE
            ),

            // ✖ FLOATING CLOSE BUTTON
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
                    decoration: BoxDecoration(
                      color: Colors.black87, // circle color
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
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

  

  // Settlements
  Future<Map<String, dynamic>> createSettlementsCollection(
      String remark, String amt, String? mode_of_payment) async {
    print("object");
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.href)
        .collection("Transactions")
        .get();

    String? docId;
    String? final_bill_no;
    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    print(documents.length);
    print(widget.table_option);
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

    QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.href)
        .collection("Settlements")
        .get();
    int bill_no = querySnapshot1.size;

    print(docId);
    print("ID");

    if (docId != null) {
      print("PP");
      // Document exists, update it
      Map<String, dynamic> bill_data =
          documentSnapshot!.data() as Map<String, dynamic>;
      bill_data['paid_status'] = true;
      bill_data['settled_time'] = DateTime.now().toIso8601String();
      bill_data['table_option'] = widget.table_option;
      bill_data['status'] = "Paid";
      bill_data['mode_of_payment'] = mode_of_payment ?? "Not Specified";
      bill_data['remark'] = remark;
      // bill_data['paid_amount'] = amt;
      bill_data['bill_no'] = '${bill_no + 1}';
      bill_data['actual_price'] = total;
      bill_data['discount_amount'] = amt;

      final_bill_no = bill_data['bill_no'];
      

      // Creation of Collection
      await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.href)
          .collection("Settlements")
          .doc(docId)
          .set(bill_data, SetOptions(merge: true));

      // Delete from bill, transactions and vacant the table

      await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.href)
          .collection("Transactions")
          .doc(docId)
          .delete();
      await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.href)
          .collection("Bill")
          .doc(docId)
          .delete();
      await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.href)
          .collection("Cook")
          .doc(docId)
          .delete();

      List<dynamic> status_list = [false, ""];

      await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.href)
          .update({'table_status.${widget.table_option}': status_list});

      print("Transaction Collection Updated");

      refreshPage();
      print(bill_data);
      print(final_bill_no);

      print("RETURNING");

      // Log
      String email = FirebaseAuth.instance.currentUser!.email!;
      await addLogEntry(
        hotelId: widget.href,
        userEmail: email,
        action: "Bill Settled",
        tableNumber: widget.table_option.toString().toLowerCase(),
        sessionId: docId ?? "",
      );
    }
    // print(bill_data);
    return {"res": true, "bill_no": final_bill_no.toString()};
  }

  bool? edit_status = false;
  Map<String, dynamic> localSessionItems = {};
  String subtotal = "0.0";
  String total = "0.0";
  int itemsLength = 0;
  String gst = "";
  String gstin = "";
  Map<String, dynamic>? data;
  late Future<void> menu_items;
  bool _isLoading = true;
  bool _isfetched = false;
  Iterable? docids;
  List? d;
  Map<String, Map<String, dynamic>> tableData = {};
  String globalStoredID = "";

  // from bill colections
  String mg_name = "";
  String generate_bill_date = "";
  String generate_bill_time = "";
  String email = "";

  Future<void> fetch_menu_data_locally() async {
    gst = "";
    gstin = "";
    mg_name = "";
    generate_bill_date = "";
    generate_bill_time = "";
    email = "";
    _discountAmountController.text = "";
    total = "";

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.href)
        .get();
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    gst = data['gst_rate'];
    gstin = data['gst_no'];
    print(gst);
    print("GST");

    subtotal = "0.0";
    total = "0.0";
    d = [];
    localSessionItems = {};

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.href)
        .collection("Transactions")
        .get();

    print("SNAP");
    print(querySnapshot.size);

    if (querySnapshot.size != 0) {
      for (var doc in querySnapshot.docs) {
        if (doc.id.split("_")[1] == widget.table_option) {
          globalStoredID = doc.id;
          break;
        }
      }
      print("GID");
      print(globalStoredID);
      if (globalStoredID != '') {
        print("PPPP");
        print(globalStoredID);
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("Hotels")
            .doc(widget.href)
            .collection("Transactions")
            .doc(globalStoredID)
            .get();

        if (documentSnapshot.exists) {
          localSessionItems = documentSnapshot.data() as Map<String, dynamic>;

          email = localSessionItems['email'];
          DateTime dateTime =
              DateTime.parse(localSessionItems["generate_bill_time"]);
          generate_bill_date = DateFormat('dd/MM/yyyy').format(dateTime);

          generate_bill_time = DateFormat('HH:mm:ss').format(dateTime);
          mg_name = localSessionItems["mg_name"];

          localSessionItems = Map.fromEntries(localSessionItems.entries.where(
              (entry) =>
                  entry.key != "status" &&
                  entry.key != "timestamp" &&
                  entry.key != "email" &&
                  entry.key != "mg_name" &&
                  entry.key != "generate_bill_time" &&
                  entry.key != "table_option" &&
                  entry.key != "paid_status" &&
                  entry.key != "session_start_time" &&
                  entry.key != "status"));

          print(localSessionItems);
          print("FFF1");

          var sortedEntries = localSessionItems.entries.toList()
            ..sort((a, b) => (a.key).compareTo(b.key));

          localSessionItems = {
            for (var entry in sortedEntries) entry.key: entry.value
          } as Map<String, dynamic>;

          d = localSessionItems.keys.toList();

          itemsLength = 0;
          for (var key in localSessionItems.keys) {
            var item = localSessionItems[key];

            subtotal = (double.parse(subtotal) +
                    (double.parse(item['price']) *
                        double.parse(item['quantity'])))
                .toString();
            itemsLength += int.parse(item['quantity']);
          }

          print("FFF2");
          print(d);
          print(localSessionItems);
          print(email);
          print(mg_name);
          print(generate_bill_date);
          print(subtotal);
        }
      } else {
        print("Invalid GID");
        print(localSessionItems);
        print(d);
        print(email);
        print(mg_name);
        print(generate_bill_date);
      }

      total =
          "${double.parse(subtotal) + (double.parse(subtotal) * (double.parse(gst) / 100))}";
      print(total);
      print(":PP");
      setState(() {
        globalStoredID = globalStoredID;
        d = d;
        _isLoading = false;
        _isfetched = true;
        localSessionItems = localSessionItems;
        subtotal = subtotal;
        itemsLength = itemsLength;
        gst = gst;
        gstin = gstin;
        email = email;
        generate_bill_date = generate_bill_date;
        generate_bill_time = generate_bill_time;
        mg_name = mg_name;
        total = total;
        _discountAmountController.text = total;
      });
    }
  }

  @override
  void initState() {
    edit_status = false;
    _discountAmountController.text = "";

    print("table inside ${widget.table_option}");
    menu_items = fetch_menu_data_locally();
  }

  // Refresh

  Future<void> refreshPage() async {
    setState(() {
      menu_items = fetch_menu_data_locally();
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
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          "Pending Settlements",
          style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              color: inner_background(),
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: outer_background(),
        foregroundColor: inner_background(),
        elevation: 0,
        actions: [
          if (d != null && d!.length != 0)
            ProfileButton(
              context: context,
              hotelref: widget.href,
              isTablet: isTablet,
            ),
        ],
      ),
      body: RefreshIndicator(
          color: outer_background(),
          onRefresh: refreshPage,
          child: FutureBuilder<void>(
              future: menu_items,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CustomLoader(
                      message: 'Loading ongoing settlements...');
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
                            "🧾 No active bill found — it may be not generated yet or already settled.",
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
                } else {
                  return Padding(
                    padding: EdgeInsets.only(top: 30, left: 10, right: 10),
                    child: SingleChildScrollView(
                      physics:
                          AlwaysScrollableScrollPhysics(), // Ensures pull-down works even with less content
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Center(
                          //   child: Text(
                          //     "TAX INVOICE (${widget.table_option})",
                          //     style: TextStyle(
                          //       fontSize: 28,
                          //       fontWeight: FontWeight.w700,
                          //       color: Colors.blueGrey[900],
                          //       letterSpacing: 1.2,
                          //       shadows: [
                          //         Shadow(
                          //           offset: Offset(2, 2),
                          //           blurRadius: 4.0,
                          //           color: Colors.grey.withOpacity(0.3),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(height: 30),
                          Center(
                            child: Text(
                              "TAX INVOICE (${widget.table_option})",
                              style: TextStyle(
                                fontSize: 22,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w700,
                                color: Colors.blueGrey[900],
                              ),
                            ),
                          ),
                          Divider(thickness: 1.5, height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Date: $generate_bill_date",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Manager: $mg_name",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          _buildTableView(),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "GSTIN: $gstin",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                "Time: $generate_bill_time",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 50),
                          Padding(
                            padding: EdgeInsets.only(left: 15, right: 16),
                            child: Center(
                                child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor: outer_background(),
                                      foregroundColor: inner_background(),
                                    ),
                                    onPressed: () {
                                      print(globalStoredID);
                                      print("GID");
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BillPreviewPage(
                                                    table_uid: globalStoredID,
                                                    href: widget.href,
                                                    table_option:
                                                        widget.table_option,
                                                    generate_bill_time:
                                                        generate_bill_time,
                                                    generate_bill_date:
                                                        generate_bill_date,
                                                    subtotal: subtotal,
                                                    gst: gst,
                                                    gstin: gstin,
                                                    email: email,
                                                    mg_name: mg_name,
                                                    final_amount: total,
                                                    localSessionItems:
                                                        localSessionItems,
                                                    isWebView: false,
                                                    bill_no: "",
                                                  )));
                                    },
                                    child: Text(
                                      "Generate Bill",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor: outer_background(),
                                      foregroundColor: inner_background(),
                                    ),
                                    onPressed: () {
                                      _showPaymentOptions(context);
                                    },
                                    child: Text(
                                      "Settle Pending Orders",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              })),
    );
  }

  Widget _buildTableView() {
    return Table(
      border: TableBorder.all(),
      columnWidths: {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        _tableRow(["Item", "Qty", "Rate / item", "Amount"], isHeader: true),
        ...d!.map((itemKey) {
          final item = localSessionItems[itemKey];
          final name = itemKey; // Or use a `name` field if available
          int quantity = int.parse(item['quantity']);
          int cancelled = int.parse(item['cancelled']);
          int bill_qty = quantity - cancelled;
          double price = double.parse(item['price']);
          double amt = bill_qty * price;
          final qty = (bill_qty).toString();
          final rate = "₹${item['price']}";
          final amount = "₹${amt}";

          return _tableRow([name, qty, rate, amount]);
        }).toList(),
        _tableRow(["Subtotal", "", "", "₹$subtotal"]),
        _tableRow([
          "SGST (${double.parse(gst) / 2}%)",
          "",
          "",
          "₹${double.parse(subtotal) * (double.parse(gst) / 200)}"
        ]),
        _tableRow([
          "CGST (${double.parse(gst) / 2}%)",
          "",
          "",
          "₹${double.parse(subtotal) * (double.parse(gst) / 200)}"
        ]),
        _tableRow(["Total", "", "", "₹${total}"]),
      ],
    );
  }

  TableRow _tableRow(List<String> values, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(color: isHeader ? Colors.grey[300] : null),
      children: values.map((text) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
          ),
        );
      }).toList(),
    );
  }
}
