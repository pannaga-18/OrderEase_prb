import 'package:flutter/material.dart';
import 'package:orderease/Manager/confirm_order_dashboard.dart';
import 'package:orderease/Manager/mg_bill.dart';
import 'package:orderease/Manager/mg_category_dashboard.dart';
import 'package:orderease/util_components/search_bar.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Manager_Prepareorder_Dashboard extends StatefulWidget {
  final String table_option;
  final String href;

  const Manager_Prepareorder_Dashboard({
    super.key,
    required this.table_option,
    required this.href,
  });

  @override
  Manager_Prepareorder_DashboardState createState() =>
      Manager_Prepareorder_DashboardState();
}

class Manager_Prepareorder_DashboardState
    extends State<Manager_Prepareorder_Dashboard> {
  late PageController _pageController;
  int _selectedIndex = 0;
  late List<Widget> pages_list; // Ensure this is initialized before use

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);

    // Ensure pages_list is initialized before using PageView
    pages_list = [
      AnimatedSearchBar(
        key: ValueKey("SearchPage"),
        table_option: widget.table_option,
        role: "Manager",
        hotelref: widget.href,
      ),
      Manager_Menu_Dashboard(
        key: ValueKey("MenuPage"),
        label: "Menu",
        href: widget.href,
        table_option: widget.table_option,
      ),

      Manager_Bill_Dashboard(
        hotel_loc: widget.href,
        table_option: widget.table_option,
        screen_label: "",
      ),

      // AddPage(
      //   key: ValueKey("BillPage"),
      //   tab_option: widget.table_option,
      //   href: widget.href,
      // ),
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
      pages_list[0] = AnimatedSearchBar(
        key: ValueKey("SearchPage_${DateTime.now().millisecondsSinceEpoch}"),
        table_option: widget.table_option,
        role: "Manager",
        hotelref: widget.href,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenHeight < screenWidth;
    final padding = isTablet ? 28.0 : 16.0;
    if (pages_list.isEmpty) {
      return CustomLoader(message: 'Loading...'); // Prevent null error
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: pages_list,
          ),
          if (_selectedIndex == 0)
            Positioned(
                bottom: isTablet ? 6 : 30, // Position it above the navbar
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Expanded(
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       padding: EdgeInsets.symmetric(vertical: 16),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(20),
                    //       ),
                    //       backgroundColor: outer_background(),
                    //       foregroundColor: inner_background(),
                    //     ),
                    //     onPressed: () async {
                    //       SharedPreferences prefs =
                    //           await SharedPreferences.getInstance();

                    //       bool? storedStatus =
                    //           prefs.getBool("isBlocked_${widget.table_option}");
                    //       print(storedStatus);

                    //       // Block or not
                    //       if (storedStatus == null) {
                    //         showBounceSnackBar(
                    //             context, "Block the session!!", "warning");
                    //       } else if (storedStatus == true) {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => Manager_Order_Dashboard(
                    //               table_option: widget.table_option,
                    //               href: widget.href,
                    //               screen_label: "mg_search_bar",
                    //               buttonStatus: "prepare",
                    //             ),
                    //           ),
                    //         );
                    //       }
                    //     },
                    //     child: Text(
                    //       "Prepare",
                    //       style: TextStyle(
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.w600,
                    //         letterSpacing: 0.5,
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          bool? storedStatus =
                              prefs.getBool("isBlocked_${widget.table_option}");
                          print(storedStatus);

                          // Block or not
                          if (storedStatus == null) {
                            showBounceSnackBar(
                                context, "Block the session!!", "warning");
                          } else if (storedStatus == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Manager_Order_Dashboard(
                                  table_option: widget.table_option,
                                  href: widget.href,
                                  screen_label: "mg_search_bar",
                                  buttonStatus: "prepare",
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: outer_background(),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: outer_background().withOpacity(0.3),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: inner_background(),
                                child: Icon(
                                  Icons.task_alt,
                                  size: 18,
                                  color: outer_background(),
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  "Prepare",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: inner_background(),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    //
                    SizedBox(
                      width: 15,
                    ),

                    //
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          bool? storedStatus =
                              prefs.getBool("isBlocked_${widget.table_option}");
                          print(storedStatus);

                          if (storedStatus == null) {
                            showBounceSnackBar(
                                context, "Block the session!!", "warning");
                          } else if (storedStatus == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Manager_Order_Dashboard(
                                  table_option: widget.table_option,
                                  href: widget.href,
                                  screen_label: "mg_search_bar",
                                  buttonStatus: "view_order_status",
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: outer_background(),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: outer_background().withOpacity(0.3),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: inner_background(),
                                child: Icon(
                                  Icons.soup_kitchen,
                                  size: 18,
                                  color: outer_background(),
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  "Progress",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: inner_background(),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )),
          // if (_selectedIndex == 0)
          //   Positioned(
          //     bottom: 20, // Position it above the navbar
          //     left: 20,
          //     right: 20,
          //     child:
          //   ),
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
            icon: Icon(Icons.table_bar_sharp),
            label: "Order",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Menu",
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
