import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartalloc/features/teacher/project/model/review_model.dart';
import 'package:smartalloc/utils/contants/colors.dart';
import 'package:smartalloc/utils/methods/date_methods.dart';

class ReviewListingScreen extends StatelessWidget {

   const ReviewListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
    
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
        padding: EdgeInsets.all(0.0),
        itemCount:1,
        itemBuilder: (context, index) {
          // return ReviewCard(review: );
        },
      );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.whiteColor,
      
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar, Name, and Rating Row
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(review.avatarUrl??''),
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(width: 12),
                // Name and Rating Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.name??'',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStarRating(review.rating??0),
                          SizedBox(width: 6),
                          Text(
                            review.rating.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Date
                Text(
                  formatTimeAgo(review.reviewedAt != null ? Timestamp.fromDate(review.reviewedAt!) : Timestamp.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Comment
            Text(
              review.comment??'',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          // Full star
          return Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (index < rating) {
          // Half star
          return Icon(Icons.star_half, color: Colors.amber, size: 18);
        } else {
          // Empty star
          return Icon(Icons.star_border, color: Colors.amber, size: 18);
        }
      }),
    );
  }
}

