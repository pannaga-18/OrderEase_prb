import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Settlements/Bill_Print/print_bill.dart';
import 'package:orderease/util_components/QR_Code/invaild_qr.dart';
import 'package:orderease/util_components/util.dart';

class BillPreviewLoaderScreen extends StatelessWidget {
  final String hotelId;
  final String billNo;
  final String session_table_id;
  const BillPreviewLoaderScreen(
      {Key? key,
      required this.hotelId,
      required this.billNo,
      required this.session_table_id})
      : super(key: key);

  Future<Map<String, dynamic>> fetch_bill_data(
      String bill_no, String hotel_id) async {
    Map<String, dynamic> bill_data = {};
    Map<String, dynamic> hotel_data = {};
    Map<String, dynamic> menu_items_data = {};

    if (session_table_id == "" && bill_no != "0") {
      print("ADMIN, CASHIER");
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(hotel_id)
          .collection("Settlements")
          .where("bill_no", isEqualTo: bill_no)
          .limit(1)
          .get();

      // bill details
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = snapshot.docs.first;
        // print(documentSnapshot.data());
        bill_data = documentSnapshot.data() as Map<String, dynamic>;
        menu_items_data = Map.from(bill_data);
      }
    } else {
      print("MANAGER");
      DocumentSnapshot documentSnapshot1 = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(hotel_id)
          .collection("Settlements")
          .doc(session_table_id)
          .get();

      bill_data = documentSnapshot1.data() as Map<String, dynamic>;
      menu_items_data = Map.from(bill_data);
    }

    // gst details;
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(hotel_id)
        .get();
    hotel_data = documentSnapshot.data() as Map<String, dynamic>;
    String gst = hotel_data['gst_rate'];
    String gst_in = hotel_data['gst_no'];

    bill_data['gst'] = gst;
    bill_data['gst_in'] = gst_in;

    final allowedKeys = {
      "actual_price",
      "bill_no",
      "discount_amount",
      "email",
      "generate_bill_time",
      "mg_name",
      "mode_of_payment",
      "paid_status",
      "remark",
      "session_start_time",
      "settled_time",
      "status",
      "table_option",
      "gst",
      "gst_in"
    };

    menu_items_data.removeWhere((key, value) => allowedKeys.contains(key));

    bill_data.removeWhere((key, value) => !allowedKeys.contains(key));

    bill_data['menu_items'] = menu_items_data;

    return bill_data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetch_bill_data(billNo, hotelId),
      builder: (context, snapshot) {
        // ⏳ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomLoader(message: "Loading bill...");
        }

        // ❌ Error
        if (snapshot.hasError) {
          return InvalidQRScreen();
        }

        // ❌ No bill found
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return InvalidQRScreen();
        }

        // ✅ Success
        final billData = snapshot.data!;
        print("bill_data = $billData");

        return BillPreviewPage(
          table_uid: "",
          href: hotelId,
          table_option: billData['table_option'],
          generate_bill_time: billData['generate_bill_time'],
          generate_bill_date: billData['session_start_time'],
          subtotal: billData['actual_price'],
          gst: billData['gst'],
          gstin: billData['gst_in'],
          email: billData['email'],
          mg_name: billData['mg_name'],
          final_amount: billData['discount_amount'],
          localSessionItems: billData['menu_items'],
          isWebView: true,
          bill_no: billData['bill_no'],
        );
        // return InvalidQRScreen();
      },
    );
  }
}
