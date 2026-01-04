
// // For Web Application

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:orderease/Settlements/Bill_Print/print_bill.dart';
// import 'package:orderease/Website_Feature/Customer/customer_bill_view.dart';
// import 'package:orderease/Website_Feature/Customer/customer_view.dart';
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:orderease/LandingScreen/home_screen.dart';
// import 'package:orderease/Website_Feature/web_home_page.dart';
// import 'package:orderease/util_components/QR_Code/invaild_qr.dart';
// import 'package:orderease/util_components/util.dart';
// import 'package:orderease/firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding
//       .ensureInitialized(); // Ensure binding is initialized before Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   setUrlStrategy(PathUrlStrategy());
//   runApp(const OrderEaseWebApp());
// }

// class OrderEaseWebApp extends StatelessWidget {
//   const OrderEaseWebApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       onGenerateRoute: (settings) {
//         final uri = Uri.parse(settings.name ?? "");
//         final uri_path_length = uri.pathSegments.length;
//         final uri_path_list = uri.pathSegments;
//         final uri_string = uri.toString();
//         print("uri ${uri.toString().length}");

//         // Home Screen
//         if (uri_string == "/" ||
//             uri_string == "https://orderease-39f46.web.app/") {
//           return MaterialPageRoute(
//             builder: (_) => HomeScreen(),
//           );
//         }

//         // Food Review for Customers
//         else if (uri_path_length == 3 && uri_path_list[0] == 'table') {
//           final hotelId = uri.pathSegments[1];
//           final tableId = uri.pathSegments[2];

//           return MaterialPageRoute(
//             builder: (_) => CustomerFoodStatusScreen(
//               hotelId: hotelId,
//               tableId: tableId,
//             ),
//           );
//         } else if (uri_path_length == 3 && uri_path_list[0] == 'bill') {
//           final hotelId = uri.pathSegments[1];
//           final billNo = uri.pathSegments[2];
//           print(hotelId);
//           print(billNo);
//           print("BillPATHPARA");

//           return MaterialPageRoute(
//             builder: (_) => BillPreviewLoaderScreen(
//               hotelId: hotelId,
//               billNo: billNo,
//             ),
//           );
//         } else {
//           return MaterialPageRoute(builder: (_) => InvalidQRScreen());
//         }
//       },
//     );
//   }
// }

// For Web Application

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderease/Settlements/Bill_Print/print_bill.dart';
import 'package:orderease/Website_Feature/Customer/customer_bill_view.dart';
import 'package:orderease/Website_Feature/Customer/customer_view.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:orderease/LandingScreen/home_screen.dart';
import 'package:orderease/Website_Feature/web_home_page.dart';
import 'package:orderease/util_components/QR_Code/invaild_qr.dart';
import '../util_components/Encryption__Helper/encryption_helper.dart';
import 'package:orderease/util_components/util.dart';
import 'package:orderease/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setUrlStrategy(PathUrlStrategy());
  runApp(const OrderEaseWebApp());
}

class OrderEaseWebApp extends StatelessWidget {
  const OrderEaseWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? "");
        final uri_path_length = uri.pathSegments.length;
        final uri_path_list = uri.pathSegments;
        final uri_string = uri.toString();
        print("uri ${uri.toString()}");

        // Home Screen
        if (uri_string == "/" ||
            uri_string == "https://orderease-39f46.web.app/") {
          return MaterialPageRoute(
            builder: (_) => HomeScreen(),
          );
        }

        // 🔐 SECURE ENCRYPTED ROUTES
        // Format: /s/food/{encrypted_token} or /s/bill/{encrypted_token}
        else if (uri_path_length == 3 && uri_path_list[0] == 's') {
          final type = uri_path_list[1]; // 'food' or 'bill'
          final encryptedToken = uri_path_list[2];

          return MaterialPageRoute(
            builder: (_) => SecureRouteHandler(
              encryptedToken: encryptedToken,
              type: type,
            ),
          );
        }

        // 🔓 LEGACY UNENCRYPTED ROUTES (for backward compatibility)
        // Food Status - /table/{hotelId}/{tableId}
        else if (uri_path_length == 3 && uri_path_list[0] == 'table') {
          final hotelId = uri.pathSegments[1];
          final tableId = uri.pathSegments[2];

          print("⚠️ Warning: Using unencrypted URL for food status");
          
          return MaterialPageRoute(
            builder: (_) => CustomerFoodStatusScreen(
              hotelId: hotelId,
              tableId: tableId,
            ),
          );
        }

        // Bill View - /bill/{hotelId}/{billNo}
        else if (uri_path_length == 3 && uri_path_list[0] == 'bill') {
          final hotelId = uri.pathSegments[1];
          final billNo = uri.pathSegments[2];
          
          print("⚠️ Warning: Using unencrypted URL for bill");
          print("Hotel: $hotelId, Bill: $billNo");

          return MaterialPageRoute(
            builder: (_) => BillPreviewLoaderScreen(
              hotelId: hotelId,
              billNo: billNo,
              session_table_id: "",
            ),
          );
        }

        // Invalid Route
        else {
          print("❌ Invalid route: $uri_string");
          return MaterialPageRoute(builder: (_) => InvalidQRScreen());
        }
      },
    );
  }
}

