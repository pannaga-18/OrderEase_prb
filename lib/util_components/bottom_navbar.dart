import 'package:flutter/material.dart';
import 'package:orderease/Admin/menu/add_category.dart';
import 'package:orderease/Admin/menu/menu.dart';
import 'package:orderease/Admin/menu/menu_dashboard.dart';
import 'package:orderease/Manager/mg_bill.dart';
import 'package:orderease/Manager/mg_category_dashboard.dart';
import 'package:orderease/Manager/mg_food_status.dart';
import 'package:orderease/Manager/mg_menu_items.dart';
import 'package:orderease/util_components/search_bar.dart';
import 'package:orderease/util_components/util.dart';

class SwipableNavBar extends StatefulWidget {
  final String role;
  final String page1;
  final String page2;
  final String label;
  final String href;
  final String table_option;
  const SwipableNavBar(
      {super.key,
      required this.role,
      required this.page1,
      required this.page2,
      required this.label,
      required this.href,
      required this.table_option});
  @override
  _SwipableNavBarState createState() => _SwipableNavBarState();
}

class _SwipableNavBarState extends State<SwipableNavBar> {
  late PageController _pageController;
  late int _selectedIndex;

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
  List<BottomNavigationBarItem> icons_list = [];
  @override
  void initState() {
    super.initState();

    // for menu dashboard page
    if (widget.role == "Admin" &&
        widget.page1 == "category_add" &&
        widget.page2 == "search") {
      pages_list = [
        NewCategoryPage(
            label: "Menu",
            hotel_loc: widget.href,
            page_label: "menu_dashboard"),
        Menu_Dashboard(label: widget.label, href: widget.href),
        AnimatedSearchBar(
          table_option: "Search",
          role: "Admin",
          hotelref: widget.href,
        ),
      ];

      icons_list = [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add,
          ),
          label: "Add",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Menu",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "Search",
        ),
      ];

      _pageController = PageController(initialPage: 1);
      _selectedIndex = 1;
    }

    // for menu items page
    else if (widget.role == "Admin" &&
        widget.page1 == "add_menu_items" &&
        widget.page2 == "search") {
      pages_list = [
        NewCategoryPage(
            label: widget.label,
            hotel_loc: widget.href,
            page_label: "menu_items"),
        Menu(
          hotel_loc: widget.href,
          menu_label: widget.label,
        ),
        AnimatedSearchBar(
          table_option: "Search",
          role: "Admin",
          hotelref: widget.href,
        ),
      ];

      icons_list = [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add,
          ),
          label: "Add",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Menu",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "Search",
        ),
      ];
      _pageController = PageController(initialPage: 1);
      _selectedIndex = 1;
    }

    // manager
    else if (widget.role == "Manager" &&
        widget.page1 == "Order" &&
        widget.page2 == "MG_Menu_Items") {
      print("MAN");
      print(widget.label);
      pages_list = [
        Manager_Menu_Items(
          hotel_loc: widget.href,
          menu_label: widget.label,
          table_option: widget.table_option,
        ),
        Manager_Status_Dashboard(
          hotel_loc: widget.href,
          table_option: widget.table_option,
          screen_label: "mg_menu",
        ),
        Manager_Bill_Dashboard(
          hotel_loc: widget.href,
          table_option: widget.table_option,
          screen_label: "",
        ),
      ];
      icons_list = [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.view_list_sharp,
          ),
          label: "Food Items",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.update),
          label: "Order Status",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: "Bill",
        ),
      ];
      _pageController = PageController(initialPage: 0);
      _selectedIndex = 0;
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
        items: icons_list,
      ),
    );
  }
}

// Dummy Pages for Navigation
class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Add Page")),
    );
  }
}
