import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/Settlements/Bill_Print/bill_service.dart';
import 'package:orderease/util_components/util.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:orderease/Settlements/Bill_Print/bill_helper_selector.dart';

import '../../Review_System/review_system.dart';

class BillPreviewPage extends StatefulWidget {
  final String href;
  final String table_option;
  final String generate_bill_date;
  final String generate_bill_time;
  final String subtotal;
  final String gst;
  final String gstin;
  final String email;
  final String mg_name;
  final String final_amount;
  final Map<String, dynamic> localSessionItems;
  final String table_uid;
  final String bill_no;

  // flag for website
  final bool isWebView;

  const BillPreviewPage(
      {super.key,
      required this.table_uid,
      required this.href,
      required this.table_option,
      required this.generate_bill_date,
      required this.generate_bill_time,
      required this.subtotal,
      required this.gst,
      required this.gstin,
      required this.email,
      required this.mg_name,
      required this.final_amount,
      required this.localSessionItems,
      required this.isWebView,
      required this.bill_no});

  @override
  State<BillPreviewPage> createState() => _BillPreviewPageState();
}

class _BillPreviewPageState extends State<BillPreviewPage> {
  Uint8List? pdfBytes;

  bool isPdfGenerating = false;
  final billHelper = getBillHelper(); // resolved automatically

