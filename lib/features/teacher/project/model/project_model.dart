// To parse this JSON data, do
//
//     final projectModel = projectModelFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartalloc/utils/methods/date_methods.dart';

List<ProjectModel> projectModelFromJson(String str) => List<ProjectModel>.from(json.decode(str).map((x) => ProjectModel.fromJson(x)));

String projectModelToJson(List<ProjectModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProjectModel {
    String? teacherEmail;
    String? teacherName;
    String? batch;
    String? description;
    String? abstractfileurl;
    String? uploadAt;
    String? teacherId;
    String? domain;
    String? finalProjectFileurl;
    List<String>? namefilter;
    String? departmentcode;
    String? startyear;
    String? id;
    String? department;
    String? endyear;
    String? projectName;
    String? status;

    ProjectModel({
        this.teacherEmail,
        this.teacherName,
        this.batch,
        this.description,
        this.abstractfileurl,
        this.uploadAt,
        this.teacherId,
        this.domain,
        this.finalProjectFileurl,
        this.namefilter,
        this.departmentcode,
        this.startyear,
        this.id,
        this.department,
        this.endyear,
        this.projectName,
        this.status,
    });

    factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        teacherEmail: json["teacherEmail"],
        teacherName: json["teacherName"],
        batch: json["batch"],
        description: json["description"],
        abstractfileurl: json["abstractfileurl"],
        uploadAt: formatTimestamp(json["uploadAt"] as Timestamp),
        teacherId: json["teacherId"],
        domain: json["domain"],
        finalProjectFileurl: json["finalProjectFileurl"],
        namefilter: json["namefilter"] == null ? [] : List<String>.from(json["namefilter"]!.map((x) => x)),
        departmentcode: json["departmentcode"],
        startyear: json["startyear"],
        id: json["id"],
        department: json["department"],
        endyear: json["endyear"],
        projectName: json["projectName"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "teacherEmail": teacherEmail,
        "teacherName": teacherName,
        "batch": batch,
        "description": description,
        "abstractfileurl": abstractfileurl,
        "uploadAt": uploadAt,
        "teacherId": teacherId,
        "domain": domain,
        "finalProjectFileurl": finalProjectFileurl,
        "namefilter": namefilter == null ? [] : List<dynamic>.from(namefilter!.map((x) => x)),
        "departmentcode": departmentcode,
        "startyear": startyear,
        "id": id,
        "department": department,
        "endyear": endyear,
        "projectName": projectName,
        "status": status,
    };
}
