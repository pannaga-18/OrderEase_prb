import 'package:flutter/material.dart';
import 'package:orderease/Cook/prepared_dashboard.dart';
import 'package:orderease/Cook/preparing_dashboard.dart';
import 'package:orderease/Manager/confirm_order_dashboard.dart';
import 'package:orderease/Manager/mg_bill.dart';
import 'package:orderease/Manager/mg_category_dashboard.dart';
import 'package:orderease/util_components/search_bar.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cook_Dashboard extends StatefulWidget {
  final String href;

  const Cook_Dashboard({
    super.key,
    required this.href,
  });

  @override
  Cook_DashboardState createState() => Cook_DashboardState();
}

class Cook_DashboardState extends State<Cook_Dashboard> {
  late PageController _pageController;
  int _selectedIndex = 0;
  late List<Widget> pages_list; // Ensure this is initialized before use

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);

    // Ensure pages_list is initialized before using PageView
    pages_list = [
      Cook_Preparing_Dashboard(hotel_loc: widget.href),
      Cook_Prepared_Dashboard(hotel_loc: widget.href),
    ];

    // Ensure UI updates safely after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;

      // If switching to Search Page, reset it
      if (index == 0) {
        _resetSearchPage();
      }
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void _resetSearchPage() {
    setState(() {
      pages_list[0] = Cook_Preparing_Dashboard(hotel_loc: widget.href);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (pages_list.isEmpty) {
      return CustomLoader(message: 'Loading...'); // Prevent null error
    }

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: pages_list,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: outer_background(),
        selectedItemColor: inner_background(),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        iconSize: 32,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: "Preparing",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Prepared",
          ),
        ],
      ),
    );
  }
}

class AddPage extends StatefulWidget {
  final String tab_option;
  final String href;
  const AddPage({super.key, required this.tab_option, required this.href});
  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ElevatedButton(onPressed: () {}, child: Text("Add Page")),
    ));
  }
}
