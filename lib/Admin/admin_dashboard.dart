// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:orderease/Admin/menu/menu_dashboard.dart';
// import 'package:orderease/Admin/roles/user_dashboard.dart';
// import 'package:orderease/Authentication/auth.dart';
// import 'package:orderease/LandingScreen/home_screen.dart';
// import 'package:orderease/Settlements/analytics_dashboard.dart';
// import 'package:orderease/Settlements/settlements_table_dashboard.dart';
// import 'package:orderease/Authentication/hotels_collection.dart';
// import 'package:orderease/main.dart';
// import 'package:orderease/Admin/roles/add_user.dart';
// import 'package:orderease/util_components/bottom_navbar.dart';
// import 'package:orderease/util_components/util.dart';
// import 'package:orderease/Admin/menu/menu_dashboard.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(AdminDashboard());
// }

// Map<String, dynamic>? UserData;
// var hotelref;
// var h_id, h_n, h_a, h_p;
// String default_option = "Manager";

// List<String> roles_options = ['Manager', 'Cook', "Cashier"];

// // String? hotel_name, hotel_logo_url;
// TextEditingController? _gstratecontroller;

// void send_data_from_login(Object data) {
//   if (data is Map<String, dynamic>) UserData = data;
//   h_id = UserData!['hotel_id'];
//   h_n = UserData!['hotel_name'].toString().toLowerCase();
//   h_a = UserData!['hotel_area'].toString().toLowerCase();
//   h_p = UserData!['pincode'].toString().toLowerCase();
//   hotelref = "${h_id}_${h_n}_${h_a}_${h_p}";
// }

// class AdminDashboard extends StatefulWidget {
//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<AdminDashboard> {
//   late String adminName;
//   late String adminEmail;
//   late String adminRole;
//   late int hotel_id;
//   bool _isDialogOpen = false; // Track whether the dialog is open

//   @override
//   void initState() {
//     super.initState();
//     // Initialize data safely in initState
//     if (UserData != null) {
//       adminName = UserData!['admin_name'] ?? 'Admin';
//       adminEmail = UserData!['admin_email'] ?? 'N/A';
//       adminRole = UserData!['role'] ?? 'Admin';
//       hotel_id = UserData!['hotel_id'] ?? 0;

//       // Initialize hotelref properly
//       if (hotelref == null || hotelref.isEmpty) {
//         final h_id = UserData!['hotel_id'];
//         final h_n = UserData!['hotel_name']?.toString().toLowerCase() ?? 'hotel';
//         final h_a = UserData!['hotel_area']?.toString().toLowerCase() ?? 'area';
//         final h_p = UserData!['pincode']?.toString().toLowerCase() ?? 'pincode';
//         hotelref = "${h_id}_${h_n}_${h_a}_${h_p}";
//       }
//     }
//   }

//   void _toggleAdminInfoDialog(BuildContext context) {
//     if (_isDialogOpen) {
//       // Close the dialog if it's already open
//       Navigator.of(context).pop();
//       setState(() {
//         _isDialogOpen = false;
//       });
//     } else {
//       // Open the dialog
//       _showAdminInfoDialog(context);
//       setState(() {
//         _isDialogOpen = true;
//       });
//     }
//   }

//   void _showInputDialog(
//       BuildContext context, String msg, String place_holder, String feature) {
//     final _formKey = GlobalKey<FormState>(); // Form key to validate the form
//     String _inputValue = ''; // Variable to store the input value

//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(
//               msg,
//               style: TextStyle(
//                 fontSize: 16,
//               ),
//               overflow: TextOverflow.clip,
//               softWrap: true,
//             ),
//             content: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     keyboardType: TextInputType.numberWithOptions(),
//                     controller: _gstratecontroller,
//                     decoration: InputDecoration(
//                       enabledBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(
//                             color: Colors.grey), // Color when not focused
//                       ),
//                       focusedBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(
//                             color: outer_background()), // Color when focused
//                       ),
//                       labelText: place_holder,
//                     ),
//                     validator: (value) {
//                       if ((value == null || value.isEmpty)) {
//                         return 'Field should not be empty';
//                       }
//                       return null;
//                     },
//                     onChanged: (value) {
//                       _inputValue = value;
//                     },
//                   )
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Close the dialog
//                 },

