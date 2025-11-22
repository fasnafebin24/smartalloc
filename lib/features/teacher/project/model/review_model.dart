// To parse this JSON data, do
//
//     final reviewModel = reviewModelFromJson(jsonString);

import 'dart:convert';

List<ReviewModel> reviewModelFromJson(String str) => List<ReviewModel>.from(json.decode(str).map((x) => ReviewModel.fromJson(x)));

String reviewModelToJson(List<ReviewModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewModel {
    String? comment;
    double? rating;
    int? outoff;
    int? status;
    String? name;
    String? emailId;
    String? avatarUrl;
    DateTime? reviewedAt;
    String? userId;

    ReviewModel({
        this.comment,
        this.rating,
        this.outoff,
        this.status,
        this.name,
        this.emailId,
        this.avatarUrl,
        this.reviewedAt,
        this.userId,
    });

    factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        comment: json["comment"],
        rating: json["rating"]?.toDouble(),
        outoff: json["outoff"],
        status: json["status"],
        name: json["name"],
        emailId: json["emailId"],
        avatarUrl: json["avatarUrl"],
        reviewedAt: json["reviewedAt"] == null ? null : DateTime.parse(json["reviewedAt"]),
        userId: json["userId"],
    );

    Map<String, dynamic> toJson() => {
        "comment": comment,
        "rating": rating,
        "outoff": outoff,
        "status": status,
        "name": name,
        "emailId": emailId,
        "avatarUrl": avatarUrl,
        "reviewedAt": reviewedAt?.toIso8601String(),
        "userId": userId,
    };
}
