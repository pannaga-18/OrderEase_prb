import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:orderease/Admin/admin_dashboard.dart';
import 'package:orderease/LandingScreen/home_screen.dart';
import 'package:orderease/Settlements/Bill_Print/print_bill.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import "../firebase_options.dart";
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

// import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:orderease/Authentication/hotels_collection.dart';

// For color
import 'package:orderease/util_components/util.dart';

class RegisterLoginScreen extends StatefulWidget {
  final int selectedTab;

  RegisterLoginScreen({this.selectedTab = 0});

  @override
  _RegisterLoginScreenState createState() => _RegisterLoginScreenState();

  // This method will allow you to set the selected tab
  void logout_selectTab(int tab) {
    _RegisterLoginScreenState().setSelectedTab(tab);
  }
}

class _RegisterLoginScreenState extends State<RegisterLoginScreen> {
  int _selectedTab = 0;
  bool isOperationLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.selectedTab;
    adminLoginEmailController.addListener(() {
      setState(() {});
    });
    hotel_id_loginController.addListener(() {
      setState(() {});
    });
  }

  void setSelectedTab(int tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  bool emailStatus = false;
  bool hotelIdStatus = false;

  XFile? _selectedImage; // For storing the uploaded image
  String _fileName = ''; // For displaying the file name

  int _currentPage = 0; // Tracks the current page in the "How It Works" section
  PageController _pageController = PageController();
  bool _isPasswordVisible = false; // Track password visibility state

  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final _formKey1 = GlobalKey<FormState>(); // Form key for validation

  TextEditingController hotelNameController = TextEditingController();
  TextEditingController adminNameController = TextEditingController();
  TextEditingController adminEmailController = TextEditingController();
  TextEditingController adminPasswordController = TextEditingController();
  TextEditingController hotelPhoneController = TextEditingController();
  TextEditingController gstNumberController = TextEditingController();
  TextEditingController gstRateController = TextEditingController();
  TextEditingController hotelAddressController = TextEditingController();
  TextEditingController hotelAreaController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController adminLoginEmailController = TextEditingController();
  TextEditingController adminLoginPasswordController = TextEditingController();
  TextEditingController hotel_id_loginController = TextEditingController();
  var hotel_name, admin_email, hotel_phone, gst_number, gst_rate, hotel_address;

  var hotel_area, pincode, admin_name;

  bool _isImageUploaded = false;

  void _pickImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();

      // Check platform and request permissions if on mobile
      if (!kIsWeb) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          showBounceSnackBar(context, "Storage permission denied.", "fail");

          return;
        }
      }

      // Proceed to pick an image
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Adjust the quality if needed
      );

      if (image != null) {
        final String fileName = image.name; // Get filename with extension
        final String nameWithoutExtension =
            fileName.split('.').first; // Extract name without extension

        // Check for allowed file extensions
        final allowedExtensions = ['jpg', 'jpeg', 'png'];
        String extension = fileName.split('.').last.toLowerCase();

        print(nameWithoutExtension);

        var name_list = nameWithoutExtension.split("_");

        // Validate file name length
        if (name_list[1].length > 6) {
          showBounceSnackBar(
              context,
              "File name (without extension) must be 6 characters or less.",
              "warning");

          return;
        }

        if (!allowedExtensions.contains(extension)) {
          showBounceSnackBar(
              context, "Only JPEG and PNG files are allowed.", "warning");

          return;
        }

        setState(() {
          _selectedImage = image;
          _fileName = name_list[1]; // Store the file name with extension
          _isImageUploaded = true;
        });
      } else {
        showBounceSnackBar(context, "No image selected.", "warning");
      }
    } catch (e) {
      showBounceSnackBar(context, "Failed to pick image.", "fail");
      print("Error picking image: $e");
    }
  }

  Future<void> _register(BuildContext context) async {
    // print(adminPasswordController.text);
    if (!_isImageUploaded) {
      showBounceSnackBar(
          context, "Please upload a photo before registering.", "warning");
      return; // Prevent registration if the image is not uploaded
    }

    if (_formKey.currentState!.validate()) {
      // Handle registration logic
      hotel_name = hotelNameController.text.trim();
      admin_name = adminNameController.text.trim();
      admin_email = adminEmailController.text.trim();
      var admin_password = adminPasswordController.text.trim();
      hotel_phone = hotelPhoneController.text.trim();
      gst_number = gstNumberController.text.trim();
      gst_rate = gstRateController.text.trim();
      hotel_address = hotelAddressController.text.trim();
      hotel_area = hotelAreaController.text.trim();
      pincode = pincodeController.text.trim();

      print('${hotel_name} \n $admin_email \n $hotel_phone \n $gst_number');
      print(gst_rate);
      print(hotel_address);
      print(hotel_area);
      print(pincode);
      print(_fileName);

      // Returns a downloaded url after storing in storage

      bool status =
          await validateHotel(hotel_name, hotel_area, pincode, gst_number);
      // if that url is not empty, create hotel collection and users sub collection.

      if (status == false) {
        String hotel_logo_url = await uploadImageToFirebase(_selectedImage);

        if (hotel_logo_url.isNotEmpty) {
          send_data(
              hotel_name,
              admin_name,
              admin_email,
              hotel_phone,
              gst_number,
              gst_rate,
              hotel_address,
              hotel_area,
              pincode,
              hotel_logo_url);

          bool reg_status =
              await registerUser(context, admin_email, admin_password);

          if (reg_status == true) {
            Timer(Duration(seconds: 2), () {
              setState(() {
                _selectedTab = 1;
              });
            });
          }
        }
      } else {
        showBounceSnackBar(
            context, "Hotel already registered, please login", "fail");
        setState(() {
          _selectedTab = 1;
        });
      }
    }
  }

  String? _validateHotelName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter hotel name';
    }
    return null;
  }

  String? _validateAdminName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter admin name';
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Only alphabets are allowed';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validateHotelArea(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter hotel area';
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Only alphabets are allowed';
    }
    return null;
  }

  String? _validateHotelAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter hotel address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter hotel phone';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Only numbers are allowed';
    }
    if (value.length > 10 || value.length < 10) {
      return "Invalid phone number";
    }
    return null;
  }

  String? _validateGstNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter GST Number';
    }
    return null;
  }

  String? _validateGstRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter GST Rate';
    }
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
      return 'Enter a valid integer or decimal value';
    }
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter pincode';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Only numbers are allowed';
    }
    if (value.length > 6 || value.length < 6) {
      return "Invalid Pin code";
    }
    return null;
  }

  @override
  void dispose() {
    // Dispose controllers to free resources when the widget is disposed
    hotelNameController.dispose();
    adminEmailController.dispose();
    adminPasswordController.dispose();
    hotelPhoneController.dispose();
    hotelAddressController.dispose();
    hotelAreaController.dispose();
    gstNumberController.dispose();
    gstRateController.dispose();
    pincodeController.dispose();
    adminNameController.dispose();
    adminLoginEmailController.dispose();
    adminLoginPasswordController.dispose();
    hotel_id_loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: inner_background(),
      appBar: AppBar(
        backgroundColor: outer_background(),
        elevation: 0,
        title: Text(
          'Hotel Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: inner_background(),
            onPressed: () => {Navigator.pop(context)}),
        centerTitle: true,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) async {
          if (details.primaryVelocity! > 0) {
            setState(() {
              _selectedTab = 0;
            });
          } else if (details.primaryVelocity! < 0) {
            var res = await getLoginDetails();
            setState(() {
              _selectedTab = 1;
              emailStatus = res;
              hotelIdStatus = res;
            });
          }
        },
        child: Column(
          children: [
            // Enhanced Tabs for Register/Login
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: outer_background(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 0;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? inner_background()
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color:
                                _selectedTab == 0 ? Colors.black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        var res = await getLoginDetails();
                        setState(() {
                          _selectedTab = 1;
                          emailStatus = res;
                          hotelIdStatus = res;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? inner_background()
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color:
                                _selectedTab == 1 ? Colors.black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Animated form switching
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _selectedTab == 0
                    ? _buildRegisterForm(context)
                    : _buildLoginForm(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 32.0 : 16.0;
    final maxWidth = screenWidth > 800 ? 600.0 : double.infinity;

    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding:
              EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
          child: GestureDetector(
            onHorizontalDragEnd: (details) async {
              if (details.primaryVelocity! > 0) {
                setState(() {
                  _selectedTab = 0;
                });
              } else if (details.primaryVelocity! < 0) {
                var res = await getLoginDetails();
                setState(() {
                  _selectedTab = 1;
                  emailStatus = res;
                  hotelIdStatus = res;
                });
              }
            },
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    "Register your Hotel",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Get started with your hotel management",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Form Fields with improved styling
                  _buildEnhancedTextField(
                    controller: hotelNameController,
                    label: 'Hotel Name',
                    icon: Icons.business,
                    validator: _validateHotelName,
                  ),
                  SizedBox(height: 20),

                  _buildEnhancedTextField(
                    controller: adminNameController,
                    label: 'Admin Name',
                    icon: Icons.person,
                    validator: _validateAdminName,
                  ),
                  SizedBox(height: 20),

                  _buildEnhancedTextField(
                    controller: adminEmailController,
                    label: 'Admin Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 20),

                  _buildEnhancedPasswordField(
                      "Admin Password", adminPasswordController),
                  SizedBox(height: 20),

                  _buildEnhancedTextField(
                    controller: hotelPhoneController,
                    label: 'Hotel Phone',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      flutter_services.FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: _validatePhone,
                  ),
                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildEnhancedTextField(
                          controller: gstNumberController,
                          label: 'GST Number',
                          icon: Icons.receipt_long,
                          validator: _validateGstNumber,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _buildEnhancedTextField(
                          controller: gstRateController,
                          label: 'GST Rate %',
                          icon: Icons.percent,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            flutter_services
                                .FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _validateGstRate,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  _buildEnhancedTextField(
                    controller: hotelAddressController,
                    label: 'Hotel Address',
                    icon: Icons.location_on,
                    maxLines: 2,
                    validator: _validateHotelAddress,
                  ),
                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildEnhancedTextField(
                          controller: hotelAreaController,
                          label: 'Hotel Area',
                          icon: Icons.map,
                          inputFormatters: [
                            flutter_services.FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z ]')),
                          ],
                          validator: _validateHotelArea,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildEnhancedTextField(
                          controller: pincodeController,
                          label: 'Pincode',
                          icon: Icons.pin_drop,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            flutter_services
                                .FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _validatePincode,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Upload button with improved design
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hotel Logo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_selectedImage != null) ...[
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green, size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _fileName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    'No file selected',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            _pickImage(context);
                          },
                          icon: Icon(Icons.upload_file, size: 18),
                          label: Text('Choose File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: outer_background(),
                            foregroundColor: inner_background(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Register button with improved styling
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isOperationLoading
                          ? null
                          : () async {
                              setState(() {
                                isOperationLoading = true;
                              });

                              await _register(context);

                              setState(() {
                                isOperationLoading = false;
                              });
                            },
                      child: isOperationLoading
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Registering Hotel...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ...getCircularProgressIndicator()
                              ],
                            )
                          : Text(
                              'Register Hotel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: outer_background(),
                        foregroundColor: inner_background(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  // SizedBox(height: 32),

                  // // Enhanced "How It Works" section
                  // Container(
                  //   width: double.infinity,
                  //   padding: EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       colors: [
                  //         outer_background(),
                  //         outer_background().withOpacity(0.8)
                  //       ],
                  //       begin: Alignment.topLeft,
                  //       end: Alignment.bottomRight,
                  //     ),
                  //     borderRadius: BorderRadius.circular(16),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.1),
                  //         blurRadius: 10,
                  //         offset: Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         children: [
                  //           Icon(Icons.info_outline, color: Colors.white),
                  //           SizedBox(width: 8),
                  //           Text(
                  //             'HOW IT WORKS',
                  //             style: TextStyle(
                  //               fontSize: 18,
                  //               fontWeight: FontWeight.bold,
                  //               color: Colors.white,
                  //               letterSpacing: 1.2,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       SizedBox(height: 16),
                  //       SizedBox(
                  //         height: 180,
                  //         child: PageView(
                  //           controller: _pageController,
                  //           onPageChanged: (int page) {
                  //             setState(() {
                  //               _currentPage = page;
                  //             });
                  //           },
                  //           children: [
                  //             _buildHowItWorksSlide([
                  //               'Point 1 for roles description',
                  //               'Point 2 for roles description',
                  //               'Point 3 for roles description'
                  //             ]),
                  //             _buildHowItWorksSlide([
                  //               'First step for operation',
                  //               'Second step for operation',
                  //               'Third step for operation'
                  //             ]),
                  //             _buildHowItWorksSlide([
                  //               'First advantage point',
                  //               'Second advantage point',
                  //               'Third advantage point'
                  //             ]),
                  //             _buildHowItWorksSlide([
                  //               'Instruction 1',
                  //               'Instruction 2',
                  //               'Instruction 3'
                  //             ]),
                  //           ],
                  //         ),
                  //       ),
                  //       SizedBox(height: 16),
                  //       // Enhanced pagination dots
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: List.generate(4, (index) {
                  //           return AnimatedContainer(
                  //             duration: Duration(milliseconds: 300),
                  //             margin: EdgeInsets.symmetric(horizontal: 4.0),
                  //             width: _currentPage == index ? 24.0 : 8.0,
                  //             height: 8.0,
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(4),
                  //               color: _currentPage == index
                  //                   ? Colors.white
                  //                   : Colors.white.withOpacity(0.5),
                  //             ),
                  //           );
                  //         }),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<flutter_services.TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: outer_background()),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outer_background(), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildEnhancedPasswordField(
      String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: outer_background()),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outer_background(), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[600],
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: _validatePassword,
    );
  }

  Widget _buildTextField(String label) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return _buildEnhancedPasswordField(label, controller);
  }

  Widget _buildHowItWorksSlide(List<String> points) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: points
            .asMap()
            .entries
            .map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: outer_background(),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Future<bool> getLoginDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? user_email = await prefs.getString('email');
    String? hotel_id = await prefs.getString('hotel_id');

    print("User email ${user_email}");
    print("HOT ID ${hotel_id}");

    if (user_email != null && hotel_id != null) {
      adminLoginEmailController.text = user_email;
      hotel_id_loginController.text = hotel_id;
      return true;
    }

    return false;
  }

  Widget _buildLoginForm(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 32.0 : 16.0;
    final maxWidth = screenWidth > 800 ? 500.0 : double.infinity;

    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) async {
        if (details.primaryVelocity! > 0) {
          setState(() {
            _selectedTab = 0;
          });
        } else if (details.primaryVelocity! < 0) {
          var res = await getLoginDetails();
          setState(() {
            _selectedTab = 1;
            emailStatus = res;
            hotelIdStatus = res;
          });
        }
      },
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 32),
            child: Form(
              key: _formKey1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Sign in to continue managing your hotel",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 48),

                  // Email Field
                  TextFormField(
                    controller: adminLoginEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: outer_background()),
                      suffixIcon: adminLoginEmailController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  adminLoginEmailController.clear();
                                  emailStatus = false;
                                });
                              },
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: outer_background(), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Hotel ID Field
                  TextFormField(
                    controller: hotel_id_loginController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <flutter_services.TextInputFormatter>[
                      flutter_services.FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      labelText: 'Hotel ID',
                      prefixIcon: Icon(Icons.badge, color: outer_background()),
                      suffixIcon: hotel_id_loginController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  hotel_id_loginController.clear();
                                  hotelIdStatus = false;
                                });
                              },
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: outer_background(), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your hotel id';
                    },
                  ),
                  SizedBox(height: 20),

                  // Password Field
                  _buildPasswordField("Password", adminLoginPasswordController),
                  SizedBox(height: 12),

                  // Forgot Password (Optional)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Add forgot password logic
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: outer_background(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isOperationLoading
                          ? null
                          : () async {
                              setState(() {
                                isOperationLoading = true;
                              });
                              final email =
                                  adminLoginEmailController.text.trim();
                              final password =
                                  adminLoginPasswordController.text.trim();
                              final hotelId = hotel_id_loginController.text;

                              if (_formKey1.currentState!.validate()) {
                                Object data = await validate_hotel_during_login(
                                    email, hotelId);

                                if (data is Map<String, dynamic>) {
                                  if (['Admin', 'Manager', 'Cook', 'Cashier']
                                      .contains(data['role'])) {
                                    bool res = await loginUser(email, password,
                                        data['role'], data, context);
                                    if (res) {
                                      setState(() {
                                        isOperationLoading = false;
                                      });
                                    }
                                  } else
                                    showBounceSnackBar(
                                        context,
                                        "This role does not exist. Contact the admin",
                                        "fail");
                                }
                              }
                              setState(() {
                                isOperationLoading = false;
                              });
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isOperationLoading ? 'Logging in...' : 'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isOperationLoading)
                            ...getCircularProgressIndicator()
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: outer_background(),
                        foregroundColor: inner_background(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Info card
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Use your registered email and hotel ID to access your account',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
