import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/Admin/roles/user_dashboard.dart';
import 'package:orderease/util_components/profile.dart';
import 'package:orderease/util_components/util.dart';

class AddUserPage extends StatefulWidget {
  final String href;
  const AddUserPage({required this.href});
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _role = '';
  TextEditingController userEmailController = TextEditingController();
  String selectedRole = "Manager";
  bool _isPasswordVisible = false;
  bool _isLoading = false;

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

  Future<void> createUserCollection(
      String email, String name, String role) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.href)
        .collection("Users")
        .doc(email)
        .get();

    if (!documentSnapshot.exists) {
      print("Creating user collection");
      print(widget.href);
      print(email);
      print(name);
      print(role);
      await FirebaseFirestore.instance
          .collection("Hotels")
          .doc(widget.href)
          .collection("Users")
          .doc(email)
          .set({
        "name": name,
        "email": email,
        "role": role,
        "working_status": false
      });
    }
  }

  Future<bool> registerUser(BuildContext context, String email, String password,
      String name, String role) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Store current admin info BEFORE creating new user
      User? adminUser = FirebaseAuth.instance.currentUser;
      String? adminEmail = adminUser?.email;
      String? adminPassword = _password; // Store admin password if available

      // Create new user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .timeout(const Duration(seconds: 10));

      // Create user collection in Firestore
      await createUserCollection(email, name, role);

      // IMPORTANT: Sign out the newly created user and sign back in as admin
      await FirebaseAuth.instance.signOut();

      // Re-sign in the admin using stored credentials
      if (adminEmail != null) {
        try {
          // Show verification dialog to get admin password
          final adminPasswordFromDialog = await _showReAuthenticationDialog(
            context,
            adminEmail,
          );

          if (adminPasswordFromDialog != null &&
              adminPasswordFromDialog.isNotEmpty) {
            // Sign in with admin credentials
            await FirebaseAuth.instance
                .signInWithEmailAndPassword(
                  email: adminEmail,
                  password: adminPasswordFromDialog,
                )
                .timeout(const Duration(seconds: 10));

            setState(() {
              _isLoading = false;
            });

            showSlideFromLeftSnackBar(
              context,
              'Employee Added Successfully! Admin logged back in.',
              'success',
            );

            // Log
            String email = FirebaseAuth.instance.currentUser!.email!;
            await addLogEntry(
              hotelId: widget.href,
              userEmail: email,
              action:
                  "New employee created (${role.toString().toLowerCase()} -> ${name.toLowerCase()}).",
              tableNumber: "",
              sessionId: "",
            );

            return true;
          } else {
            // User cancelled or didn't provide password
            setState(() {
              _isLoading = false;
            });

            showBounceSnackBar(
              context,
              'Employee Added but could not log back in as admin.',
              'warning',
            );

            // Log
            String email = FirebaseAuth.instance.currentUser!.email!;
            await addLogEntry(
              hotelId: widget.href,
              userEmail: email,
              action:
                  "New employee created (${role.toString().toLowerCase()} -> ${name.toLowerCase()}).",
              tableNumber: "",
              sessionId: "",
            );

            return false;
          }
        } catch (reAuthError) {
          setState(() {
            _isLoading = false;
          });

          showBounceSnackBar(
            context,
            'Failed to log back in. Please log in again manually.',
            'fail',
          );

          return false;
        }
      }

      setState(() {
        _isLoading = false;
      });

      return true;
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'An error occurred';
      if (e.code == 'email-already-in-use') {
        errorMessage = "The email is already in use by another account.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is not valid.";
      } else if (e.code == 'weak-password') {
        errorMessage = "The password is too weak.";
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = "Email/password accounts are not enabled.";
      }

      showBounceSnackBar(context, errorMessage, "fail");
      return false;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      showBounceSnackBar(
          context, "An unknown error occurred. Please try again.", "fail");
      return false;
    }
  }

  Future<String?> _showReAuthenticationDialog(
      BuildContext context, String adminEmail) {
    TextEditingController passwordController = TextEditingController();
    bool isReAuthLoading = false;

    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: outer_background().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.security,
                      color: outer_background(),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Verify Your Identity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: outer_background().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: outer_background(),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please enter your admin password to remain logged in.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Admin Email: $adminEmail',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      enabled: !isReAuthLoading,
                      decoration: InputDecoration(
                        labelText: 'Enter your password',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        hintText: 'Your admin password',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: outer_background(),
                          size: 20,
                        ),
                        fillColor: Colors.grey[50],
                        filled: true,
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
                          borderSide: BorderSide(
                            color: outer_background(),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton.icon(
                  onPressed: isReAuthLoading
                      ? null
                      : () async {
                          if (passwordController.text.isEmpty) {
                            showBounceSnackBar(
                              context,
                              'Please enter your password',
                              'fail',
                            );
                            return;
                          }

                          setState(() {
                            isReAuthLoading = true;
                          });

                          try {
                            // Verify password by attempting sign in
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                  email: adminEmail,
                                  password: passwordController.text,
                                )
                                .timeout(const Duration(seconds: 10));

                            // If sign in successful, return the password
                            if (mounted) {
                              Navigator.pop(
                                  dialogContext, passwordController.text);
                            }
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              isReAuthLoading = false;
                            });

                            String errorMsg = 'Authentication failed';
                            if (e.code == 'wrong-password') {
                              errorMsg =
                                  'Incorrect password. Please try again.';
                            } else if (e.code == 'user-not-found') {
                              errorMsg = 'Admin account not found.';
                            }

                            showBounceSnackBar(context, errorMsg, 'fail');
                          } catch (e) {
                            setState(() {
                              isReAuthLoading = false;
                            });

                            showBounceSnackBar(
                              context,
                              'Error verifying identity. Please try again.',
                              'fail',
                            );
                          }
                        },
                  icon: isReAuthLoading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(Icons.verified, size: 18),
                  label: Text(
                    isReAuthLoading ? 'Verifying...' : 'Verify & Login',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: outer_background(),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;
    final hotelref = widget.href;

    final horizontalPadding = isTablet ? 32.0 : 16.0;
    final maxWidth = isTablet ? 800.0 : double.infinity;
    final fieldSpacing = isLandscape ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: inner_background(),
      appBar: AppBar(
        backgroundColor: outer_background(),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: inner_background(),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Employee Details',
          style: TextStyle(
            color: inner_background(),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          ProfileButton(
              context: context, hotelref: widget.href, isTablet: isTablet)
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isLandscape ? 16 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            outer_background(),
                            outer_background().withOpacity(0.8)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person_add,
                              color: inner_background(),
                              size: isTablet ? 32 : 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add New Employee",
                                  style: TextStyle(
                                    fontSize: isTablet ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: inner_background(),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Fill in the details to register a new team member",
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: inner_background().withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isLandscape ? 24 : 32),

                    // Form Section
                    Container(
                      padding: EdgeInsets.all(isTablet ? 32 : 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEnhancedFormField(
                              label: 'Name',
                              icon: Icons.person,
                              isTablet: isTablet,
                              child:
                                  _buildTextField('Enter full name', (value) {
                                _name = value;
                              }),
                            ),
                            SizedBox(height: fieldSpacing),
                            _buildEnhancedFormField(
                              label: 'Email',
                              icon: Icons.email,
                              isTablet: isTablet,
                              child: TextFormField(
                                controller: userEmailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Enter email address',
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  hintText: 'example@hotel.com',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  fillColor: Colors.grey[50],
                                  filled: true,
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: outer_background(),
                                    size: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: outer_background(),
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                validator: _validateEmail,
                              ),
                            ),
                            SizedBox(height: fieldSpacing),
                            _buildEnhancedFormField(
                              label: 'Password',
                              icon: Icons.lock,
                              isTablet: isTablet,
                              child: _buildTextField(
                                "Create password",
                                (val) => _password = val,
                                obscureText: !_isPasswordVisible,
                              ),
                            ),
                            SizedBox(height: fieldSpacing),
                            _buildEnhancedFormField(
                              label: 'Role',
                              icon: Icons.work,
                              isTablet: isTablet,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedRole,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: outer_background(),
                                    ),
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                    dropdownColor: Colors.white,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedRole = newValue!;
                                      });
                                    },
                                    items: ["Manager", "Cook", "Cashier"]
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Row(
                                          children: [
                                            Icon(
                                              _getRoleIcon(value),
                                              size: 20,
                                              color: outer_background(),
                                            ),
                                            SizedBox(width: 12),
                                            Text(value),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: isLandscape ? 24 : 32),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: outer_background(),
                                  foregroundColor: inner_background(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  shadowColor:
                                      outer_background().withOpacity(0.3),
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          print('Name: $_name');
                                          print(
                                              'Email: ${userEmailController.text}');
                                          print('Password: $_password');
                                          print('Role: $selectedRole');

                                          bool res = await registerUser(
                                            context,
                                            userEmailController.text,
                                            _password,
                                            _name,
                                            selectedRole,
                                          );

                                          if (res && mounted) {
                                            await Future.delayed(
                                                Duration(seconds: 2));
                                            Navigator.pop(context);
                                          }
                                        }
                                      },
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: inner_background(),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person_add, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Register Employee',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) CustomLoader(message: "Creating employee account..."),
        ],
      ),
    );
  }

  Widget _buildEnhancedFormField({
    required String label,
    required IconData icon,
    required Widget child,
    required bool isTablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: outer_background().withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 16,
                color: outer_background(),
              ),
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        child,
      ],
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Manager':
        return Icons.manage_accounts;
      case 'Cook':
        return Icons.restaurant;
      case 'Cashier':
        return Icons.point_of_sale;
      default:
        return Icons.work;
    }
  }

  Widget _buildTextField(
    String labelText,
    Function(String) onChanged, {
    bool obscureText = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        suffixIcon: labelText.toLowerCase().contains("password")
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: outer_background(),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        prefixIcon: labelText.toLowerCase().contains("password")
            ? Icon(Icons.lock_outline, color: outer_background(), size: 20)
            : Icon(Icons.person_outline, color: outer_background(), size: 20),
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        hintText: labelText.toLowerCase().contains("password")
            ? "Min. 6 characters"
            : null,
        hintStyle: TextStyle(color: Colors.grey[400]),
        fillColor: Colors.grey[50],
        filled: true,
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
          borderSide: BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      obscureText: obscureText,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter ${labelText.toLowerCase()}';
        }

        if (obscureText && value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }
}
