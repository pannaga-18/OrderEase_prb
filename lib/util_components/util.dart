import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/main.dart';
import 'package:orderease/util_components/QR_Code/qr_code.dart';
import 'package:orderease/util_components/profile.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:audioplayers/audioplayers.dart';

Color outer_background() {
  return Color(0xFF397ABC);
}

Color inner_background() {
  return Color(0xFFF7FBFF);
}

Color dark_outer_background() {
  return Color(0xFF2F6AA5);
}

Color light_variant() {
  print("light variant called");
  return Color(0xFFE8F0F8);
}

Color statusBlocked() => const Color(0xFFDA4F49); // Soft red
Color statusBlockedDark() => const Color(0xFFC0392B); // Deep red
Color statusBlockedLight() => const Color(0xFFFFE5E5); // Light red bg

Color statusVacant() => const Color(0xFF2ECC71); // Soft green
Color statusVacantDark() => const Color(0xFF27AE60); // Deep green
Color statusVacantLight() => const Color(0xFFE8F9F0); // Light green bg

Color lightenColor(Color color, [double amount = 0.2]) {
  int r = (color.red + (255 - color.red) * amount).round();
  int g = (color.green + (255 - color.green) * amount).round();
  int b = (color.blue + (255 - color.blue) * amount).round();
  return Color.fromARGB(color.alpha, r, g, b);
}

TextStyle font(double n) {
  return TextStyle(fontSize: n);
}

Future<void> playSound(String status) async {
  final _player = AudioPlayer();

  switch (status) {
    case "success":
      await _player.play(AssetSource('tones/success.mp3'));
      break;
    case "fail":
      await _player.play(AssetSource('tones/error1.mp3'));
      break;
    case "warning":
      await _player.play(AssetSource('tones/error.mp3'));
      break;
    case "info":
      await _player.play(AssetSource('tones/info.mp3'));
      break;
  }
}

Map<String, dynamic> getStatusColor(String status) {
  IconData iconData;
  Color backgroundColor;
  switch (status.toLowerCase()) {
    case 'success':
      iconData = Icons.check_circle_outline;
      backgroundColor = Colors.green;
      break;
    case 'fail':
      iconData = Icons.error_outline;
      backgroundColor = Colors.red;
      break;
    case 'warning':
      iconData = Icons.warning_amber_outlined;
      backgroundColor = Colors.orangeAccent;
      break;
    case 'info':
    default:
      iconData = Icons.info_outline;
      backgroundColor = lightenColor(Color(0xFF397ABC), 0.3);
      break;
  }
  return {"iconData": iconData, "bgcolor": backgroundColor};
}

void showStatusSnackBar(BuildContext context, String message, String status) {
  // Set icon and color based on status
  IconData iconData;
  Color backgroundColor;

  final col_bg_data = getStatusColor(status);

  iconData = col_bg_data['iconData'];
  backgroundColor = col_bg_data["bgcolor"];

  // Play sound immediately
  playSound(status);

  final snackBar = SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 3),

    /// Animated Container for fade + slide effects
    content: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },

      /// The child UI
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: backgroundColor!.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(iconData, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);

  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(
  //     content: Row(
  //       children: [
  //         Icon(iconData, color: Colors.white),
  //         SizedBox(width: 8),
  //         Expanded(
  //           child: Text(
  //             message,
  //             style: TextStyle(color: Colors.white),
  //           ),
  //         ),
  //       ],
  //     ),
  //     behavior: SnackBarBehavior.floating,
  //     backgroundColor: backgroundColor,
  //   ),
  // );
}

// Custom Loader Widget
class CustomLoader extends StatelessWidget {
  final String message;
  // final String imagePath; // Your logo path
  const CustomLoader({
    super.key,
    required this.message,
    // required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = "assets/images/cook_icon_sgs.png";
    return Stack(
      children: [
        // Dimmed background
        Container(
          color: Colors.black.withOpacity(0.5),
        ),

        // Center loading box
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            width: 230,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circular loader
                    SizedBox(
                      height: 44,
                      width: 44,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: outer_background(),
                      ),
                    ),

                    // Your logo inside loader
                    CircleAvatar(
                      backgroundImage: AssetImage(imagePath),
                      radius: 19,
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    decoration: TextDecoration.none,
                  ),
                ),

                SizedBox(height: 16),

                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pop(context);
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: outer_background(),
                //     foregroundColor: Colors.white,
                //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //   ),
                //   child: Text("Dismiss"),
                // )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Method to show the CustomLoader
Future<void> showLoadingDialog(
  BuildContext context, {
  required String message,
  // required String imagePath,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) => CustomLoader(
      message: message,
      // imagePath: imagePath,
    ),
  );
}

// Profile Button
Widget ProfileButton(
    {required BuildContext context,
    required String hotelref,
    required bool isTablet}) {
  return Padding(
    padding: EdgeInsets.only(right: isTablet ? 16 : 8),
    child: IconButton(
      onPressed: () async {
        // _toggleAdminInfoDialog(context);
        print("Profile Icon Pressed");

        String email = FirebaseAuth.instance.currentUser!.email.toString();
        print(email);
        print(hotelref);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileView(
              userId: FirebaseAuth.instance.currentUser!.email!,
              isCurrentUser: true,
              href: hotelref,
              onCancel: () => Navigator.pop(context),
              onLogout: () {},
            ),
          ),
        );
      },
      icon: Icon(
        Icons.account_circle,
        size: isTablet ? 36 : 30,
        color: inner_background(),
      ),
      tooltip: 'Account Info',
    ),
  );
}

