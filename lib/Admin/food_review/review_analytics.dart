import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:orderease/util_components/util.dart';

class FoodAnalyticsSection extends StatefulWidget {
  final dynamic reviewsData; // Can accept both List and Map
  final String title;
  final Color? primaryColor;
  final Color? backgroundColor;

  const FoodAnalyticsSection({
    Key? key,
    required this.reviewsData,
    this.title = 'Food Performance Analytics',
    this.primaryColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<FoodAnalyticsSection> createState() => _FoodAnalyticsSectionState();
}

class _FoodAnalyticsSectionState extends State<FoodAnalyticsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedView = 'top3'; // top3, top5, top10, all

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get primaryColor => widget.primaryColor ?? outer_background();
  Color get backgroundColor => widget.backgroundColor ?? inner_background();

  // Convert List to Map format for processing
  Map<String, dynamic> get _processedData {
    if (widget.reviewsData is Map<String, dynamic>) {
      return widget.reviewsData as Map<String, dynamic>;
    } else if (widget.reviewsData is List) {
      Map<String, dynamic> converted = {};
      for (var item in widget.reviewsData) {
        if (item is Map<String, dynamic>) {
          // Extract food name from the map
          String? foodName;

          // Try common key names for food name
          if (item.containsKey('foodName')) {
            foodName = item['foodName'];
          } else if (item.containsKey('food_name')) {
            foodName = item['food_name'];
          } else if (item.containsKey('name')) {
            foodName = item['name'];
          } else {
            // If no name field, use the first string value found
            for (var value in item.values) {
              if (value is String) {
                foodName = value;
                break;
              }
            }
          }

          if (foodName != null) {
            // Store the data under the food name key
            converted[foodName] = {
              'ratings': item['ratings'] ?? item['total_ratings'] ?? 0.0,
              'review_food_count':
                  item['review_food_count'] ?? item['count'] ?? 0,
              'average_ratings':
                  item['average_ratings'] ?? item['avg_rating'] ?? 0.0,
            };
          }
        }
      }
      return converted;
    }
    return {};
  }

  List<MapEntry<String, dynamic>> _getSortedData() {
    List<MapEntry<String, dynamic>> entries = _processedData.entries.toList();

    // Always sort by average rating (descending)
    entries.sort((a, b) {
      double ratingA = (a.value['average_ratings'] ?? 0.0).toDouble();
      double ratingB = (b.value['average_ratings'] ?? 0.0).toDouble();
      return ratingB.compareTo(ratingA);
    });

    // Filter based on selected view
    switch (_selectedView) {
      case 'top3':
        return entries.take(3).toList();
      case 'top5':
        return entries.take(5).toList();
      case 'top10':
        return entries.take(10).toList();
      case 'all':
      default:
        return entries;
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8.5) return Colors.green;
    if (rating >= 7.0) return Colors.lightGreen;
    if (rating >= 5.5) return Colors.orange;
    if (rating >= 4.0) return Colors.deepOrange;
    return Colors.red;
  }

  String _getRatingLabel(double rating) {
    if (rating >= 9.0) return 'Exceptional';
    if (rating >= 8.0) return 'Excellent';
    if (rating >= 7.0) return 'Very Good';
    if (rating >= 6.0) return 'Good';
    if (rating >= 5.0) return 'Average';
    if (rating >= 4.0) return 'Below Average';
    return 'Needs Improvement';
  }

  IconData _getRatingIcon(double rating) {
    if (rating >= 8.5) return Icons.star;
    if (rating >= 7.0) return Icons.thumb_up;
    if (rating >= 5.5) return Icons.thumb_up_outlined;
    if (rating >= 4.0) return Icons.warning_amber_rounded;
    return Icons.trending_down;
  }

  String? _getSuggestion(double rating) {
    if (rating < 6.0) {
      if (rating < 4.0) {
        return '🔴 Critical: Immediate improvement needed';
      } else if (rating < 5.0) {
        return '🟠 Review ingredients and preparation';
      } else {
        return '🟡 Consider customer feedback for enhancement';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeTablet = screenWidth > 900;

    final processedData = _processedData;

    if (processedData.isEmpty) {
      return _buildEmptyState(isTablet);
    }

    final sortedData = _getSortedData();
    print(sortedData);
    print("SORTDATA");
    return Container(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 14.0 : 12.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: isTablet ? 32.0 : 28.0,
                ),
              ),
              SizedBox(width: isTablet ? 16.0 : 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: isTablet ? 26.0 : 22.0,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '${processedData.length} items • Sorted by rating',
                      style: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 28.0 : 24.0),

          // View Options
          Row(
            children: [
              Text(
                'Show:',
                style: TextStyle(
                  fontSize: isTablet ? 16.0 : 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: isTablet ? 12.0 : 8.0),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildViewChip('Top 3', 'top3', isTablet),
                      _buildViewChip('Top 5', 'top5', isTablet),
                      _buildViewChip('Top 10', 'top10', isTablet),
                      _buildViewChip('View All', 'all', isTablet),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 24.0 : 20.0),

          // Food Items List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedData.length,
            itemBuilder: (context, index) {
              final entry = sortedData[index];
              final foodName = entry.key;
              final data = entry.value;
              final avgRating = (data['average_ratings'] ?? 0.0).toDouble();
              final reviewCount = data['review_food_count'] ?? 0;
              final totalRatings = (data['ratings'] ?? 0.0).toDouble();

              final delay = index * 0.1;

              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      math.min(delay, 0.8),
                      math.min(delay + 0.2, 1.0),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.2, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        math.min(delay, 0.8),
                        math.min(delay + 0.2, 1.0),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  child: _buildFoodItemCard(
                    foodName: foodName,
                    avgRating: avgRating,
                    reviewCount: reviewCount,
                    totalRatings: totalRatings,
                    rank: index + 1,
                    isTablet: isTablet,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewChip(String label, String value, bool isTablet) {
    final isSelected = _selectedView == value;
    return Padding(
      padding: EdgeInsets.only(right: isTablet ? 10.0 : 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _selectedView = value;
            _animationController.reset();
            _animationController.forward();
          });
        },
        selectedColor: primaryColor.withOpacity(0.2),
        checkmarkColor: primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: isTablet ? 14.0 : 12.0,
        ),
        side: BorderSide(
          color: isSelected ? primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }

  Widget _buildFoodItemCard({
    required String foodName,
    required double avgRating,
    required int reviewCount,
    required double totalRatings,
    required int rank,
    required bool isTablet,
  }) {
    final ratingColor = _getRatingColor(avgRating);
    final ratingLabel = _getRatingLabel(avgRating);
    final ratingIcon = _getRatingIcon(avgRating);
    final suggestion = _getSuggestion(avgRating);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ratingColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ratingColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Rank Badge
                Container(
                  width: isTablet ? 42.0 : 38.0,
                  height: isTablet ? 42.0 : 38.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: rank <= 3
                          ? [Colors.amber, Colors.orange]
                          : [Colors.grey[300]!, Colors.grey[400]!],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: rank <= 3
                        ? [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: isTablet ? 16.0 : 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 16.0 : 12.0),
                // Food Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        foodName,
                        style: TextStyle(
                          fontSize: isTablet ? 20.0 : 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(
                            ratingIcon,
                            size: isTablet ? 18.0 : 16.0,
                            color: ratingColor,
                          ),
                          SizedBox(width: 6.0),
                          Text(
                            ratingLabel,
                            style: TextStyle(
                              fontSize: isTablet ? 14.0 : 12.0,
                              color: ratingColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Text(
                            "Total Reviews:",
                            style: TextStyle(
                              fontSize: isTablet ? 16.0 : 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: 6.0),
                          Text(
                            reviewCount.toString(),
                            style: TextStyle(
                              fontSize: isTablet ? 14.0 : 12.0,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Rating Score
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16.0 : 12.0,
                    vertical: isTablet ? 10.0 : 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: ratingColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ratingColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: isTablet ? 24.0 : 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4.0),
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: isTablet ? 20.0 : 18.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Suggestion Box (if rating needs improvement)
            if (suggestion != null) ...[
              SizedBox(height: isTablet ? 16.0 : 12.0),
              Container(
                padding: EdgeInsets.all(isTablet ? 14.0 : 12.0),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ratingColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: ratingColor,
                      size: isTablet ? 24.0 : 20.0,
                    ),
                    SizedBox(width: isTablet ? 12.0 : 10.0),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          fontSize: isTablet ? 14.0 : 12.0,
                          color: ratingColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: isTablet ? 16.0 : 12.0),

            // Stats Row
            // Container(
            //   padding: EdgeInsets.all(isTablet ? 14.0 : 12.0),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[50],
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       _buildStatItem(
            //         icon: Icons.rate_review,
            //         label: 'Total Reviews',
            //         value: reviewCount.toString(),
            //         color: primaryColor,
            //         isTablet: isTablet,
            //       ),
            //       // Container(
            //       //   width: 1,
            //       //   height: isTablet ? 40.0 : 35.0,
            //       //   color: Colors.grey[300],
            //       // ),
            //       // _buildStatItem(
            //       //   icon: Icons.star_border,
            //       //   label: 'Total Ratings',
            //       //   value: totalRatings.toStringAsFixed(1),
            //       //   color: Colors.amber[700]!,
            //       //   isTablet: isTablet,
            //       // ),
            //       // Container(
            //       //   width: 1,
            //       //   height: isTablet ? 40.0 : 35.0,
            //       //   color: Colors.grey[300],
            //       // ),
            //       // _buildStatItem(
            //       //   icon: Icons.trending_up,
            //       //   label: 'Avg Score',
            //       //   value: avgRating.toStringAsFixed(1),
            //       //   color: ratingColor,
            //       //   isTablet: isTablet,
            //       // ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isTablet,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: isTablet ? 24.0 : 20.0),
        SizedBox(height: 6.0),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 18.0 : 16.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2.0),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 11.0 : 10.0,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 48.0 : 32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: isTablet ? 80.0 : 64.0,
            color: Colors.grey[400],
          ),
          SizedBox(height: isTablet ? 24.0 : 16.0),
          Text(
            'No Review Data Available',
            style: TextStyle(
              fontSize: isTablet ? 22.0 : 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: isTablet ? 12.0 : 8.0),
          Text(
            'Start collecting customer feedback to see analytics',
            style: TextStyle(
              fontSize: isTablet ? 16.0 : 14.0,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Example Usage with List format:
/*
FoodAnalyticsSection(
  reviewsData: [
    {
      "foodName": "Chicken Biryani",
      "ratings": 24.0,
      "review_food_count": 3,
      "average_ratings": 8.0
    },
    {
      "foodName": "Paneer Tikka",
      "ratings": 21.0,
      "review_food_count": 3,
      "average_ratings": 7.0
    },
    {
      "foodName": "Dal Makhani",
      "ratings": 15.0,
      "review_food_count": 3,
      "average_ratings": 5.0
    },
  ],
  title: 'Food Performance Analytics',
  primaryColor: Color(0xFF1565C0),
  backgroundColor: Color(0xFFF5F5F5),
)
*/