//                 // Adding style to button
//                 style: TextButton.styleFrom(
//                   backgroundColor: inner_background(),
//                   foregroundColor: outer_background(),
//                 ),
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(color: outer_background()),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     // If form is valid, proceed
//                     print('Input value: $_inputValue');
//                     print(hotelref);
//                     if (feature == "GST Rate") {
//                       // var rate = int.parse(_inputValue);
//                       await FirebaseFirestore.instance
//                           .collection("Hotels")
//                           .doc(hotelref)
//                           .update({"gst_rate": _inputValue});
//                     }

//                     if (feature == "Tables") {
//                       // var table = int.parse(_inputValue);

//                       List<String> table_name = [
//                         "",
//                         "A",
//                         "B",
//                         "C",
//                         "D",
//                         "E",
//                         "F"
//                       ];
//                       Map<String, dynamic> table_map = {};
//                       for (var i = 1; i <= int.parse(_inputValue); i++) {
//                         for (var tab in table_name) {
//                           table_map["Table ${i}${tab}"] = [false, ""];
//                         }
//                       }

//                       Map<String, dynamic> to_store_table_map = {
//                         "no_of_tables": _inputValue,
//                         "table_status": table_map
//                       };

//                       print("Tablemap");
//                       print(to_store_table_map);

//                       await FirebaseFirestore.instance
//                           .collection("Hotels")
//                           .doc(hotelref)
//                           .update(to_store_table_map);
//                     }

//                     Navigator.of(context).pop(); // Close the dialog
//                     showStatusSnackBar(
//                         context, "$feature updated Successfully", "success");
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: outer_background(),
//                   foregroundColor: inner_background(),
//                 ),
//                 child: Text('Submit'),
//               ),
//             ],
//           );
//         });
//   }

//   void _showAdminInfoDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: true, // Allow tapping outside to dismiss
//       builder: (context) {
//         return AdminInfoDialog(
//             adminName: adminName,
//             adminEmail: adminEmail,
//             adminRole: adminRole,
//             hotelID: hotel_id);
//       },
//     ).then((_) {
//       // Reset dialog state when the dialog is closed
//       setState(() {
//         _isDialogOpen = false;
//       });
//     });
//   }

//   void _showPopupMenu(BuildContext context, Offset position) async {
//     final RenderBox overlay =
//         Overlay.of(context).context.findRenderObject() as RenderBox;

//     final selectedValue = await showMenu<String>(
//       context: context,
//       position: RelativeRect.fromRect(
//         Rect.fromLTWH(position.dx, position.dy, 0,
//             0), // Popup will appear near the tap point
//         Offset.zero & overlay.size, // Boundaries for the popup
//       ),
//       items: roles_options.map((String option) {
//         return PopupMenuItem<String>(
//           value: option,
//           child: Text(option),
//         );
//       }).toList(),
//       elevation: 8.0,
//     );

//     if (selectedValue != null) {
//       setState(() {
//         default_option = selectedValue;
//         print(default_option);
//       });

//       Future.delayed(Duration(milliseconds: 100), () {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => SwipableRoleNavBar1(
//                       user_option: selectedValue,
//                       href: hotelref,
//                     )));
//       });
//     }
//   }

//   Widget _buildRoles(BuildContext context) {
//     return Center(
//       child: DropdownButton<String>(
//         value: default_option,
//         icon: Icon(Icons.arrow_downward),
//         iconSize: 20,
//         elevation: 16,
//         style: TextStyle(color: Color(0xFF397ABC)),
//         underline: Container(
//           height: 2,
//           color: Colors.blueAccent,
//         ),
//         onChanged: (String? newValue) {
//           setState(() {
//             default_option = newValue!;
//           });
//         },
//         items: roles_options.map<DropdownMenuItem<String>>((String value) {
//           return DropdownMenuItem<String>(value: value, child: Text(value));
//         }).toList(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Check if UserData is available
//     if (UserData == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Dashboard')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       backgroundColor:
//           inner_background(), // Background color similar to your design
//       appBar: AppBar(
//         title: Text(
//           'Dashboard',
//           style: TextStyle(color: inner_background()),
//         ),
//         backgroundColor: outer_background(), // Same color as the buttons
//         centerTitle: true,
//         // removes back arrow from app bar
//         automaticallyImplyLeading: false,

