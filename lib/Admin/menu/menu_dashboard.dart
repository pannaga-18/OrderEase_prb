import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/util_components/bottom_navbar.dart';
import 'package:orderease/util_components/profile.dart';
import 'package:orderease/util_components/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var hotelref, Dash_label, hotel_loc;

bool show_text_status = true;
bool _isLoading = true;

List<String> cardTitles = [];
Map imagePaths = {};
// Map imagePaths

Future<void> get_data(String label, String href) async {
  Dash_label = label;
  hotel_loc = href;

  print("Inside menu_dah ${Dash_label}, ${hotel_loc}");

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("Hotels")
      .doc(hotel_loc)
      .collection("Menu")
      .get();

  if (querySnapshot.size != 0) {
    show_text_status = false;

    cardTitles = [];
    for (var doc in querySnapshot.docs) {
      cardTitles.add(doc.id);

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(hotel_loc)
          .collection("Menu")
          .doc(doc.id)
          .get();
      var data = documentSnapshot.data() as Map<String, dynamic>;
      // print(data);

      imagePaths[doc.id] = data['category_image_path'];
    }
  } else {
    cardTitles = [];
    show_text_status = true;
    print("MEnu bbbbbbb00");
  }
}

class Menu_Dashboard extends StatefulWidget {
  final String label;
  final String href;

  Menu_Dashboard({required this.label, required this.href});

  @override
  Dashboard createState() => Dashboard();
}

class Dashboard extends State<Menu_Dashboard> {
  @override
  void initState() {
    super.initState();
    fetchMenuData();
  }

  // fetching category, each time when
  Future<void> fetchMenuData() async {
    // Call get_data to fetch menu information
    await get_data(widget.label, widget.href);
    setState(() {
      _isLoading =
          false; // Data has been loaded, stop showing the loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      backgroundColor: inner_background(),
      appBar: AppBar(
        title: (isLandscape)
            ? Text(
                "Menu Dashboard",
                style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    color: inner_background(),
                    fontWeight: FontWeight.w600),
              )
            : Text(""),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: inner_background(),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: outer_background(),
        elevation: 0,
        actions: [
          ProfileButton(
              context: context, hotelref: widget.href, isTablet: isTablet)
        ],
      ),
      body: _isLoading
          ? CustomLoader(message: 'Loading menu...')
          : show_text_status
              ? _buildEmptyState(context, isLandscape, isTablet)
              : _buildMenuContent(context, isLandscape, isTablet),
    );
  }

// Empty State Widget - Fully Responsive
  Widget _buildEmptyState(
      BuildContext context, bool isLandscape, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final horizontalPadding =
            isLandscape ? (isTablet ? 60.0 : 40.0) : (isWide ? 40.0 : 20.0);
        final verticalSpacing = isLandscape ? 16.0 : 24.0;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: isLandscape ? 20 : (isWide ? 40 : 24)),

                // Parchment Header
                if (!isLandscape)
                  _buildParchmentHeader(
                    context,
                    isWide,
                    0, // No additional padding, already applied
                    isLandscape,
                  ),

                SizedBox(height: isLandscape ? 30 : 60),

                // Main Content - Landscape uses Row layout
                if (isLandscape && isTablet)
                  _buildLandscapeEmptyContent(isWide, verticalSpacing)
                else
                  _buildPortraitEmptyContent(isWide, verticalSpacing),
              ],
            ),
          ),
        );
      },
    );
  }

// Portrait Empty Content
  Widget _buildPortraitEmptyContent(bool isWide, double verticalSpacing) {
    return Column(
      children: [
        // Empty State Illustration
        _buildEmptyIllustration(isWide),
        SizedBox(height: verticalSpacing),
        _buildEmptyText(isWide),
        // SizedBox(height: 32),
        // _buildAddCategoryButton(isWide, false),
      ],
    );
  }

