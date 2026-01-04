import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Manager/considated_bill.dart';
import 'package:orderease/Manager/mg_bill.dart';
import 'package:orderease/Manager/mg_category_dashboard.dart';
import 'package:orderease/Manager/mg_food_status.dart';
import 'package:orderease/Manager/mg_items_consolidated.dart';
import 'package:orderease/Settlements/cleared_settlements.dart';
import 'package:orderease/Settlements/pending_settlements.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettlementsView extends StatefulWidget {
  final String table_option;
  final String href;

  const SettlementsView({
    super.key,
    required this.table_option,
    required this.href,
  });
  @override
  SettlementsViewState createState() => SettlementsViewState();
}

class SettlementsViewState extends State<SettlementsView> {
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
    print("Tab ${widget.table_option}");
    pages_list = [PendingSettlements(href: widget.href, table_option:widget.table_option), Completed_Settlements_Dashboard(hotel_loc: widget.href, table_option:widget.table_option)];
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
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.hourglass_bottom),
              label: "Settle Order",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline_outlined),
              label: "Settled Orders",
            )
          ]),
    );
  }
}

// // Dummy Pages for Navigation
class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Text("Add Page",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black))));
  }
}