//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: () {
//               // Action for the profile icon
//               _toggleAdminInfoDialog(context);
//             },
//             icon: Icon(
//               Icons.account_circle,
//               size: 30,
//               color: inner_background(),
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Hotel Logo
//             Center(
//               child: Container(
//                 width: 130,
//                 height: 130,
//                 child: ClipOval(
//                   child: _buildHotelLogo(),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),

//             // Hotel Name
//             Text(
//               UserData!['hotel_name'] ?? 'Hotel',
//               style: TextStyle(
//                 fontSize: MediaQuery.of(context).size.width * 0.05,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             SizedBox(height: 32),

//             // Button Grid
//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 children: [
//                   _buildDashboardButton('Menu', Icons.restaurant_menu),
//                   _buildDashboardButton('Settlements', Icons.receipt_long),
//                   _buildDashboardButton('Roles', Icons.person),
//                   _buildDashboardButton('Tables', Icons.table_chart),
//                   _buildDashboardButton('GST Rate', Icons.currency_rupee_sharp),
//                   _buildDashboardButton('Analytics', Icons.analytics),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper function to build hotel logo with timeout
//   Widget _buildHotelLogo() {
//     final logoUrl = UserData!['hotel_logo_url'];

//     if (logoUrl == null || logoUrl.isEmpty) {
//       return Container(
//         color: outer_background(),
//         child: Icon(Icons.hotel, size: 60, color: Colors.white),
//       );
//     }

//     return Image.network(
//       logoUrl,
//       fit: BoxFit.cover,
//       loadingBuilder: (context, child, loadingProgress) {
//         if (loadingProgress == null) return child;
//         return Center(
//           child: CircularProgressIndicator(
//             color: outer_background(),
//             value: loadingProgress.expectedTotalBytes != null
//                 ? loadingProgress.cumulativeBytesLoaded /
//                     loadingProgress.expectedTotalBytes!
//                 : null,
//           ),
//         );
//       },
//       errorBuilder: (context, error, stackTrace) {
//         return Container(
//           color: outer_background().withOpacity(0.1),
//           child: Icon(Icons.hotel, size: 60, color: outer_background()),
//         );
//       },
//     );
//   }

//   // Helper function to build dashboard buttons
//   Widget _buildDashboardButton(String label, IconData icon) {
//     return GestureDetector(
//       onTapDown: (TapDownDetails details) async {
//         // Check if hotelref is valid before proceeding
//         if (hotelref == null || hotelref.isEmpty) {
//           showStatusSnackBar(
//               context, 'Hotel reference is invalid. Please try again.', 'error');
//           return;
//         }

//         try {
//           // Fetch hotel data with timeout to prevent hanging
//           final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
//               .collection("Hotels")
//               .doc(hotelref)
//               .get()
//               .timeout(
//                 const Duration(seconds: 5),
//                 onTimeout: () {
//                   throw TimeoutException('Failed to fetch hotel data');
//                 },
//               );

//           if (documentSnapshot.exists) {
//             var data = documentSnapshot.data() as Map<String, dynamic>?;
//             if (data != null && data.isNotEmpty) {
//               if (mounted) {
//                 setState(() {
//                   UserData!['no_of_tables'] = data['no_of_tables'];
//                   UserData!['gst_rate'] = data['gst_rate'];
//                 });
//               }
//             }
//           }
//         } catch (e) {
//           print('Error fetching hotel data: $e');
//           if (mounted) {
//           showStatusSnackBar(
//                 context, 'Error fetching hotel data. Please try again.', 'error');
//           }
//           return;
//         }

//         // Handle button press
//         print(label);

//         if (label == "Tables") {
//           if (UserData!.containsKey('no_of_tables')) {
//             _gstratecontroller =
//                 TextEditingController(text: "${UserData!['no_of_tables']}");
//           } else {
//             _gstratecontroller = TextEditingController(text: "");
//           }
//           _showInputDialog(
//               context,
//               "How many number of tables do you want to have?",
//               "Number of tables",
//               label);
//         }

