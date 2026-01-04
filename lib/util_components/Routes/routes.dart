import 'package:flutter/material.dart';
import 'package:orderease/Website_Feature/Customer/customer_view.dart';


Route<dynamic> _webRoutes(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '');

  if (uri.pathSegments.length == 3 &&
      uri.pathSegments[0] == 'table') {
    return MaterialPageRoute(
      builder: (_) => CustomerFoodStatusScreen(
        hotelId: uri.pathSegments[1],
        tableId: uri.pathSegments[2],
      ),
    );
  }

  return MaterialPageRoute(
    builder: (_) => const Scaffold(
      body: Center(child: Text('Invalid QR')),
    ),
  );
}