// Landscape Empty Content
  Widget _buildLandscapeEmptyContent(bool isWide, double verticalSpacing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: _buildEmptyIllustration(isWide),
        ),
        SizedBox(width: 40),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmptyText(isWide,
                  crossAxisAlignment: CrossAxisAlignment.start),
              // SizedBox(height: 24),
              // _buildAddCategoryButton(isWide, true),
            ],
          ),
        ),
      ],
    );
  }

// Empty Illustration Widget
  Widget _buildEmptyIllustration(bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 32 : 24),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            outer_background().withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.restaurant_menu,
        size: isWide ? 100 : 80,
        color: outer_background().withOpacity(0.3),
      ),
    );
  }

// Empty Text Widget
  Widget _buildEmptyText(bool isWide,
      {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "No Menu Added Yet",
          style: TextStyle(
            fontSize: isWide ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: dark_outer_background(),
            fontFamily: 'serif',
          ),
          textAlign: crossAxisAlignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.left,
        ),
        SizedBox(height: 12),
        Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: Text(
            "Begin your culinary journey by adding\nyour first category to the menu",
            style: TextStyle(
              fontSize: isWide ? 16 : 14,
              color: outer_background(),
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: crossAxisAlignment == CrossAxisAlignment.center
                ? TextAlign.center
                : TextAlign.left,
          ),
        ),
      ],
    );
  }

