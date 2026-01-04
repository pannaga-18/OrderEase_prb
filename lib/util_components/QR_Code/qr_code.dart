// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:orderease/util_components/util.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class TableQRWidget extends StatelessWidget {
//   final String hotelId;
//   final String tableId;
//   final int bill_no;
//   final String qr_status;

//   const TableQRWidget({
//     Key? key,
//     required this.hotelId,
//     required this.tableId,
//     required this.bill_no,
//     required this.qr_status,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final bool isFoodStatus = qr_status == "food_status";

//     final String upperDisplayText =
//         isFoodStatus ? "Order Status QR" : "Bill Download QR";

//     final String bottomDisplayText = isFoodStatus
//         ? "Scan to view live food status"
//         : "Scan to download your bill";

//     final String qrData = isFoodStatus
//         ? "https://orderease-39f46.web.app/table/$hotelId/$tableId"
//         : "https://orderease-39f46.web.app/bill/$hotelId/$bill_no";

//     final imagePath = "assets/images/cook_icon_sgs.png";

//     return Scaffold(
//       backgroundColor: Colors.grey.shade200,
//       appBar: AppBar(
//         title: Column(
//           children: [
//             Container(
//               width: 60,
//               height: 6,
//               decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(2))),
//             ),
//             SizedBox(
//               height: 8,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   backgroundImage: AssetImage(
//                     imagePath,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 6,
//                 ),
//                 Text(upperDisplayText),
//               ],
//             ),
//           ],
//         ),
//         centerTitle: true,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//       ),
//       body: Center(
//         child: Container(
//           width: 300,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 10,
//                 offset: Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 16),