//         //  For GST
//         if (label == "GST Rate") {
//           if (UserData!.containsKey('gst_rate')) {
//             _gstratecontroller =
//                 TextEditingController(text: "${UserData!['gst_rate']}");
//           } else {
//             _gstratecontroller = TextEditingController(text: "");
//           }
//           _showInputDialog(context, "Edit Gst Rate.", "Gst Rate", label);
//         }

//         // For Roles
//         if (label == 'Roles') {
//           print("coming inside");
//           _showPopupMenu(context, details.globalPosition);
//         }

//         if (label == 'Menu') {
//           // get_data(label, hotelref);
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => SwipableNavBar(
//                   role: "Admin",
//                   page1: "category_add",
//                   page2: "search",
//                   label: label,
//                   href: hotelref,
//                   table_option: "",
//                 ),
//               ));
//         }

//         if (label == "Analytics") {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AnalyticsDashboard(hotel_loc: hotelref),
//             ),
//           );
//         }

//         if (label == "Settlements") {
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => SettlementsPage(
//                         href: hotelref,
//                         role: "Admin",
//                       )));
//         }
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: outer_background(),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color: Colors.white,
//               size: 40,
//             ),
//             SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// //  Function to logout
// void logout(BuildContext context) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.remove('email');
//   await prefs.remove('hotel_id');

//   // Perform Firebase sign out or any logout operation here
//   FirebaseAuth.instance.signOut().then((_) {
//     // After sign out, navigate to the login screen
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(
//           builder: (context) => OrderEaseApp() // Go to the login tab
//           ),
//       (Route<dynamic> route) => false, // Remove all previous routes
//     );
//   }).catchError((error) {
//     // Handle error if something goes wrong during logout
//     print("Error logging out: $error");
//   });
// }

// class AdminInfoDialog extends StatelessWidget {
//   final String adminName;
//   final String adminEmail;
//   final String adminRole;
//   final int hotelID;

//   AdminInfoDialog({
//     required this.adminName,
//     required this.adminEmail,
//     required this.adminRole,
//     required this.hotelID,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       contentPadding: EdgeInsets.zero,
//       content: Container(
//         padding: EdgeInsets.all(16.0),
//         width: MediaQuery.of(context).size.width * 0.3,
//         // constraints: BoxConstraints(
//         //   maxWidth: 400, // Max width for larger screens
//         //   minWidth: 200, // Min width for smaller screens
//         //   maxHeight: MediaQuery.of(context).size.height * 0.5, // Max height
//         // ),// Small window
//         height: MediaQuery.of(context).size.height * 0.3,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Admin Name: $adminName',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Text('Email: $adminEmail'),
//             SizedBox(height: 10),
//             Text('Role: $adminRole'),
//             SizedBox(height: 10),
//             Text('Hotel ID: $hotelID'),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 logout(context);
//               },
//               child: Text("Logout"),
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: outer_background(),
//                   foregroundColor: inner_background()),
//             )
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop(); // Close the alert
//           },
//           child: Text('Close'),
//         ),
//       ],
//     );
//   }
// }
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orderease/Admin/menu/menu_dashboard.dart';
import 'package:orderease/Admin/roles/user_dashboard.dart';
import 'package:orderease/Authentication/auth.dart';
import 'package:orderease/LandingScreen/home_screen.dart';
import 'package:orderease/Settlements/analytics_dashboard.dart';
import 'package:orderease/Settlements/settlements_table_dashboard.dart';
import 'package:orderease/Authentication/hotels_collection.dart';
import 'package:orderease/main.dart';
import 'package:orderease/Admin/roles/add_user.dart';
import 'package:orderease/util_components/bottom_navbar.dart';
import 'package:orderease/util_components/profile.dart';
import 'package:orderease/util_components/util.dart';
import 'package:orderease/Admin/menu/menu_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orderease/Admin/Logs/log.dart';

void main() {
  runApp(AdminDashboard());
}

Map<String, dynamic>? UserData;
var hotelref;
var h_id, h_n, h_a, h_p;
String default_option = "Manager";

List<String> roles_options = ['Manager', 'Cook', "Cashier"];

TextEditingController? _gstratecontroller;

void send_data_from_login(Object data) {
  if (data is Map<String, dynamic>) UserData = data;
  h_id = UserData!['hotel_id'];
  h_n = UserData!['hotel_name'].toString().toLowerCase();
  h_a = UserData!['hotel_area'].toString().toLowerCase();
  h_p = UserData!['pincode'].toString().toLowerCase();
  hotelref = "${h_id}_${h_n}_${h_a}_${h_p}";
}

class AdminDashboard extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<AdminDashboard> {
  late String adminName;
  late String adminEmail;
  late String adminRole;
  late int hotel_id;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    if (UserData != null) {
      adminName = UserData!['admin_name'] ?? 'Admin';
      adminEmail = UserData!['admin_email'] ?? 'N/A';
      adminRole = UserData!['role'] ?? 'Admin';
      hotel_id = UserData!['hotel_id'] ?? 0;

      if (hotelref == null || hotelref.isEmpty) {
        final h_id = UserData!['hotel_id'];
        final h_n =
            UserData!['hotel_name']?.toString().toLowerCase() ?? 'hotel';
        final h_a = UserData!['hotel_area']?.toString().toLowerCase() ?? 'area';
        final h_p = UserData!['pincode']?.toString().toLowerCase() ?? 'pincode';
        hotelref = "${h_id}_${h_n}_${h_a}_${h_p}";
      }
    }
  }

  void _toggleAdminInfoDialog(BuildContext context) {
    if (_isDialogOpen) {
      Navigator.of(context).pop();
      setState(() {
        _isDialogOpen = false;
      });
    } else {
      _showAdminInfoDialog(context);
      setState(() {
        _isDialogOpen = true;
      });
    }
  }

  void _showInputDialog(BuildContext parentContext, String msg,
      String place_holder, String feature) {
    final _formKey = GlobalKey<FormState>();
    String _inputValue = '';

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              msg,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.numberWithOptions(),
                    controller: _gstratecontroller,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: outer_background(), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red.shade300),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      labelText: place_holder,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if ((value == null || value.isEmpty)) {
                        return 'Field should not be empty';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _inputValue = value;
                    },
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String email = FirebaseAuth.instance.currentUser!.email!;
                    await addLogEntry(
                      hotelId: hotelref,
                      userEmail: email,
                      action: "Edited $feature to $_inputValue.",
                      tableNumber: "", // stored as null in Firestore
                      sessionId: "",
                    );
                    print('Input value: $_inputValue');
                    print(hotelref);
                    if (feature == "GST Rate") {
                      await FirebaseFirestore.instance
                          .collection("Hotels")
                          .doc(hotelref)
                          .update({"gst_rate": _inputValue});
                    }

                    if (feature == "Tables") {
                      List<String> table_name = [
                        "",
                        "A",
                        "B",
                        "C",
                        "D",
                        "E",
                        "F"
                      ];
                      Map<String, dynamic> table_map = {};
                      for (var i = 1; i <= int.parse(_inputValue); i++) {
                        for (var tab in table_name) {
                          table_map["Table ${i}${tab}"] = [false, ""];
                        }
                      }

                      Map<String, dynamic> to_store_table_map = {
                        "no_of_tables": _inputValue,
                        "table_status": table_map
                      };

                      print("Tablemap");
                      print(to_store_table_map);

                      await FirebaseFirestore.instance
                          .collection("Hotels")
                          .doc(hotelref)
                          .update(to_store_table_map);
                    }
                    Navigator.of(context).pop();
                    showSlideFromLeftSnackBar(parentContext,
                        "$feature updated successfully!", "success");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: outer_background(),
                  foregroundColor: inner_background(),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ],
          );
        });
  }

  void _showAdminInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AdminInfoDialog(
            adminName: adminName,
            adminEmail: adminEmail,
            adminRole: adminRole,
            hotelID: hotel_id);
      },
    ).then((_) {
      setState(() {
        _isDialogOpen = false;
      });
    });
  }

  void _showPopupMenu(BuildContext context, Offset position) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final selectedValue = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: roles_options.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(option, style: TextStyle(fontSize: 16)),
          ),
        );
      }).toList(),
      elevation: 8.0,
    );

    if (selectedValue != null) {
      setState(() {
        default_option = selectedValue;
        print(default_option);
      });

      Future.delayed(Duration(milliseconds: 100), () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SwipableRoleNavBar1(
                      user_option: selectedValue,
                      href: hotelref,
                    )));
      });
    }
  }

  Widget _buildRoles(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        value: default_option,
        icon: Icon(Icons.arrow_downward),
        iconSize: 20,
        elevation: 16,
        style: TextStyle(color: Color(0xFF397ABC)),
        underline: Container(
          height: 2,
          color: Colors.blueAccent,
        ),
        onChanged: (String? newValue) {
          setState(() {
            default_option = newValue!;
          });
        },
        items: roles_options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (UserData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: CustomLoader(message: 'Loading Dashboard...'),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;

    return PopScope(
        canPop: false, // prevents default pop
        onPopInvokedWithResult: (didPop, result) async {
          // If user tries to exit (back button)
          bool exitApp = await showExitDialog(context);

          if (exitApp) {
            SystemNavigator.pop(); // close app
          }
        },
        child: Scaffold(
          backgroundColor: inner_background(),
          appBar: AppBar(
            title: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: isTablet ? 24 : 20,
                  color: inner_background(),
                ),
                SizedBox(width: 8),
                Text(
                  "Admin Panel", 
                  style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.w600,
                      color: inner_background()),
                ),
              ],
            ),
            backgroundColor: outer_background(),
            centerTitle: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            actions: [
              ProfileButton(
                  context: context, hotelref: hotelref, isTablet: isTablet)
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32 : 16,
                        vertical: isTablet ? 24 : 16,
                      ),
                      child: Column(
                        children: [
                          // Hotel Logo with animation
                          Hero(
                            tag: 'hotel_logo',
                            child: Container(
                              width: isTablet ? 150 : 120,
                              height: isTablet ? 150 : 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: outer_background().withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _buildHotelLogo(),
                              ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 20 : 16),

                          // Hotel Name
                          Text(
                            UserData!['hotel_name'] == "SGS" ? "Shree Guru Sagar" : UserData!['hotel_name'] ?? 'Hotel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTablet ? 28 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          SizedBox(height: isTablet ? 40 : 32),

                          // Button Grid with responsive layout
                          _buildDashboardGrid(
                              isTablet, isLandscape, screenWidth),

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }

  Widget _buildDashboardGrid(
      bool isTablet, bool isLandscape, double screenWidth) {
    int crossAxisCount;
    double childAspectRatio;

    if (isLandscape && isTablet) {
      crossAxisCount = 4;
      childAspectRatio = 1.3;
    } else if (isTablet) {
      crossAxisCount = 4;
      childAspectRatio = 1.1;
    } else if (isLandscape) {
      crossAxisCount = 3;
      childAspectRatio = 1.2;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 1.0;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: isTablet ? 20 : 16,
      mainAxisSpacing: isTablet ? 20 : 16,
      childAspectRatio: childAspectRatio,
      children: [
        _buildDashboardButton('Menu', Icons.restaurant_menu, isTablet),
        _buildDashboardButton('Settlements', Icons.receipt_long, isTablet),
        _buildDashboardButton('Roles', Icons.person, isTablet),
        _buildDashboardButton('Tables', Icons.table_chart, isTablet),
        _buildDashboardButton('GST Rate', Icons.currency_rupee_sharp, isTablet),
        _buildDashboardButton('Analytics', Icons.analytics, isTablet),
        _buildDashboardButton('Logs', Icons.local_activity, isTablet),
      ],
    );
  }

  Widget _buildHotelLogo() {
    final logoUrl = UserData!['hotel_logo_url'];

    if (logoUrl == null || logoUrl.isEmpty) {
      return Container(
        color: outer_background(),
        child: Icon(Icons.hotel, size: 60, color: Colors.white),
      );
    }

    return Image.network(
      logoUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: outer_background(),
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: outer_background().withOpacity(0.1),
          child: Icon(Icons.hotel, size: 60, color: outer_background()),
        );
      },
    );
  }

  Widget _buildDashboardButton(String label, IconData icon, bool isTablet) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) async {
        if (hotelref == null || hotelref.isEmpty) {
          showBounceSnackBar(context,
              'Hotel reference is invalid. Please try again.', 'error');
          return;
        }

        try {
          final DocumentSnapshot documentSnapshot = await FirebaseFirestore
              .instance
              .collection("Hotels")
              .doc(hotelref)
              .get()
              .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Failed to fetch hotel data');
            },
          );

          if (documentSnapshot.exists) {
            var data = documentSnapshot.data() as Map<String, dynamic>?;
            if (data != null && data.isNotEmpty) {
              if (mounted) {
                setState(() {
                  UserData!['no_of_tables'] = data['no_of_tables'];
                  UserData!['gst_rate'] = data['gst_rate'];
                });
              }
            }
          }
        } catch (e) {
          print('Error fetching hotel data: $e');
          if (mounted) {
            showBounceSnackBar(context,
                'Error fetching hotel data. Please try again.', 'error');
          }
          return;
        }

        print(label);

        if (label == "Tables") {
          // showLoadingDialog(context, message: "Loading Tables...");

          if (UserData!.containsKey('no_of_tables')) {
            _gstratecontroller =
                TextEditingController(text: "${UserData!['no_of_tables']}");
          } else {
            _gstratecontroller = TextEditingController(text: "");
          }
          _showInputDialog(
              context,
              "How many number of tables do you want to have?",
              "Number of tables",
              label);
          // showStatusSnackBar(context, "Tables added successfully!", "success");
        }

        if (label == "Settlements") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SettlementsPage(
                        href: hotelref,
                        role: "Admin",
                      )));
        }

        if (label == "GST Rate") {
          if (UserData!.containsKey('gst_rate')) {
            _gstratecontroller =
                TextEditingController(text: "${UserData!['gst_rate']}");
          } else {
            _gstratecontroller = TextEditingController(text: "");
          }
          _showInputDialog(context, "Edit Gst Rate.", "Gst Rate", label);
        }

        if (label == 'Roles') {
          print("coming inside");
          _showPopupMenu(context, details.globalPosition);
        }

        if (label == 'Menu') {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SwipableNavBar(
                  role: "Admin",
                  page1: "category_add",
                  page2: "search",
                  label: label,
                  href: hotelref,
                  table_option: "",
                ),
              ));
        }

        if (label == "Analytics") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalyticsDashboard(hotel_loc: hotelref),
            ),
          );
        }

        if (label == "Logs") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityLogsScreen(hotelRef: hotelref),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: outer_background(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: outer_background().withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isTablet ? 48 : 40,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('email');
  await prefs.remove('hotel_id');

  FirebaseAuth.instance.signOut().then((_) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => OrderEaseApp()),
      (Route<dynamic> route) => false,
    );
  }).catchError((error) {
    print("Error logging out: $error");
  });
}

class AdminInfoDialog extends StatelessWidget {
  final String adminName;
  final String adminEmail;
  final String adminRole;
  final int hotelID;

  AdminInfoDialog({
    required this.adminName,
    required this.adminEmail,
    required this.adminRole,
    required this.hotelID,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        constraints: BoxConstraints(
          maxWidth: isTablet ? 500 : 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: outer_background().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_circle,
                size: isTablet ? 60 : 50,
                color: outer_background(),
              ),
            ),
            SizedBox(height: 24),
            _buildInfoRow(Icons.person, 'Name', adminName, isTablet),
            SizedBox(height: 16),
            _buildInfoRow(Icons.email, 'Email', adminEmail, isTablet),
            SizedBox(height: 16),
            _buildInfoRow(Icons.badge, 'Role', adminRole, isTablet),
            SizedBox(height: 16),
            _buildInfoRow(
                Icons.business, 'Hotel ID', hotelID.toString(), isTablet),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: outer_background()),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: outer_background(),
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      logout(context);
                    },
                    icon: Icon(Icons.logout, size: isTablet ? 20 : 18),
                    label: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: outer_background(),
                      foregroundColor: inner_background(),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: isTablet ? 24 : 20, color: outer_background()),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