// Add Category Button
  Widget _buildAddCategoryButton(bool isWide, bool isLandscape) {
    return Container(
      constraints: BoxConstraints(
        maxWidth:
            isLandscape ? double.infinity : (isWide ? 400 : double.infinity),
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to add category
        },
        icon: Icon(Icons.add_circle_outline, size: 20),
        label: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Add Your First Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: outer_background(),
          foregroundColor: inner_background(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

// Menu Content Widget - Fully Responsive
  Widget _buildMenuContent(
      BuildContext context, bool isLandscape, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final horizontalPadding =
            isLandscape ? (isTablet ? 60.0 : 40.0) : (isWide ? 40.0 : 20.0);

        return Column(
          children: [
            SizedBox(height: isLandscape ? 0 : (isWide ? 40 : 24)),

            // Parchment Header

            if (!isLandscape)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildParchmentHeader(context, isWide, 0, isLandscape),
              ),

            SizedBox(height: isLandscape ? 20 : 32),

            // Categories Grid/List
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: build_category_cards(
                    href: widget.href,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// Parchment Header - Responsive
  Widget _buildParchmentHeader(
    BuildContext context,
    bool isWide,
    double horizontalPadding,
    bool isLandscape,
  ) {
    final headerPadding =
        isLandscape ? (isWide ? 32.0 : 20.0) : (isWide ? 40.0 : 24.0);
    final verticalPadding =
        isLandscape ? (isWide ? 18.0 : 14.0) : (isWide ? 24.0 : 18.0);
    final titleSize =
        isLandscape ? (isWide ? 28.0 : 22.0) : (isWide ? 32.0 : 26.0);

    return Container(
      constraints: BoxConstraints(
        maxWidth: isWide ? 700 : double.infinity,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            inner_background(),
            Color(0xFFEBF6FF),
            inner_background(),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: outer_background().withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: dark_outer_background().withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: outer_background().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Subtle texture overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  outer_background().withOpacity(0.05),
                  Colors.transparent,
                  dark_outer_background().withOpacity(0.03),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: headerPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decorative top border
                _buildDecorativeRow(isWide, isLandscape),

                SizedBox(height: isLandscape ? 12 : (isWide ? 20 : 16)),

                // Title
                Text(
                  Dash_label,
                  style: TextStyle(
                    color: dark_outer_background(),
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: outer_background().withOpacity(0.3),
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isLandscape ? 12 : (isWide ? 20 : 16)),

                // Decorative bottom border
                _buildDecorativeRow(isWide, isLandscape),
              ],
            ),
          ),

          // Curl effect corners
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: Size(30, 30),
              painter: _CurlPainter(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: CustomPaint(
              size: Size(30, 30),
              painter: _CurlPainter(),
            ),
          ),
        ],
      ),
    );
  }

// Decorative Row
  Widget _buildDecorativeRow(bool isWide, bool isLandscape) {
    final iconSize =
        isLandscape ? (isWide ? 18.0 : 16.0) : (isWide ? 22.0 : 18.0);

    return Row(
      children: [
        Expanded(child: _buildDecorativeLine()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isLandscape ? 8 : 12),
          child: Icon(
            Icons.auto_awesome,
            color: outer_background(),
            size: iconSize,
          ),
        ),
        Expanded(child: _buildDecorativeLine()),
      ],
    );
  }

// Decorative line widget
  Widget _buildDecorativeLine() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            outer_background().withOpacity(0.4),
            outer_background(),
            dark_outer_background(),
            outer_background(),
            outer_background().withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// Custom painter for paper curl effect
class _CurlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFD4E9FC)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width / 2, size.height / 2, size.width, 0)
      ..lineTo(0, 0);

    canvas.drawPath(path, paint);

    final shadowPaint = Paint()
      ..color = Color(0xFF397ABC).withOpacity(0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class build_category_cards extends StatefulWidget {
  final String href;
  const build_category_cards({required this.href});

  @override
  _BuildCategoryCardsState createState() => _BuildCategoryCardsState();
}

TextEditingController editCategoryController = TextEditingController();

class _BuildCategoryCardsState extends State<build_category_cards> {
  Offset? _tapposition;

  void _showInputDialog(
      BuildContext parentContext, String msg, String category) {
    final _formKey = GlobalKey<FormState>();
    String _inputValue = category;

    editCategoryController = TextEditingController(text: category);

    showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (BuildContext context) {
          final orientation = MediaQuery.of(context).orientation;
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final isLandscape = orientation == Orientation.landscape;
          return Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: isLandscape
                  ? screenWidth * 0.25 // More side padding in landscape
                  : screenWidth * 0.1, // Less side padding in portrait
              vertical: 24.0,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 24.0 : 20.0,
                vertical: isLandscape ? 16.0 : 20.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      msg,
                      style: TextStyle(
                        fontSize: isLandscape ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Form
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: editCategoryController,
                        decoration: InputDecoration(
                          labelText: "New Category Name",
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: isLandscape ? 12.0 : 16.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: isLandscape ? 14 : 16,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Field should not be empty';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _inputValue = value;
                        },
                      ),
                    ),
                    SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: outer_background(),
                            padding: EdgeInsets.symmetric(
                              horizontal: isLandscape ? 20.0 : 16.0,
                              vertical: isLandscape ? 8.0 : 12.0,
                            ),
                          ),
                          child: Text('Cancel'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: inner_background(),
                            backgroundColor: outer_background(),
                            padding: EdgeInsets.symmetric(
                              horizontal: isLandscape ? 24.0 : 20.0,
                              vertical: isLandscape ? 8.0 : 12.0,
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var oldCate = category;
                              DocumentSnapshot documentSnapshot =
                                  await FirebaseFirestore.instance
                                      .collection("Hotels")
                                      .doc(hotel_loc)
                                      .collection("Menu")
                                      .doc(category)
                                      .get();

                              Map<String, dynamic>? oldMenuData =
                                  documentSnapshot.data()
                                      as Map<String, dynamic>?;

                              if (oldMenuData != null) {
                                await FirebaseFirestore.instance
                                    .collection("Hotels")
                                    .doc(hotel_loc)
                                    .collection("Menu")
                                    .doc(_inputValue)
                                    .set(oldMenuData);

                                await FirebaseFirestore.instance
                                    .collection("Hotels")
                                    .doc(hotel_loc)
                                    .collection("Menu")
                                    .doc(category)
                                    .delete();
                              }

                              // Updating UI
                              var oldCategory = category;
                              var newCategory = _inputValue;

                              String email =
                                  FirebaseAuth.instance.currentUser!.email!;
                              await addLogEntry(
                                hotelId: hotel_loc,
                                userEmail: email,
                                action:
                                    "Edited menu item (${oldCategory.toString().toLowerCase()} -> ${newCategory.toString().toLowerCase()}).",
                                tableNumber: "",
                                sessionId: "",
                              );

                              setState(() {
                                int index = cardTitles.indexOf(oldCate);
                                if (index != -1) {
                                  cardTitles[index] = _inputValue;
                                  print("PPPP");
                                  print(imagePaths);
                                }
                                // Updating UI after renaming category
                                if (imagePaths.containsKey(oldCategory)) {
                                  imagePaths[newCategory] =
                                      imagePaths[oldCategory];
                                  imagePaths.remove(oldCategory);
                                }
                              });

                              Navigator.of(context).pop(); // Close dialog
                              showSlideFromLeftSnackBar(parentContext,
                                  "Menu edited successfully!", "success");
                            }
                          },
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  // To store data that is being deleted
  var data;

  // Undo function
  void undo_the_category(var data, var category_name) async {
    print(data);

    await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(hotel_loc)
        .collection("Menu")
        .doc(category_name)
        .set(data);
    print("unoed");
  }

  // Delete function (only deletes, data should already be fetched)
  void _delete_category(var category_name, BuildContext context) async {
    try {
      String email = FirebaseAuth.instance.currentUser!.email!;
      await addLogEntry(
        hotelId: hotel_loc,
        userEmail: email,
        action: "Deleted category (${category_name.toString().toLowerCase()}).",
        tableNumber: "",
        sessionId: "",
      );
      try {
        // Extract the file path from the URL
        if (data != null && data['category_image_path'] != null) {
          final RegExp regExp = RegExp(r'o/(.*)\?alt=media');
          final RegExpMatch? match =
              regExp.firstMatch(data['category_image_path']);

          if (match != null) {
            String filePath =
                Uri.decodeFull(match.group(1)!); // Decode the file path

            // Reference to the file in Firebase Storage
            Reference fileRef = FirebaseStorage.instance.ref().child(filePath);

            // Delete the file with timeout
            await fileRef.delete().timeout(Duration(seconds: 5));
            print("File deleted successfully: $filePath");
          } else {
            print("Invalid Firebase Storage URL.");
          }
        }
      } catch (e) {
        print("Error while deleting file: $e");
      }

      // Delete from Firestore with timeout
      await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(hotel_loc)
          .collection("Menu")
          .doc(category_name)
          .delete()
          .timeout(Duration(seconds: 5));

      print("${category_name} deleted");

      // Only call setState if widget is still mounted
      if (mounted) {
        setState(() {
          cardTitles
              .remove(category_name); // Remove the deleted item from the list
        });
      }
    } on TimeoutException {
      print("Deletion timeout for category: $category_name");
    } catch (e) {
      print("Error deleting category: $e");
    }
  }

  // Delete and Undo functionality
  void alert_before_deleting(
      BuildContext parentContext, String message, String category_name) {
    int flag_delete = 0;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete ${category_name}"),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: inner_background(),
                    foregroundColor: outer_background(),
                  ),
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    // Fetch data before showing SnackBar
                    try {
                      DocumentSnapshot documentSnapshot =
                          await FirebaseFirestore.instance
                              .collection("Hotels")
                              .doc(hotel_loc)
                              .collection("Menu")
                              .doc(category_name)
                              .get()
                              .timeout(Duration(seconds: 5));

                      if (documentSnapshot.exists) {
                        data = documentSnapshot.data();
                      }
                    } catch (e) {
                      print("Error fetching category data: $e");
                      if (mounted) {
                        showBounceSnackBar(
                            context,
                            "Error fetching category data. Undo may not work.",
                            "error");
                      }
                      return;
                    }

                    Navigator.pop(context);
                    setState(() {
                      cardTitles.remove(
                          category_name); // Remove the deleted item from the list
                    });

                    // Show SnackBar after popping dialog
                    Future.delayed(Duration(milliseconds: 100), () {
                      playSound("info");

                      if (mounted) {
                        ScaffoldMessenger.of(parentContext)
                            .showSnackBar(SnackBar(
                          duration: Duration(seconds: 5),
                          content: Row(
                            children: [
                              Expanded(
                                child: Text("Category deleted!"),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    print(data);
                                    print("Undo pressed");
                                    undo_the_category(data, category_name);
                                    flag_delete = 1;
                                    // Add the category to card Titles if undoed..
                                    setState(() {
                                      cardTitles.add(category_name);
                                    });
                                  },
                                  // Style
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: outer_background(),
                                      foregroundColor: inner_background()),
                                  //
                                  child: Text(
                                    "Undo",
                                    style:
                                        TextStyle(color: (inner_background())),
                                  ))
                            ],
                          ),
                          backgroundColor: lightenColor(Color(0xFF397ABC), 0.3),
                        ));

                        // delete the doc after 5 seconds if not undoed
                        Timer(Duration(seconds: 5), () {
                          if (flag_delete == 0)
                            _delete_category(category_name, context);
                        });
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: outer_background(),
                    foregroundColor: inner_background(),
                  ),

                  // Delete function
                  child: Text("Delete")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen orientation and width
    final orientation = MediaQuery.of(context).orientation;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine cross axis count based on orientation and screen width
    int getCrossAxisCount() {
      if (orientation == Orientation.landscape) {
        // Landscape mode: more columns
        if (screenWidth > 1200) return 5;
        if (screenWidth > 900) return 4;
        return 3;
      } else {
        // Portrait mode
        if (screenWidth > 600) return 3;
        return 2;
      }
    }

    // Calculate responsive card height
    double getCardHeight() {
      if (orientation == Orientation.landscape) {
        return screenWidth > 900 ? 140 : 120;
      }
      return 115;
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // If inside ScrollView
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: getCrossAxisCount(),
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
          mainAxisExtent: getCardHeight(),
        ),
        itemCount: cardTitles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTapDown: (TapDownDetails details) async {
              _tapposition = details.globalPosition;
            },
            onTapUp: (TapUpDetails details) {
              print("Tap ended at: ${details.globalPosition}");
              _tapposition = details.globalPosition;
              // print("Pressed Category ${cardTitles[index]}");
              print("href ${widget.href}");
              print(index);
              print("ERROR INDEX");
              // print("label ${cardTitles[index]}");
              print("cardTitles: $cardTitles");
              print("Length: ${cardTitles.length}");
              print("Index: $index");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SwipableNavBar(
                    role: "Admin",
                    page1: "add_menu_items",
                    page2: "search",
                    label: cardTitles[index],
                    href: widget.href,
                    table_option: "",
                  ),
                ),
              );
            },
            onLongPress: () {
              print("Long press detected");
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  _tapposition!.dx,
                  _tapposition!.dy,
                  _tapposition!.dx,
                  _tapposition!.dy,
                ),
                items: [
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _showInputDialog(
                          context,
                          "Do you wish to edit category name?",
                          cardTitles[index],
                        );
                      },
                      child: Text(
                        "Edit name",
                        style: TextStyle(color: outer_background()),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        alert_before_deleting(
                          context,
                          "This category will be permanently deleted from the menu. Do you want to delete?",
                          cardTitles[index],
                        );
                      },
                      child: Text(
                        "Delete",
                        style: TextStyle(color: outer_background()),
                      ),
                    ),
                  ),
                ],
              );
            },
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  // Background Image from Firebase
                  if (imagePaths[cardTitles[index]] != null &&
                      imagePaths[cardTitles[index]] != "")
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          imagePaths[cardTitles[index]]!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: outer_background(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: outer_background(),
                            );
                          },
                        ),
                      ),
                    ),

                  // Default Background Color
                  if (imagePaths[cardTitles[index]] == null ||
                      imagePaths[cardTitles[index]] == "")
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: outer_background(),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),

                  // Text Content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: Text(
                        cardTitles[index],
                        style: TextStyle(
                          fontSize: orientation == Orientation.landscape &&
                                  screenWidth > 900
                              ? 22
                              : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