// Dynamic Loading Effect for buttons
List<Widget> getCircularProgressIndicator() {
  return [
    SizedBox(width: 16),
    SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(inner_background()),
        strokeWidth: 2,
      ),
    ),
  ];
}

// Exit triger Haptic
Future<void> triggerExitHaptic() async {
  try {
    await HapticFeedback.heavyImpact();
    await Future.delayed(Duration(milliseconds: 120));
    await HapticFeedback.vibrate();
  } catch (e) {
    print("Haptic error: $e");
  }
}

// Dialog Window
Future<bool> showExitDialog(BuildContext context) async {
  // 🔔 Trigger small haptic vibration when the dialog opens
  WidgetsBinding.instance.addPostFrameCallback((_) {
    triggerExitHaptic();
  });

  return await showDialog(
    context: context,
    barrierDismissible: false, // prevent closing by tapping outside
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                outer_background(), // Your custom function
                inner_background(), // Your custom function
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔵 App Logo – replace placeholder
              // 🔵 App Logo – perfectly circular
              CircleAvatar(
                radius: 40,
                backgroundColor: inner_background(),
                child: ClipOval(
                  child: Image.asset(
                    "assets/images/cook_icon_sgs.png",
                    fit: BoxFit.cover,
                    width: 75,
                    height: 75,
                  ),
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Exit Application?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "Are you sure you want to close the application?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ❌ CANCEL
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: outer_background(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      child: Text("No"),
                    ),
                  ),

                  // ✔ EXIT
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      child: Text("Yes"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  ).then((value) => value ?? false);
}

// Advanced Snackbars
void showSlideFromLeftSnackBar(
    BuildContext context, String message, String status) {
  IconData iconData;
  Color backgroundColor;

  final col_bg_data = getStatusColor(status);

  iconData = col_bg_data['iconData'];
  backgroundColor = col_bg_data["bgcolor"];

  // Play sound immediately
  playSound(status);

  final controller = AnimationController(
    vsync: ScaffoldMessenger.of(context),
    duration: Duration(milliseconds: 500),
  );

  final animation = Tween<Offset>(
    begin: Offset(-1.0, 0.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: Curves.easeOut,
  ));

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(12),
        content: SlideTransition(
          position: animation,
          child: Row(
            children: [
              Icon(iconData, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  controller.forward();
}

void showBounceSnackBar(BuildContext context, String message, String status) {
  IconData iconData;
  Color backgroundColor;

  final col_bg_data = getStatusColor(status);

  iconData = col_bg_data['iconData'];
  backgroundColor = col_bg_data["bgcolor"];

  // Play sound immediately
  playSound(status);

  final controller = AnimationController(
    vsync: ScaffoldMessenger.of(context),
    duration: Duration(milliseconds: 600),
  );

  final animation = CurvedAnimation(
    parent: controller,
    curve: Curves.elasticOut,
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(12),
        content: ScaleTransition(
          scale: animation,
          child: Row(
            children: [
              Icon(iconData, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  controller.forward();
}

// Show QR

// 1) Bill No for cashier completed view side to show QR
// 2) Session_table_id for Manager side (digitized bill and digital payment) and (Digitized bill + feedback) after settlement process.

void showQR(BuildContext context, String hotelId, String table_option, int bill_no, String qr_status, String session_table_id, bool modal_status) {
  showModalBottomSheet(
    backgroundColor: inner_background(),
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => TableQRWidget(
      hotelId: hotelId,
      tableId: table_option,
      bill_no: bill_no,
      qr_status: qr_status,
      session_table_id: session_table_id,
      modal_status: modal_status,
    ),
  );
}
