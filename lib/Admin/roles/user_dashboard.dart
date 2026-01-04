import 'package:flutter/material.dart';
import 'package:orderease/Admin/menu/add_category.dart';
import 'package:orderease/Admin/menu/menu.dart';
import 'package:orderease/Admin/menu/menu_dashboard.dart';
import 'package:orderease/Admin/roles/add_user.dart';
import 'package:orderease/Admin/roles/fetch_users.dart';
import 'package:orderease/util_components/search_bar.dart';
import 'package:orderease/util_components/util.dart';

class SwipableRoleNavBar1 extends StatefulWidget {
  final String user_option;

  final String href;
  const SwipableRoleNavBar1(
      {super.key, required this.user_option, required this.href});
  @override
  _SwipableNavBarState createState() => _SwipableNavBarState();
}

class _SwipableNavBarState extends State<SwipableRoleNavBar1> {
  PageController _pageController = PageController();
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

  @override
  void initState() {
    super.initState();

    // MANAGER
    if (widget.user_option == "Manager" || widget.user_option == "Cashier") {
      pages_list = [
        Fetch_Users_Page(
          user_role: "Manager",
          href: widget.href,
        ),
        AddUserPage(
          href: widget.href,
        ),
        Fetch_Users_Page(
          user_role: "Cook",
          href: widget.href,
        ),
      ];
      _pageController = PageController(initialPage: 0);
      _selectedIndex = 0;
    }

    // COOK
    if (widget.user_option == "Cook") {
      pages_list = [
        Fetch_Users_Page(
          user_role: "Manager",
          href: widget.href,
        ),
        AddUserPage(
          href: widget.href,
        ),
        // AddUserPage(),
        // AddUserPage(),
        Fetch_Users_Page(
          user_role: "Cook",
          href: widget.href,
        ),
      ];
      _pageController = PageController(initialPage: 2);
      _selectedIndex = 2;
    }

    // ADD
    if (widget.user_option == "ADD") {
      pages_list = [
        Fetch_Users_Page(
          user_role: "Manager",
          href: widget.href,
        ),
        AddUserPage(
          href: widget.href,
        ),
        // AddUserPage(),
        // AddUserPage(),
        Fetch_Users_Page(
          user_role: "Cook",
          href: widget.href,
        ),
      ];
      _pageController = PageController(initialPage: 1);
      _selectedIndex = 1;
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.supervisor_account),
            label: "Manager",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
            ),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Cook",
          ),
        ],
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
