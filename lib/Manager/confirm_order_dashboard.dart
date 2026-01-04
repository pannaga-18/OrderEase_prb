import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Manager/considated_bill.dart';
import 'package:orderease/Manager/mg_bill.dart';
import 'package:orderease/Manager/mg_category_dashboard.dart';
import 'package:orderease/Manager/mg_food_status.dart';
import 'package:orderease/Manager/mg_items_consolidated.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Manager_Order_Dashboard extends StatefulWidget {
  final String table_option;
  final String href;
  final String screen_label;
  final String buttonStatus;

  const Manager_Order_Dashboard(
      {super.key,
      required this.table_option,
      required this.href,
      required this.screen_label,
      required this.buttonStatus});
  @override
  Manager_Order_DashboardState createState() => Manager_Order_DashboardState();
}

class Manager_Order_DashboardState extends State<Manager_Order_Dashboard> {
  PageController _pageController = PageController();
  // late int _selectedIndex;
  int _selectedIndex = 0;
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  List<Widget> pages_list = [];

  @override
  void initState() {
    super.initState();

    if (widget.buttonStatus == "prepare") {
      pages_list = [
        Manager_Menu_Items1(
          hotel_loc: widget.href,
          table_option: widget.table_option,
          screen_label: widget.screen_label,
        ),
        Manager_Bill_Dashboard(
          hotel_loc: widget.href,
          table_option: widget.table_option,
          screen_label: "",
        ),
      ];
    } else if (widget.buttonStatus == "view_order_status") {
      pages_list = [
        Manager_Status_Dashboard(
          hotel_loc: widget.href,
          table_option: widget.table_option,
          screen_label: widget.screen_label,
        ),
        Manager_Bill_Dashboard(
          hotel_loc: widget.href,
          table_option: widget.table_option,
          screen_label: "",
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: pages_list),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: outer_background(), // Background color
        selectedItemColor: inner_background(), // Active icon color
        unselectedItemColor: Colors.grey, // Inactive icon color
        currentIndex: _selectedIndex,
        iconSize: 32,
        onTap: _onItemTapped,
        items: (widget.buttonStatus == "view_order_status")
            ? [
                BottomNavigationBarItem(
                  icon: Icon(Icons.update),
                  label: "Order Status",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: "Bill",
                )
              ]
            : [
                BottomNavigationBarItem(
                  icon: Icon(Icons.view_list_sharp),
                  label: "Confirm",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: "Bill",
                ),
              ],
      ),
    );
  }
}

// // Dummy Pages for Navigation
class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Row(
      children: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Want to Add more?")),
        ElevatedButton(onPressed: () {}, child: Text("Place Order.."))
      ],
    )));
  }
}