  Future<void> generate_pdf_on_load() async {
    _generatePdf(PdfPageFormat(226.4, double.infinity)).then((data) {
      setState(() {
        pdfBytes = Uint8List.fromList(data);
      });
    });
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
  bool is_data_fetched = false;
  Iterable? docids;
  List? d;
  Map<String, Map<String, dynamic>> tableData = {};
  String globalStoredID = "";

  // from bill colections
  String mg_name = "";
  String generate_bill_date = "";
  String generate_bill_time = "";
  String email = "";
  String final_amount = "";

  // from settlement collections
  String bill_no = "";

  Future<void> fetch_menu_data_locally(bool isWebView) async {
    gst = "";
    gstin = "";
    mg_name = "";
    generate_bill_date = "";
    generate_bill_time = "";
    email = "";
    final_amount = "";
    total = "";
    bill_no = "";

    if (!isWebView) {
      QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.href)
          .collection("Settlements")
          .get();

      bill_no = (querySnapshot1.size + 1).toString();

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.href)
          .get();
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

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
          d = d;
          localSessionItems = localSessionItems;
          subtotal = subtotal;
          itemsLength = itemsLength;
          is_data_fetched = true;
          gst = gst;
          gstin = gstin;
          email = email;
          generate_bill_date = generate_bill_date;
          generate_bill_time = generate_bill_time;
          mg_name = mg_name;
          total = total;
          final_amount = total;
          bill_no = bill_no;
        });
      }
    } else {
      localSessionItems = widget.localSessionItems;
      d = localSessionItems.keys.toList();
      itemsLength = d!.length;

      setState(() {
        d = d;
        localSessionItems = localSessionItems;
        subtotal = widget.subtotal;
        itemsLength = itemsLength;
        is_data_fetched = true;
        gst = widget.gst;
        gstin = widget.gstin;
        email = widget.email;
        generate_bill_date = widget.generate_bill_date;
        generate_bill_time = widget.generate_bill_time;
        mg_name = widget.mg_name;
        total = widget.final_amount;
        final_amount = widget.final_amount;
      });
    }
  }

  Future<void> initializeData(bool isWebView) async {
    print("WEBVIEW $isWebView");
    // if (!isWebView) {
    await fetch_menu_data_locally(isWebView);
    // }
    await generate_pdf_on_load();
  }

  @override
  void initState() {
    super.initState();
    final_amount = "";
    is_data_fetched = false;

    initializeData(widget.isWebView);
  }

  // Review Data Storage
  Future<bool> createReviewCollection(Map<String, dynamic> reviewData) async {
    try {
      // Convert reviewData to proper format
      // Input: {1: Instance of 'ReviewData', 2: Instance of 'ReviewData'}

      // {1: {foodId: 1, foodName: masala puri, rating: 5.0}, 2: {foodId: 2, foodName: mpeexfg, rating: 5.0}}
      final Map<String, dynamic> review_data = {};

      reviewData.forEach((key, value) {
        review_data[key.toString()] = value.toJson();
      });

      print("CONVERTED REVIEW DATA: $review_data");

      // Get reference to the document
      DocumentReference docRef = FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.href)
          .collection("Food_Reviews")
          .doc("food_review_data");

      // Check if document exists
      DocumentSnapshot documentSnapshot = await docRef.get();
      String time_stamp = DateTime.now().toIso8601String();

      if (!documentSnapshot.exists) {
        // NEW DOCUMENT - Create initial structure
        print("Creating new document");

        final Map<String, dynamic> review_data_to_store = {};

        for (var key in review_data.keys.toList()) {
          final value_map = review_data[key];
          String food_name = value_map['foodName'];
          final double food_ratings = value_map['rating'];

          review_data_to_store[food_name] = {
            "ratings": food_ratings,
            "review_food_count": 1,
            "average_ratings": food_ratings,
            "review_date_time": time_stamp
          };
        }

        await docRef.set(review_data_to_store);
        print("New document created: $review_data_to_store");
      } else {
        // EXISTING DOCUMENT - Update existing data
        print("Updating existing document");

        // Get existing data from DB
        // DB format {mpeexfg: {review_food_count: 1, ratings: 10.0, average_ratings: 10.0}, masala puri: {ratings: 37.0, review_food_count: 4, average_ratings: 9.25}}
        Map<String, dynamic> data_map =
            documentSnapshot.data() as Map<String, dynamic>;

        print("DATA FROM DB: $data_map");

        // Process each food item from the new review
        for (var key in review_data.keys.toList()) {
          final value_map = review_data[key];
          String food_name = value_map['foodName'];
          final double food_ratings = value_map['rating'];

          if (data_map.containsKey(food_name)) {
            // Food item already exists - update it
            final existing_count = data_map[food_name]['review_food_count'];
            final existing_total_ratings = data_map[food_name]['ratings'];

            // Update count and total ratings
            final new_count = existing_count + 1;
            final new_total_ratings = existing_total_ratings + food_ratings;

            data_map[food_name] = {
              "ratings": new_total_ratings,
              "review_food_count": new_count,
              "average_ratings": new_total_ratings / new_count,
              "review_date_time": time_stamp
            };
          } else {
            // New food item - add it
            data_map[food_name] = {
              "ratings": food_ratings,
              "review_food_count": 1,
              "average_ratings": food_ratings,
              "review_date_time": time_stamp
            };
          }
        }

        print("DATA TO UPDATE IN DB: $data_map");

        // Update the document
        await docRef.update(data_map);
      }

      print("Review data successfully stored!");
      return true;
    } catch (e) {
      print("Error storing review data: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: inner_background(),
      appBar: AppBar(
        backgroundColor: outer_background(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: inner_background()),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            Text('Bill Preview', style: TextStyle(color: inner_background())),
      ),
      body: pdfBytes == null
          ? CustomLoader(message: 'Loading bill...')
          : PdfPreviewView(pdfData: pdfBytes!),
      bottomNavigationBar: BottomAppBar(
        color: outer_background(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Share Button
              if (!widget.isWebView)
                ...[Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: outer_background(),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(Icons.share, size: 20),
                    label: Text('Share', style: TextStyle(fontSize: 14)),
                    onPressed: pdfBytes == null || isPdfGenerating
                        ? null
                        : () async {
                            await _handleShare();
                          },
                  ),
                ),
                SizedBox(width: 16),
                ],

              // Download/Print Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: outer_background(),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                    kIsWeb ? Icons.download : Icons.print,
                    size: 20,
                  ),
                  label: Text(
                    kIsWeb ? 'Download' : 'Print',
                    style: TextStyle(fontSize: 14),
                  ),
                  onPressed: pdfBytes == null || isPdfGenerating
                      ? null
                      : () async {
                          await _handleDownload();
                        },
                ),
              ),
              if (kIsWeb) ...[
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: outer_background(),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(
                      Icons.star_outline,
                      size: 20,
                    ),
                    label: Text(
                      'Give Feedback',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: pdfBytes == null || isPdfGenerating
                        ? null
                        : () async {
                            // Navigating to Food Review

                            List<FoodItem> food_items_list = [];
                            int id = 0;
                            for (var food_item in d!) {
                              id += 1;
                              food_items_list.add(FoodItem(
                                  id: id.toString(),
                                  name: food_item,
                                  category: ""));
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodReviewPage(
                                  tableNumber: widget.table_option,
                                  foodItems: food_items_list,
                                  onSubmitReview: (reviewData) {
                                    // Handle the review data here

                                    print('Reviews submitted: $reviewData');
                                    createReviewCollection(reviewData);
                                    // Send to backend
                                  },
                                ),
                              ),
                            );
                          },
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   color: outer_background(),
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //       children: [
      //         IconButton(
      //             icon: Icon(
      //               Icons.share,
      //               color: inner_background(),
      //               size: 30,
      //             ),
      //             onPressed: () async {
      //               // Log
      //               String email = FirebaseAuth.instance.currentUser!.email!;
      //               await addLogEntry(
      //                 hotelId: widget.href,
      //                 userEmail: email,
      //                 action: "Bill shared",
      //                 tableNumber: widget.table_option.toString().toLowerCase(),
      //                 sessionId: widget.table_uid,
      //               );
      //               Printing.sharePdf(bytes: pdfBytes!, filename: 'bill.pdf');
      //             }),
      //         IconButton(
      //             icon: Icon(Icons.print, color: inner_background(), size: 30),
      //             onPressed: () async {
      //               // Log
      //               String email = FirebaseAuth.instance.currentUser!.email!;
      //               await addLogEntry(
      //                 hotelId: widget.href,
      //                 userEmail: email,
      //                 action: "Bill downloaded",
      //                 tableNumber: widget.table_option.toString().toLowerCase(),
      //                 sessionId: widget.table_uid,
      //               );

      //               Printing.layoutPdf(
      //                 onLayout: (PdfPageFormat format) async {
      //                   return pdfBytes!;
      //                 },
      //               );
      //             }),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  Future<void> _handleShare() async {
    if (pdfBytes == null) {
      showStatusSnackBar(
          context, 'Please wait, PDF is still loading...', "warning");
      return;
    }

    try {
      // Log
      print("SHARE PDF");

      String email = FirebaseAuth.instance.currentUser?.email ?? 'unknown';
      if (email != "unknown") {
        await addLogEntry(
          hotelId: widget.href,
          userEmail: email,
          action: "Bill shared",
          tableNumber: widget.table_option.toString().toLowerCase(),
          sessionId: widget.table_uid,
        );
      }
      print(email);
      print("MM");

      if (kIsWeb) {
        // Web: Download instead of share
        billHelper.sharePdf(pdfBytes!, 'bill_${widget.table_option}.pdf');
        if (mounted) {
          showSlideFromLeftSnackBar(
              context, "Bill downloaded successfully!", "success");
        }
      } else {
        // Mobile: Use native share
        await billHelper.sharePdf(
          pdfBytes!,
          'bill_${widget.table_option}.pdf',
        );
      }
    } catch (e) {
      print('Error sharing PDF: $e');
      if (mounted) {
        showBounceSnackBar(context, "'Error sharing PDF: $e'", "fail");
      }
    }
  }

  Future<void> _handleDownload() async {
    if (pdfBytes == null) {
      showStatusSnackBar(
          context, 'Please wait, PDF is still loading...', "warning");

      return;
    }

    try {
      // Log
      String email = FirebaseAuth.instance.currentUser?.email ?? 'unknown';

      if (email != "unknown") {
        await addLogEntry(
          hotelId: widget.href,
          userEmail: email,
          action: "Bill downloaded",
          tableNumber: widget.table_option.toString().toLowerCase(),
          sessionId: widget.table_uid,
        );
      }

      print("WEB DOWN");
      print(email);
      print("MM");

      if (kIsWeb) {
        // Web: Direct download
        billHelper.sharePdf(pdfBytes!, 'bill_${widget.table_option}.pdf');
        if (mounted) {
          showSlideFromLeftSnackBar(
              context, "Bill downloaded successfully!", "success");
        }
      } else {
        // Mobile: Print dialog
        await billHelper.printPdf(pdfBytes!);
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      if (mounted) {
        showBounceSnackBar(context, "'Error downloading PDF: $e'", "fail");
      }
    }
  }

  /// PDF generation (aligned to thermal printer paper size)
  Future<List<int>> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) => _receiptLayout(),
      ),
    );

    return pdf.save();
  }

  /// The receipt layout — replace the hard-coded strings with your data
  pw.Widget _receiptLayout() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ---------- Header ----------
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text('SHREE GURU SAGAR',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('#576, West Of Chord Road', style: _small),
              pw.Text('Near Water Tank, Basaveshwaranagar', style: _small),
              pw.Text('Bengaluru 560079', style: _small),
              pw.SizedBox(height: 5),
              pw.Text('TAX INVOICE',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Divider(thickness: 0.5),
            ],
          ),
        ),

        // ---------- Bill info ----------
        _infoRow('Date:', generate_bill_date, 'Bill No:', widget.bill_no),
        _infoRow(
            'T.No:', widget.table_option.split(' ')[1], 'W.Name:', mg_name),
        pw.SizedBox(height: 4),

        // ---------- Table Header ----------
        pw.Divider(thickness: 0.5),
        _tableHeader(),
        pw.Divider(thickness: 0.5),

        // ---------- Item list (example) ----------

        localSessionItems.isEmpty
            ? pw.Text('No items found', style: _small)
            : pw.Column(
                children: d!.map((key) {
                  var item = localSessionItems[key];
                  return _itemRow(
                      '${key}',
                      '${item['quantity']}',
                      '${item['price']}',
                      '${(double.parse(item['price']) * double.parse(item['quantity'])).toStringAsFixed(2)}');
                }).toList(),
              ),

        pw.SizedBox(height: 5),

        // ---------- Totals ----------
        _plain('Sub Total', subtotal),
        _plain('SGST @${gst}%', (double.parse(gst) / 2).toStringAsFixed(2)),
        _plain('CGST @${gst}%', (double.parse(gst) / 2).toStringAsFixed(2)),
        pw.SizedBox(height: 4),
        _plain('Food Total', final_amount),
        pw.Divider(thickness: 0.5),
        _plain('Total', final_amount,
            valueStyle:
                pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),

        // ---------- Footer ----------
        pw.Text(
            (!widget.isWebView)
                ? 'GST: ${gstin} --- (${double.parse(generate_bill_time.split(":")[0]) >= 12 ? "${generate_bill_time} pm" : "${widget.generate_bill_time} am"})'
                : 'GST: ${gstin} --- (${DateFormat('hh:mm a').format(DateTime.parse(generate_bill_time))})',
            style: _small),

        pw.Text('E.&O.E.  Thank You Visit Again', style: _small),
        pw.Text('PH - 8660743840', style: _small),
      ],
    );
  }

  // ---------- Helpers ----------

  pw.TextStyle get _small =>
      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.normal);

  pw.Widget _infoRow(String l1, String v1, String l2, String v2) {
    return pw.Row(
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.Row(
            children: [
              pw.Text(l1, style: _small),
              pw.SizedBox(width: 4),
              pw.Text(v1, style: _small),
            ],
          ),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(l2, style: _small),
              pw.SizedBox(width: 4),
              pw.Text(v2, style: _small),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _tableHeader() {
    return pw.Row(
      children: [
        pw.Expanded(
            flex: 5,
            child: pw.Text('Particulars',
                style:
                    pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
        pw.Expanded(
          flex: 5,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Qty',
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Text('Rate',
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Text('Amount',
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _itemRow(String name, String qty, String rate, String amount) {
    return pw.Row(
      children: [
        pw.Expanded(flex: 5, child: pw.Text(name, style: _small)),
        pw.Expanded(
          flex: 5,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(qty, style: _small),
              pw.Text(rate, style: _small),
              pw.Text(amount, style: _small),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _plain(String label, String value, {pw.TextStyle? valueStyle}) {
    valueStyle ??= _small;
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: _small),
        pw.Text(value, style: valueStyle),
      ],
    );
  }
}

/// Display widget to preview the PDF file
class PdfPreviewView extends StatelessWidget {
  final Uint8List pdfData;

  const PdfPreviewView({super.key, required this.pdfData});

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      build: (format) => Future.value(pdfData),
      canChangePageFormat: false,
      canChangeOrientation: false,
      allowSharing: false, // Handled manually
      allowPrinting: false, // Handled manually
      pageFormats: const {
        '80 mm Receipt': PdfPageFormat(226.4, double.infinity), // 80 mm wide
      },
    );
  }
}
