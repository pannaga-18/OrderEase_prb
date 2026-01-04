import 'package:flutter/material.dart';
import 'package:orderease/util_components/util.dart';


class InvalidQRScreen extends StatefulWidget {
  const InvalidQRScreen({Key? key}) : super(key: key);

  @override
  State<InvalidQRScreen> createState() => _InvalidQRScreenState();
}

class _InvalidQRScreenState extends State<InvalidQRScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeTablet = screenWidth > 900;

    double getResponsiveFontSize(double mobile, double tablet, double large) {
      if (isLargeTablet) return large;
      if (isTablet) return tablet;
      return mobile;
    }

    double getResponsivePadding(double mobile, double tablet) {
      return isTablet ? tablet : mobile;
    }

    return Scaffold(
      backgroundColor: inner_background(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: getResponsivePadding(24.0, 48.0),
              vertical: getResponsivePadding(32.0, 48.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Error Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: isTablet ? 200.0 : 160.0,
                    height: isTablet ? 200.0 : 160.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.red[400]!,
                          Colors.red[600]!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.qr_code_scanner,
                      size: isTablet ? 100.0 : 80.0,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: getResponsivePadding(40.0, 56.0)),

                // Error Icon with Cross
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.all(getResponsivePadding(16.0, 20.0)),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red[300]!,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.close,
                      size: isTablet ? 60.0 : 48.0,
                      color: Colors.red[600],
                    ),
                  ),
                ),

                SizedBox(height: getResponsivePadding(32.0, 40.0)),

                // Main Error Message
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Invalid QR Code',
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(32.0, 40.0, 48.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: getResponsivePadding(16.0, 20.0)),

                // Description
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getResponsivePadding(16.0, 32.0),
                    ),
                    child: Text(
                      'The QR code you scanned is not valid or has expired.',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(16.0, 18.0, 20.0),
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(height: getResponsivePadding(40.0, 56.0)),

                // Information Card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: isLargeTablet ? 600 : 500,
                    ),
                    padding: EdgeInsets.all(getResponsivePadding(24.0, 32.0)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.red[200]!,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.red[600],
                              size: isTablet ? 28.0 : 24.0,
                            ),
                            SizedBox(width: 12.0),
                            Text(
                              'Possible Reasons',
                              style: TextStyle(
                                fontSize:
                                    getResponsiveFontSize(18.0, 20.0, 22.0),
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: getResponsivePadding(20.0, 24.0)),
                        _buildReasonItem(
                          icon: Icons.link_off,
                          text: 'The QR code link is incorrect or broken',
                          isTablet: isTablet,
                          getResponsiveFontSize: getResponsiveFontSize,
                        ),
                        SizedBox(height: getResponsivePadding(12.0, 16.0)),
                        _buildReasonItem(
                          icon: Icons.access_time,
                          text: 'The QR code has expired',
                          isTablet: isTablet,
                          getResponsiveFontSize: getResponsiveFontSize,
                        ),
                        SizedBox(height: getResponsivePadding(12.0, 16.0)),
                        _buildReasonItem(
                          icon: Icons.restaurant,
                          text: 'The restaurant is no longer available',
                          isTablet: isTablet,
                          getResponsiveFontSize: getResponsiveFontSize,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: getResponsivePadding(40.0, 56.0)),

                // Action Button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: isLargeTablet ? 400 : 350,
                    ),
                    height: isTablet ? 65.0 : 56.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          outer_background(),
                          outer_background().withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: outer_background(),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: isTablet ? 26.0 : 22.0,
                              ),
                              SizedBox(width: 12.0),
                              Text(
                                'Go Back',
                                style: TextStyle(
                                  fontSize:
                                      getResponsiveFontSize(18.0, 20.0, 22.0),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: getResponsivePadding(24.0, 32.0)),

                // Help Text
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: TextButton.icon(
                    onPressed: () {
                      // Add contact support logic here
                      _showContactSupportDialog(
                          context, isTablet, getResponsiveFontSize);
                    },
                    icon: Icon(
                      Icons.help_outline,
                      color: outer_background(),
                      size: isTablet ? 24.0 : 20.0,
                    ),
                    label: Text(
                      'Need Help? Contact Support',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(14.0, 16.0, 18.0),
                        color: outer_background(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReasonItem({
    required IconData icon,
    required String text,
    required bool isTablet,
    required Function getResponsiveFontSize,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.red[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isTablet ? 20.0 : 18.0,
            color: Colors.red[600],
          ),
        ),
        SizedBox(width: 12.0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: getResponsiveFontSize(14.0, 16.0, 17.0),
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showContactSupportDialog(
    BuildContext context,
    bool isTablet,
    Function getResponsiveFontSize,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.support_agent,
                color: outer_background(),
                size: isTablet ? 32.0 : 28.0,
              ),
              SizedBox(width: 12.0),
              Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(20.0, 22.0, 24.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please ask the restaurant staff for assistance or request a new QR code.',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(14.0, 16.0, 17.0),
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue[200]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue[700],
                      size: isTablet ? 24.0 : 20.0,
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        'Try scanning the QR code again',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(13.0, 14.0, 15.0),
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(16.0, 18.0, 19.0),
                  fontWeight: FontWeight.bold,
                  color: outer_background(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