// 🔐 Secure Route Handler
class SecureRouteHandler extends StatefulWidget {
  final String encryptedToken;
  final String type; // 'food' or 'bill'

  const SecureRouteHandler({
    Key? key,
    required this.encryptedToken,
    required this.type,
  }) : super(key: key);

  @override
  State<SecureRouteHandler> createState() => _SecureRouteHandlerState();
}

class _SecureRouteHandlerState extends State<SecureRouteHandler> {
  bool _isLoading = true;
  bool _isValid = false;
  Map<String, dynamic>? _decodedData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _decodeAndValidate();
  }

  Future<void> _decodeAndValidate() async {
    try {
      print("🔓 Decoding encrypted token: ${widget.encryptedToken}");
      
      // Decode the encrypted token
      final data = EncryptionHelper.decodeData(widget.encryptedToken);

      if (data == null) {
        setState(() {
          _isLoading = false;
          _isValid = false;
          _errorMessage = "Invalid or corrupted QR code";
        });
        return;
      }

      print("✅ Token decoded successfully: $data");

      // Validate token expiry (optional - 24 hours validity)
      final timestamp = data['ts'] as int?;
      
      // Validate type matches
      final status = data['s'] as String;
      final expectedType = (status == 'food_status') ? 'food' : 'bill';

      if (timestamp != null && expectedType == "bill") {
        final createdAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        final difference = now.difference(createdAt);

        if (difference.inHours > 24) {
          setState(() {
            _isLoading = false;
            _isValid = false;
            _errorMessage = "QR code has expired (valid for 24 hours)";
          });
          return;
        }
      }

      // Validate required fields
      if (!data.containsKey('h') || !data.containsKey('t') || !data.containsKey('s')) {
        setState(() {
          _isLoading = false;
          _isValid = false;
          _errorMessage = "Invalid QR code format";
        });
        return;
      }

  
      
      if (widget.type != expectedType) {
        setState(() {
          _isLoading = false;
          _isValid = false;
          _errorMessage = "QR code type mismatch";
        });
        return;
      }

      setState(() {
        _decodedData = data;
        _isValid = true;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error decoding token: $e");
      setState(() {
        _isLoading = false;
        _isValid = false;
        _errorMessage = "Failed to decode QR code: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: inner_background(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(outer_background()),
              ),
              SizedBox(height: 24),
              Text(
                'Verifying QR code...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isValid || _decodedData == null) {
      return InvalidQRScreen();
    }

    // Extract decoded data
    final hotelId = _decodedData!['h'] as String;
    final tableId = _decodedData!['t'] as String;
    final billNo = _decodedData!['b'] as int;
    final status = _decodedData!['s'] as String;
    final session_table_id = _decodedData!['sbt'] as String;

    print("✅ Routing to ${widget.type} with Hotel: $hotelId, Table: $tableId, Bill: $billNo, session_table_id: $session_table_id");

    // Navigate to appropriate screen based on type
    if (widget.type == 'food') {
      return CustomerFoodStatusScreen(
        hotelId: hotelId,
        tableId: tableId,
      );
    } else if (widget.type == 'bill') {
      return BillPreviewLoaderScreen(
        hotelId: hotelId,
        billNo: billNo.toString(),
        session_table_id: session_table_id,
      );
    } else {
      return InvalidQRScreen();
    }
  }
}