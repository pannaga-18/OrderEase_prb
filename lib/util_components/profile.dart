import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/LandingScreen/home_screen.dart';
import 'package:orderease/main.dart';
import 'package:orderease/util_components/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String hotelId;
  final String profileImageUrl;

  final Map<String, dynamic>? additionalData;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.hotelId,
    this.profileImageUrl = '',
    this.additionalData,
  });

  factory UserProfile.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc, String hotelId) {
    final data = doc.data();
    return UserProfile(
      userId: doc.id,
      name: data?['name'] ?? data?['admin_name'] ?? 'User',
      email: data?['email'] ?? data?['admin_email'] ?? 'N/A',
      phone: data?['phone'] ?? data?['phone_number'] ?? 'N/A',
      role: data?['role'] ?? 'User',
      hotelId: hotelId ?? 'N/A',
      profileImageUrl: data?['profile_image_url'] ?? '',
      additionalData: data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'hotelId': hotelId,
      'profileImageUrl': profileImageUrl,
    };
  }
}

class ProfileView extends StatefulWidget {
  final String userId;
  final VoidCallback onCancel;
  final VoidCallback onLogout;
  final bool isCurrentUser;
  final String href;

  const ProfileView({
    Key? key,
    required this.userId,
    required this.onCancel,
    required this.onLogout,
    this.isCurrentUser = false,
    required this.href,
  }) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Future<UserProfile> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _fetchUserProfile();
  }

  Future<UserProfile> _fetchUserProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Hotels')
          .doc(widget.href)
          .collection("Users")
          .doc(widget.userId)
          .get()
          .timeout(const Duration(seconds: 10));

      final hotelId = widget.href.split("_")[0];

      if (doc.exists) {
        return UserProfile.fromFirestore(doc, hotelId);
      }

      // If not found in Users, try other collections
      throw Exception('User not found');
    } on TimeoutException {
      throw Exception('Failed to fetch user profile. Please try again.');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await addLogEntry(
                  hotelId: widget.href,
                  userEmail: widget.userId,
                  action: "Logged Out",
                  tableNumber: "", // stored as null in Firestore
                  sessionId: "",
                );
                Navigator.pop(context);

                try {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('email');
                  await prefs.remove('hotel_id');
                  await FirebaseAuth.instance.signOut();

                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => OrderEaseApp()),
                      (Route<dynamic> route) => false,
                    );
                  }

                  /// 🔥 SHOW SNACKBAR SAFELY AFTER NAVIGATION
                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   showStatusSnackBar(
                  //       context, // explained below
                  //       "User logged out successfully!",
                  //       "success");
                  // });
                } catch (e) {
                  if (mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showBounceSnackBar(
                          context, "Error logging out: $e", "fail");
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        title: Text(
          'User Profile',
          style:
              TextStyle(color: inner_background(), fontWeight: FontWeight.w600),
        ),
        backgroundColor: outer_background(),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
          color: inner_background(),
        ),
      ),
      backgroundColor: inner_background(),
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomLoader(message: 'Loading profile details...');
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _userProfileFuture = _fetchUserProfile();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: outer_background(),
                      foregroundColor: inner_background(),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No profile data available'),
            );
          }

          final profile = snapshot.data!;
          return _buildProfileContent(context, profile);
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  outer_background(),
                  outer_background().withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              child: Column(
                children: [
                  // Profile Avatar
                  Container(
                    width: isTablet ? 140 : 120,
                    height: isTablet ? 140 : 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: profile.profileImageUrl.isNotEmpty
                          ? Image.network(
                              profile.profileImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar(profile.name);
                              },
                            )
                          : _buildDefaultAvatar(profile.name),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    profile.name,
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      profile.role,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile Details
          Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            child: Column(
              children: [
                // const SizedBox(height: 16),
                // _buildProfileInfoCard(
                //   icon: Icons.phone_outlined,
                //   label: 'Phone',
                //   value: profile.phone,
                //   isTablet: isTablet,
                // ),

                _buildProfileInfoCard(
                  icon: Icons.badge_outlined,
                  label: 'Email',
                  value: profile.userId,
                  isTablet: isTablet,
                  isCopyable: true,
                ),
                const SizedBox(height: 16),
                _buildProfileInfoCard(
                  icon: Icons.business_outlined,
                  label: 'Hotel ID',
                  value: profile.hotelId,
                  isTablet: isTablet,
                ),

                // Additional Data if available
                if (profile.additionalData != null)
                  ...profile.additionalData!.entries
                      .where((e) => ![
                            'name',
                            'email',
                            'phone',
                            'role',
                            'hotel_id',
                            'created_at',
                            'profile_image_url',
                            'admin_name',
                            'admin_email',
                            'phone_number'
                          ].contains(e.key))
                      .map((e) => Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildProfileInfoCard(
                                icon: Icons.info_outlined,
                                label: _formatLabel(e.key),
                                value: e.value.toString(),
                                isTablet: isTablet,
                              ),
                            ],
                          ))
                      .toList(),

                const SizedBox(height: 32),

                // Action Buttons
                if (widget.isCurrentUser)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: widget.onCancel,
                          icon: const Icon(Icons.close),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: outer_background(),
                            side:
                                BorderSide(color: outer_background(), width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: outer_background(),
                        side: BorderSide(color: outer_background(), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      color: outer_background(),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isTablet,
    bool isCopyable = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 50 : 44,
            height: isTablet ? 50 : 44,
            decoration: BoxDecoration(
              color: outer_background().withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: outer_background(),
              size: isTablet ? 24 : 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          if (isCopyable)
            IconButton(
              icon: Icon(Icons.copy, color: outer_background(), size: 20),
              onPressed: () {
                // Copy to clipboard functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatLabel(String key) {
    return key.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

// // Dialog Widget to show profile
// void showUserProfileDialog(
//   BuildContext context, {
//   required String userId,
//   VoidCallback? onLogout,
//   bool isCurrentUser = false,
// }) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: ProfileView(
//         userId: userId,
//         isCurrentUser: isCurrentUser,
//         onCancel: () => Navigator.pop(context),
//         onLogout: onLogout ?? () => Navigator.pop(context),
//       ),
//     ),
//   );
// }
