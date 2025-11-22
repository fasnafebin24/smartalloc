// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartalloc/features/teacher/project/model/review_model.dart';
import 'package:smartalloc/utils/contants/colors.dart';
import 'package:smartalloc/utils/extension/space_ext.dart';

class ReviewListingScreen extends StatelessWidget {
  String projectid;
  final bool showAll;
  
  ReviewListingScreen({
    super.key,
    required this.projectid,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Projects')
          .doc(projectid)
          .collection('Review')
          .snapshots(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return 0.hBox;
        }
        if (asyncSnapshot.hasError) {
          return 0.hBox;
        }
        
        final reviews = asyncSnapshot.data!.docs;
        List<ReviewModel> reviewModel = reviews
            .map((doc) => ReviewModel.fromJson(doc.data()))
            .toList();
        
        // Limit to 2 reviews if showAll is false
        final displayReviews = showAll ? reviewModel : reviewModel.take(2).toList();
        final hasMoreReviews = reviewModel.length > 2;

        return Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(0.0),
              itemCount: displayReviews.length,
              itemBuilder: (context, index) {
                return ReviewCard(review: displayReviews[index]);
              },
            ),
            
            // Show "See All" button only if there are more than 2 reviews and not showing all
            if (!showAll && hasMoreReviews)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllReviewsScreen(projectid: projectid),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'See All Reviews (${reviewModel.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// Separate screen for showing all reviews
class AllReviewsScreen extends StatelessWidget {
  final String projectid;

  const AllReviewsScreen({super.key, required this.projectid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Reviews'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ReviewListingScreen(
            projectid: projectid,
            showAll: true,
          ),
        ),
      ),
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
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF8C7CD4),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: review.avatarUrl ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.white,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              review.name ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            review.reviewedAt ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildStarRating(review.rating ?? 0),
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
                      Text(
                        review.comment ?? '',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
          return Icon(Icons.star, color: Colors.amber, size: 12);
        } else if (index < rating) {
          return Icon(Icons.star_half, color: Colors.amber, size: 12);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 12);
        }
      }),
    );
  }
}