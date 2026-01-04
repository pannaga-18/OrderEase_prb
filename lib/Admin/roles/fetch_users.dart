import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/util_components/profile.dart';
import 'package:orderease/util_components/util.dart';

class Fetch_Users_Page extends StatefulWidget {
  final String user_role;
  final String href;
  const Fetch_Users_Page({required this.user_role, required this.href});
  @override
  _Fetch_Users_PageState createState() => _Fetch_Users_PageState();
}

class _Fetch_Users_PageState extends State<Fetch_Users_Page> {
  final List<Map<String, dynamic>> users = [];
  bool _isLoading = true;
  bool _HasNoData = false;

  Future<void> get_users_details(String role) async {
    print("A");
    print(role);
    QuerySnapshot? querySnapshot;
    if (role == "Manager") {
      querySnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.href)
          .collection("Users")
          .where("role", whereIn: ["Manager", "Cashier"]).get();
    } else if (role == "Cook") {
      querySnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.href)
          .collection("Users")
          .where("role", isEqualTo: "Cook")
          .get();
    }

    if (querySnapshot!.size != 0) {
      _HasNoData = false;
      for (var doc in querySnapshot.docs) {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("Hotels")
            .doc(widget.href)
            .collection("Users")
            .doc(doc.id)
            .get();

        users.add(documentSnapshot.data() as Map<String, dynamic>);
      }
      print("USERS DATA");
      print(users);
    } else {
      _HasNoData = true;
    }
  }

  Future<void> fetch_users(String role) async {
    await get_users_details(role);

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _show_Alert_before_delete(
      BuildContext context, String userEmail, String role) async {
    bool undo_flag = true;
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text("Delete $role"),
              content: Text("Do you want to remove $userEmail as $role?"),
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
                    Navigator.of(dialogContext)
                        .pop(); // Close dialog and return true
                    try {
                      Map<String, dynamic> to_be_deleted_data = {};
                      to_be_deleted_data = users
                          .firstWhere((user) => user['email'] == userEmail);
                      print("ASD");
                      print(to_be_deleted_data);

                      setState(() {
                        users.removeWhere((user) => user['email'] == userEmail);
                      });
                      // Display message
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Row(
                          children: [
                            Expanded(
                              child: Text("$role removed!!"),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  // Remove locally

                                  // Update local state
                                  setState(() {
                                    undo_flag = false;
                                    users.add(to_be_deleted_data);
                                  });
                                },

                                // Style
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: outer_background(),
                                    foregroundColor: inner_background()),
                                //
                                child: Text(
                                  "Undo",
                                  style: TextStyle(color: (inner_background())),
                                ))
                          ],
                        ),
                        backgroundColor: lightenColor(Color(0xFF397ABC), 0.3),
                        // action: SnackBarAction(label: "Undo", onPressed: () {}),
                        duration: Duration(seconds: 3),
                      ));

                      Timer(Duration(seconds: 5), () async {
                        // Remove from Firestore

                        if (undo_flag) {
                          // Log
                          String email =
                              FirebaseAuth.instance.currentUser!.email!;
                          await addLogEntry(
                            hotelId: widget.href,
                            userEmail: email,
                            action: "Deleted employee -> $userEmail.",
                            tableNumber: "",
                            sessionId: "",
                          );

                          await FirebaseFirestore.instance
                              .collection("Hotels")
                              .doc(widget.href)
                              .collection("Users")
                              .doc(userEmail)
                              .delete();
                        }

                        // FirebaseAuth.instance.currentUser!
                        //     .delete()
                        //     .then((value) {
                        //   print("User Deleted");
                        // }).catchError((error) {
                        //   print("Error deleting user: $error");
                        // });
                      });
                    } catch (error) {
                      // Handle errors
                      showBounceSnackBar(
                          context, "Error deleting item:", "fail");
                    }
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetch_users(widget.user_role);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final hotelref = widget.href;
    return Scaffold(
      backgroundColor: inner_background(),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: outer_background(),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: inner_background(),
        ),
        title: Text(
          widget.user_role == "Manager" ? "Managers | Cashiers" : "Cooks",
          style:
              TextStyle(color: inner_background(), fontWeight: FontWeight.w600),
        ),
        actions: [
          ProfileButton(
              context: context, hotelref: hotelref, isTablet: isTablet)
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? CustomLoader(
              message:
                  "Loading ${widget.user_role == "Manager" ? "Managers, Cashiers" : "Cooks"}...",
            )
          : _HasNoData
              ? Center(
                  child: Text(
                      "No ${widget.user_role == "Manager" ? "Managers | Cashiers" : "Cooks"} added!"),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: outer_background(),
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20),
                            ),

                            // Cards
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                side: BorderSide(
                                  color: outer_background(),
                                  width: 2.0,
                                ),
                              ),
                              color: inner_background(),
                              child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Name:",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  users[index]['name'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          ),

                                          // Email
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Email:",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  users[index]['email'],
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          ),

                                          // Role
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Role:",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  users[index]['role'],
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              // Navigator.of(context).pop();

                                              _show_Alert_before_delete(
                                                  context,
                                                  users[index]['email'],
                                                  users[index]['role']);
                                            },
                                            icon: Icon(Icons.delete)),
                                        Column(
                                          children: [
                                            Switch(
                                              value: users[index]
                                                  ['working_status'],
                                              onChanged: (value) async {

                                                // Log
                                                String email = FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .email!;

                                                String val = (value) ? "On Duty" : "Off Duty";

                                                await addLogEntry(
                                                  hotelId: widget.href,
                                                  userEmail: email,
                                                  action:
                                                      "Changed working status ${users[index]['email']} -> $val.",
                                                  tableNumber: "",
                                                  sessionId: "",
                                                );

                                                // updating status
                                                await FirebaseFirestore.instance
                                                    .collection("Hotels")
                                                    .doc(widget.href)
                                                    .collection("Users")
                                                    .doc(users[index]['email'])
                                                    .update({
                                                  "working_status": value,
                                                });

                                                //
                                                setState(() {
                                                  users[index]
                                                          ['working_status'] =
                                                      value;
                                                });
                                              },
                                              activeColor: outer_background(),
                                              inactiveThumbColor: Colors.grey,
                                              inactiveTrackColor:
                                                  Colors.grey.shade200,
                                            ),
                                            Text(
                                              users[index]['working_status']
                                                  ? "On Duty"
                                                  : "Off Duty",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  ])),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
