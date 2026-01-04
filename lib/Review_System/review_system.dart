import 'package:flutter/material.dart';
import 'package:orderease/util_components/util.dart';

class FoodReviewPage extends StatefulWidget {
  final List<FoodItem> foodItems;
  final String tableNumber;
  final Function(Map<String, ReviewData>) onSubmitReview;

  const FoodReviewPage({
    Key? key,
    required this.foodItems,
    required this.tableNumber,
    required this.onSubmitReview,
  }) : super(key: key);

  @override
  State<FoodReviewPage> createState() => _FoodReviewPageState();
}

class _FoodReviewPageState extends State<FoodReviewPage>
    with TickerProviderStateMixin {
  late Map<String, double> _ratings;
  final TextEditingController _sessionFeedbackController =
      TextEditingController();
  late AnimationController _submitButtonController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize all ratings to 5.0 (middle value)
    _ratings = {
      for (var item in widget.foodItems) item.id: 5.0,
    };

    _submitButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _sessionFeedbackController.dispose();
    _submitButtonController.dispose();
    super.dispose();
  }

  Color outer_background() => const Color(0xFF1565C0);
  Color inner_background() => const Color(0xFFF5F5F5);

  void _submitFeedback() async {
    setState(() {
      _isSubmitting = true;
    });

    _submitButtonController.forward();

    // Prepare review data
    Map<String, ReviewData> reviewData = {};
    for (var item in widget.foodItems) {
      reviewData[item.id] = ReviewData(
        foodId: item.id,
        foodName: item.name,
        rating: _ratings[item.id]!,
      );
    }

    // Call the callback with review data
    await Future.delayed(const Duration(milliseconds: 800));
    widget.onSubmitReview(reviewData);

    if (mounted) {
      Navigator.pop(context);
      showSlideFromLeftSnackBar(context, 'Thank you for your feedback! 🎉', "success");
    }
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
      appBar: AppBar(
        backgroundColor: outer_background(),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: isTablet ? 28 : 24,
          ),
        ),
        title: Text(
          'Rate Your Experience',
          style: TextStyle(
            fontSize: getResponsiveFontSize(20, 24, 28),
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getResponsivePadding(16, 24),
            vertical: getResponsivePadding(16, 20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(getResponsivePadding(20, 28)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      outer_background(),
                      outer_background().withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: outer_background(),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: isTablet ? 56 : 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: getResponsivePadding(12, 16)),
                    Text(
                      '${widget.tableNumber}',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(18, 22, 26),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: getResponsivePadding(8, 10)),
                    Text(
                      'Help us serve you better!',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(14, 16, 18),
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: getResponsivePadding(24, 32)),

              // Food Items Rating Section
              Text(
                'Rate Your Dishes',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(22, 26, 30),
                  fontWeight: FontWeight.bold,
                  color: outer_background(),
                ),
              ),

              SizedBox(height: getResponsivePadding(12, 16)),

              // Food Rating Cards
              ...widget.foodItems.map((foodItem) {
                return _buildFoodRatingCard(
                  foodItem,
                  isTablet,
                  getResponsiveFontSize,
                  getResponsivePadding,
                );
              }).toList(),

              SizedBox(height: getResponsivePadding(24, 32)),

              // Session Feedback Section
              Text(
                'Overall Experience',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(22, 26, 30),
                  fontWeight: FontWeight.bold,
                  color: outer_background(),
                ),
              ),

              SizedBox(height: getResponsivePadding(12, 16)),

              Container(
                padding: EdgeInsets.all(getResponsivePadding(20, 24)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.rate_review,
                          color: outer_background(),
                          size: isTablet ? 28 : 24,
                        ),
                        SizedBox(width: getResponsivePadding(8, 12)),
                        Text(
                          'Share your thoughts',
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(16, 18, 20),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getResponsivePadding(12, 16)),
                    TextField(
                      controller: _sessionFeedbackController,
                      maxLines: 5,
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(14, 16, 18),
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Tell us about your dining experience... (Optional)',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: getResponsiveFontSize(14, 16, 18),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: outer_background(),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(
                          getResponsivePadding(12, 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: getResponsivePadding(32, 40)),

              // Submit Button
              Center(
                child: AnimatedBuilder(
                  animation: _submitButtonController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 - (_submitButtonController.value * 0.1),
                      child: Container(
                        width: isLargeTablet ? 400 : double.infinity,
                        height: isTablet ? 65 : 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isSubmitting
                                ? [Colors.grey, Colors.grey[600]!]
                                : [
                                    outer_background(),
                                    outer_background().withOpacity(0.8),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: _isSubmitting
                                  ? Colors.grey.withOpacity(0.3)
                                  : outer_background().withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isSubmitting ? null : _submitFeedback,
                            borderRadius: BorderRadius.circular(30),
                            child: Center(
                              child: _isSubmitting
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Submitting...',
                                          style: TextStyle(
                                            fontSize: getResponsiveFontSize(
                                                18, 20, 22),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            inner_background(),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.send,
                                          color: Colors.white,
                                          size: isTablet ? 26 : 22,
                                        ),
                                        SizedBox(
                                            width: getResponsivePadding(8, 12)),
                                        Text(
                                          'Submit Feedback',
                                          style: TextStyle(
                                            fontSize: getResponsiveFontSize(
                                                18, 20, 22),
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
                    );
                  },
                ),
              ),

              SizedBox(height: getResponsivePadding(24, 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodRatingCard(
    FoodItem foodItem,
    bool isTablet,
    double Function(double, double, double) getResponsiveFontSize,
    double Function(double, double) getResponsivePadding,
  ) {
    final currentRating = _ratings[foodItem.id] ?? 5.0;
    final ratingText = _getRatingText(currentRating);
    final ratingEmoji = _getRatingEmoji(currentRating);
    final ratingColor = _getRatingColor(currentRating);

    return Container(
      margin: EdgeInsets.only(bottom: getResponsivePadding(16.0, 20.0)),
      padding: EdgeInsets.all(getResponsivePadding(20.0, 24.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Name and Category
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(getResponsivePadding(10.0, 12.0)),
                decoration: BoxDecoration(
                  color: outer_background().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  // _getCategoryIcon(foodItem.category),
                  Icons.restaurant,
                  color: outer_background(),
                  size: isTablet ? 32.0 : 28.0,
                ),
              ),
              SizedBox(width: getResponsivePadding(12.0, 16.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItem.name,
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(18.0, 20.0, 22.0),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: getResponsivePadding(16.0, 20.0)),

          // Rating Display
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  ratingEmoji,
                  style: TextStyle(
                    fontSize: isTablet ? 56.0 : 48.0,
                  ),
                ),
                SizedBox(height: getResponsivePadding(8.0, 10.0)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getResponsivePadding(16.0, 20.0),
                    vertical: getResponsivePadding(8.0, 10.0),
                  ),
                  decoration: BoxDecoration(
                    color: ratingColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ratingColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    ratingText,
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(16.0, 18.0, 20.0),
                      fontWeight: FontWeight.bold,
                      color: ratingColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: getResponsivePadding(16.0, 20.0)),

          // Slider
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: isTablet ? 8.0 : 6.0,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: isTablet ? 16.0 : 14.0,
                    elevation: 6,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: isTablet ? 28.0 : 24.0,
                  ),
                  activeTrackColor: ratingColor,
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: ratingColor,
                  overlayColor: ratingColor.withOpacity(0.2),
                  valueIndicatorColor: ratingColor,
                  valueIndicatorTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: getResponsiveFontSize(14.0, 16.0, 18.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Slider(
                  value: currentRating,
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  label: currentRating.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _ratings[foodItem.id] = value;
                    });
                  },
                ),
              ),

              // Rating Scale
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getResponsivePadding(8.0, 12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(10, (index) {
                    final number = index + 1;
                    final isSelected = currentRating.toInt() == number;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _ratings[foodItem.id] = number.toDouble();
                        });
                      },
                      child: Container(
                        width: isTablet ? 32.0 : 28.0,
                        height: isTablet ? 32.0 : 28.0,
                        decoration: BoxDecoration(
                          color: isSelected ? ratingColor : Colors.grey[200],
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: ratingColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            number.toString(),
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(11.0, 13.0, 14.0),
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating <= 2) return 'Poor';
    if (rating <= 4) return 'Below Average';
    if (rating <= 6) return 'Average';
    if (rating <= 8) return 'Good';
    if (rating <= 9) return 'Excellent';
    return 'Outstanding!';
  }

  String _getRatingEmoji(double rating) {
    if (rating <= 2) return '😞';
    if (rating <= 4) return '😐';
    if (rating <= 6) return '🙂';
    if (rating <= 8) return '😊';
    if (rating <= 9) return '😍';
    return '🤩';
  }

  Color _getRatingColor(double rating) {
    if (rating <= 3) return Colors.red;
    if (rating <= 5) return Colors.orange;
    if (rating <= 7) return Colors.amber;
    if (rating <= 9) return Colors.lightGreen;
    return Colors.green;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'appetizer':
        return Icons.fastfood;
      case 'main course':
        return Icons.restaurant;
      case 'dessert':
        return Icons.cake;
      case 'beverage':
        return Icons.local_drink;
      case 'snack':
        return Icons.lunch_dining;
      default:
        return Icons.restaurant_menu;
    }
  }
}

// Model Classes
class FoodItem {
  final String id;
  final String name;
  final String category;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
  });
}

class ReviewData {
  final String foodId;
  final String foodName;
  final double rating;

  ReviewData({
    required this.foodId,
    required this.foodName,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'rating': rating,
    };
  }
}