//               /// 🔳 QR CODE
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: QrImageView(
//                   data: qrData,
//                   size: 200,
//                   backgroundColor: Colors.white,
//                 ),
//               ),

//               const SizedBox(height: 12),

//               /// 🪑 TABLE ID
//               Text(
//                 "$tableId".toUpperCase(),
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1.2,
//                 ),
//               ),

//               const SizedBox(height: 12),

//               /// 🎨 TEXTURED BOTTOM PANEL
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 16,
//                   horizontal: 12,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.grey.shade100,
//                       Colors.grey.shade300,
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(16),
//                     bottomRight: Radius.circular(16),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.qr_code_scanner,
//                       size: 28,
//                       color: Colors.grey.shade700,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       bottomDisplayText,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:orderease/util_components/util.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Encryption__Helper/encryption_helper.dart';

class TableQRWidget extends StatelessWidget {
  final String hotelId;
  final String tableId;
  final int bill_no;
  final String qr_status;
  final String session_table_id;
  final bool modal_status;

  const TableQRWidget({
    Key? key,
    required this.hotelId,
    required this.tableId,
    required this.bill_no,
    required this.qr_status,
    required this.session_table_id,
    required this.modal_status
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeTablet = screenWidth > 900;

    double getResponsiveSize(double mobile, double tablet, double large) {
      if (isLargeTablet) return large;
      if (isTablet) return tablet;
      return mobile;
    }

    final bool isFoodStatus = qr_status == "food_status";

    final String upperDisplayText =
        isFoodStatus ? "Order Status QR" : "Bill Download QR";

    final String bottomDisplayText = isFoodStatus
        ? "Scan to view live food status"
        : "Scan to download your bill and share your feedback";

    // 🔐 Generate encrypted QR data
    final String qrData = _generateSecureQRData(isFoodStatus);

    final imagePath = "assets/images/cook_icon_sgs.png";

    return Scaffold(
      backgroundColor: inner_background(),
      appBar: AppBar(
        backgroundColor: (!modal_status) ? outer_background() : inner_background(),
        elevation: 0,
        automaticallyImplyLeading: !modal_status,
        
        toolbarHeight: getResponsiveSize(80.0, 100.0, 120.0),
        iconTheme: IconThemeData(
          color: inner_background()
        ),
        flexibleSpace: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Drag Handle
              if(modal_status)
              Container(
                width: getResponsiveSize(60.0, 80.0, 100.0),
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              SizedBox(height: getResponsiveSize(8.0, 12.0, 16.0)),
              // Logo and Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: getResponsiveSize(20.0, 24.0, 28.0),
                    backgroundImage: AssetImage(imagePath),
                    onBackgroundImageError: (_, __) {},
                  ),
                  SizedBox(width: getResponsiveSize(8.0, 12.0, 16.0)),
                  Text(
                    upperDisplayText,
                    style: TextStyle(
                      fontSize: getResponsiveSize(16.0, 20.0, 24.0),
                      fontWeight: FontWeight.w600,
                      color: (modal_status) ? Colors.black87 : inner_background(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: getResponsiveSize(16.0, 24.0, 32.0),
            vertical: getResponsiveSize(20.0, 24.0, 32.0),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isLargeTablet ? 500 : (isTablet ? 400 : 340),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  getResponsiveSize(16.0, 20.0, 24.0),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: getResponsiveSize(16.0, 20.0, 24.0)),

                  // 🔐 Security Badge
                  // Container(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: getResponsiveSize(12.0, 16.0, 20.0),
                  //     vertical: getResponsiveSize(6.0, 8.0, 10.0),
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: Colors.green.withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(20),
                  //     border: Border.all(
                  //       color: Colors.green.withOpacity(0.3),
                  //       width: 1.5,
                  //     ),
                  //   ),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Icon(
                  //         Icons.verified_user,
                  //         color: Colors.green,
                  //         size: getResponsiveSize(14.0, 16.0, 18.0),
                  //       ),
                  //       SizedBox(width: 6.0),
                  //       Text(
                  //         'Secure QR',
                  //         style: TextStyle(
                  //           fontSize: getResponsiveSize(11.0, 12.0, 13.0),
                  //           fontWeight: FontWeight.w600,
                  //           color: Colors.green.shade700,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // SizedBox(height: getResponsiveSize(16.0, 20.0, 24.0)),

                  // 🔳 QR CODE
                  Container(
                    padding: EdgeInsets.all(
                      getResponsiveSize(16.0, 20.0, 24.0),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: qrData,
                      size: getResponsiveSize(200.0, 260.0, 300.0),
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                  ),

                  SizedBox(height: getResponsiveSize(12.0, 16.0, 20.0)),

                  // 🪑 TABLE ID
                  Text(
                    tableId.toUpperCase(),
                    style: TextStyle(
                      fontSize: getResponsiveSize(20.0, 24.0, 28.0),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey[800],
                    ),
                  ),

                  SizedBox(height: getResponsiveSize(12.0, 16.0, 20.0)),

                  // 🎨 TEXTURED BOTTOM PANEL
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: getResponsiveSize(16.0, 20.0, 24.0),
                      horizontal: getResponsiveSize(12.0, 16.0, 20.0),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.shade100,
                          Colors.grey.shade300,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(
                          getResponsiveSize(16.0, 20.0, 24.0),
                        ),
                        bottomRight: Radius.circular(
                          getResponsiveSize(16.0, 20.0, 24.0),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: getResponsiveSize(28.0, 34.0, 40.0),
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(height: getResponsiveSize(8.0, 10.0, 12.0)),
                        Text(
                          bottomDisplayText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: getResponsiveSize(14.0, 16.0, 18.0),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                            height: 1.3,
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

  /// 🔐 Generate secure encrypted QR data
  String _generateSecureQRData(bool isFoodStatus) {
    final data = {
      'h': hotelId, // hotel
      't': tableId, // table
      'b': bill_no, // bill number
      's': qr_status, // status
      'sbt': session_table_id,
      'ts': DateTime.now().millisecondsSinceEpoch, // timestamp
    };

    print('📦 Original data: $data');

    // Encrypt the data
    final encryptedToken = EncryptionHelper.encodeData(data);

    print('🔐 Encrypted token: $encryptedToken');

    // 🔥 CHANGE THIS FOR YOUR ENVIRONMENT
    // For localhost testing:
    // const String baseUrl = 'http://localhost:64648';

    // For production:
    const String baseUrl = 'https://orderease-39f46.web.app';

    final String url;
    if (isFoodStatus) {
      url = "$baseUrl/s/food/$encryptedToken";
    } else {
      url = "$baseUrl/s/bill/$encryptedToken";
    }

    print('🔗 Generated URL: $url');
    return url;
  }
}
