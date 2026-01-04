import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orderease/Authentication/auth.dart';
import 'dart:async';

import 'package:orderease/main.dart';
import 'package:orderease/util_components/util.dart';

class OrderEaseApp extends StatefulWidget {
  const OrderEaseApp({Key? key}) : super(key: key);

  @override
  State<OrderEaseApp> createState() => _OrderEaseAppState();
}

class _OrderEaseAppState extends State<OrderEaseApp> {
  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // user is already logged in → navigate to dashboard
      print("User is logged in: ${user.email}");
    } else {
      // user is not logged in → go to login screen
      print("No user logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrderEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double> _logoAnimation;
  late Animation<double> _pulseAnimation;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _carouselTimer;

  String _typedText = '';
  int _typeIndex = 0;
  final String _fullText = 'OrderEase';
  Timer? _typingTimer;

  final List<FeatureInfo> _features = [
    FeatureInfo(
      icon: Icons.restaurant_menu,
      title: 'Smart Menu Management',
      description: 'Easily manage your restaurant menu with real-time updates',
    ),
    FeatureInfo(
      icon: Icons.delivery_dining,
      title: 'Fast Order Processing',
      description: 'Streamline orders from kitchen to customer seamlessly',
    ),
    FeatureInfo(
      icon: Icons.analytics,
      title: 'Business Analytics',
      description: 'Track sales, trends, and grow your restaurant business',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _logoController.forward();

    // Start typing animation
    _startTypingAnimation();

    // Auto-scroll carousel
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _features.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _startTypingAnimation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_typeIndex <= _fullText.length) {
        if (mounted) {
          setState(() {
            _typedText = _fullText.substring(0, _typeIndex);
            _typeIndex++;
          });
        }
      } else {
        timer.cancel();
        // Wait 2 seconds then restart
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _typeIndex = 0;
              _typedText = '';
            });
            _startTypingAnimation();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    _carouselTimer?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isTablet = size.width > 600;
    final isSmallDevice = size.width < 360;

    return PopScope(
        canPop: false, // prevents default pop
        onPopInvokedWithResult: (didPop, result) async {
          // If user tries to exit (back button)
          bool exitApp = await showExitDialog(context);

          if (exitApp) {
            SystemNavigator.pop(); // close app
          }
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E88E5),
                  const Color(0xFF1565C0),
                  Colors.blue.shade800,
                ],
              ),
            ),
            child: SafeArea(
              child: isLandscape
                  ? _buildLandscapeLayout(size, isTablet, isSmallDevice)
                  : _buildPortraitLayout(size, isTablet, isSmallDevice),
            ),
          ),
        ));
  }

  Widget _buildPortraitLayout(Size size, bool isTablet, bool isSmallDevice) {
    final logoSize = isTablet ? 180.0 : (isSmallDevice ? 120.0 : 160.0);
    final titleSize = isTablet ? 48.0 : (isSmallDevice ? 32.0 : 42.0);
    final subtitleSize = isTablet ? 20.0 : (isSmallDevice ? 14.0 : 18.0);
    final carouselHeight = isTablet ? 320.0 : (isSmallDevice ? 240.0 : 280.0);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: size.height),
        child: Column(
          children: [
            SizedBox(height: isTablet ? 80 : (isSmallDevice ? 40 : 60)),

            // Logo with animation
            ScaleTransition(
              scale: _logoAnimation,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border:
                            Border.all(color: inner_background(), width: 3.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/cook_icon_sgs.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4CAF50),
                                    Color(0xFF2E7D32)
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.restaurant,
                                size: logoSize * 0.5,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: isTablet ? 50 : (isSmallDevice ? 30 : 40)),

            // Animated typing title
            SizedBox(
              height: isTablet ? 70 : (isSmallDevice ? 50 : 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _typedText,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (_typeIndex <= _fullText.length)
                    Container(
                      width: 3,
                      height: titleSize * 0.95,
                      margin: const EdgeInsets.only(left: 2),
                      color: Colors.white,
                    ),
                ],
              ),
            ),

            SizedBox(height: isTablet ? 20 : (isSmallDevice ? 12 : 16)),

            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isSmallDevice ? 16 : 24),
              child: Text(
                'Simplify Restaurant Operations',
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: isTablet ? 60 : (isSmallDevice ? 30 : 40)),

            // Carousel
            SizedBox(
              height: carouselHeight,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _features.length,
                itemBuilder: (context, index) {
                  return _buildFeatureCard(
                      _features[index], isTablet, isSmallDevice);
                },
              ),
            ),

            SizedBox(height: isTablet ? 30 : (isSmallDevice ? 15 : 20)),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _features.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            SizedBox(height: isTablet ? 60 : (isSmallDevice ? 30 : 40)),

            // Get Started Button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 64 : (isSmallDevice ? 24 : 32),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterLoginScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: double.infinity,
                    height: isTablet ? 70 : (isSmallDevice ? 50 : 60),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFF5F5F5)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: isTablet ? 22 : (isSmallDevice ? 16 : 20),
                            fontWeight: FontWeight.bold,
                            color: outer_background(),
                          ),
                        ),
                        SizedBox(width: isSmallDevice ? 8 : 12),
                        Icon(
                          Icons.arrow_forward,
                          color: outer_background(),
                          size: isTablet ? 26 : (isSmallDevice ? 20 : 24),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: isTablet ? 60 : (isSmallDevice ? 30 : 50)),

            // Snackbar Testing

            // TextButton(
            //   child: Text("B1"),
            //   onPressed: () {
            //     showStatusSnackBar(context, "GREETING MY FREND", "success");
            //   },
            // ),
            // TextButton(
            //   child: Text("B2"),
            //   onPressed: () {
            //     showStatusSnackBar(context, "GREETING MY FREND", "fail");
            //   },
            // ),
            // TextButton(
            //   child: Text("B3"),
            //   onPressed: () {
            //     showStatusSnackBar(context, "GREETING MY FREND", "warning");
            //   },
            // ),
            // TextButton(
            //   child: Text("B4"),
            //   onPressed: () {
            //     showStatusSnackBar(context, "GREETING MY FREND", "info");
            //   },
            // ),
            // TextButton(
            //   child: Text("B5"),
            //   onPressed: () {
            //     showSlideFromLeftSnackBar(context, "GREETING MY FREND", "success");
            //   },
            // ),
            // TextButton(
            //   child: Text("B6"),
            //   onPressed: () {
            //     showSlideFromLeftSnackBar(context, "GREETING MY FREND", "fail");
            //   },
            // ),
            // TextButton(
            //   child: Text("B7"),
            //   onPressed: () {
            //     showSlideFromLeftSnackBar(context, "GREETING MY FREND", "warning");
            //   },
            // ),
            // TextButton(
            //   child: Text("B8"),
            //   onPressed: () {
            //     showSlideFromLeftSnackBar(context, "GREETING MY FREND", "info");
            //   },
            // ),
            // TextButton(
            //   child: Text("B9"),
            //   onPressed: () {
            //     showBounceSnackBar(context, "GREETING MY FREND", "success");
            //   },
            // ),
            // TextButton(
            //   child: Text("B10"),
            //   onPressed: () {
            //     showBounceSnackBar(context, "GREETING MY FREND", "fail");
            //   },
            // ),
            // TextButton(
            //   child: Text("B11"),
            //   onPressed: () {
            //     showBounceSnackBar(context, "GREETING MY FREND", "warning");
            //   },
            // ),
            // TextButton(
            //   child: Text("B12"),
            //   onPressed: () {
            //     showBounceSnackBar(context, "GREETING MY FREND", "info");
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(Size size, bool isTablet, bool isSmallDevice) {
    final logoSize = isTablet ? 160.0 : 100.0;
    final titleSize = isTablet ? 36.0 : 28.0;
    final subtitleSize = isTablet ? 16.0 : 14.0;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: size.height),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 48 : 24,
            vertical: isTablet ? 32 : 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Added this
            children: [
              // Left side - Logo and text
              Expanded(
                flex: isTablet ? 5 : 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _logoAnimation,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: logoSize,
                              height: logoSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                    color: inner_background(), width: 3.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/cook_icon_sgs.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF4CAF50),
                                            Color(0xFF2E7D32)
                                          ],
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.restaurant,
                                        size: logoSize * 0.5,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: isTablet ? 30 : 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _typedText,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (_typeIndex <= _fullText.length)
                          Container(
                            width: 3,
                            height: titleSize * 0.95,
                            margin: const EdgeInsets.only(left: 2),
                            color: Colors.white,
                          ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Text(
                      'Simplify Restaurant Operations',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isTablet ? 40 : 30),
                    // Get Started Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterLoginScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: isTablet ? 300 : 250,
                          height: isTablet ? 60 : 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.white, Color(0xFFF5F5F5)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: outer_background(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.arrow_forward,
                                color: outer_background(),
                                size: isTablet ? 24 : 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: isTablet ? 40 : 20),

              // Right side - Features carousel
              Expanded(
                flex: isTablet ? 6 : 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: isTablet
                          ? 300
                          : 240, // Slightly increased for better proportions
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: _features.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isTablet
                                    ? 16
                                    : 8), // Reduced horizontal padding
                            child: _buildFeatureCard(
                                _features[index], isTablet, false),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: isTablet ? 24 : 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _features.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
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
    );
  }

  Widget _buildFeatureCard(
      FeatureInfo feature, bool isTablet, bool isSmallDevice) {
    final iconSize =
        isTablet ? 80.0 : (isSmallDevice ? 60.0 : 70.0); // Slightly reduced
    final titleSize = isTablet ? 22.0 : (isSmallDevice ? 18.0 : 20.0);
    final descSize = isTablet ? 15.0 : (isSmallDevice ? 14.0 : 14.5);
    final padding =
        isTablet ? 32.0 : (isSmallDevice ? 20.0 : 28.0); // Reduced padding

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isSmallDevice ? 16 : 20), // Reduced margin
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius:
            BorderRadius.circular(24), // Slightly reduced for better fit
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // Slightly reduced shadow
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Important: Don't expand unnecessarily
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              feature.icon,
              size: iconSize * 0.5,
              color: outer_background(),
            ),
          ),
          SizedBox(height: isTablet ? 20 : (isSmallDevice ? 16 : 18)),
          Text(
            feature.title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF212121),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isTablet ? 12 : (isSmallDevice ? 8 : 10)),
          Text(
            feature.description,
            style: TextStyle(
              fontSize: descSize,
              color: Colors.grey.shade600,
              height: 1.4, // Slightly reduced line height
            ),
            textAlign: TextAlign.center,
            maxLines: 3, // Limit lines to prevent overflow
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class FeatureInfo {
  final IconData icon;
  final String title;
  final String description;

  FeatureInfo({
    required this.icon,
    required this.title,
    required this.description,
  });
}


