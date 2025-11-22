// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

List<UserModel> userModelFromJson(String str) => List<UserModel>.from(json.decode(str).map((x) => UserModel.fromJson(x)));

String userModelToJson(List<UserModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserModel {
    String? uid;
    String? name;
    List<String>? namefilter;
    String? email;
    String? password;
    String? role;
    String? department;
    String? departmentcode;
    String? avatarUrl;
    int? status;

    UserModel({
        this.uid,
        this.name,
        this.namefilter,
        this.email,
        this.password,
        this.role,
        this.department,
        this.departmentcode,
        this.avatarUrl,
        this.status,
    });

    factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json["uid"],
        name: json["name"],
        namefilter: json["namefilter"] == null ? [] : List<String>.from(json["namefilter"]!.map((x) => x)),
        email: json["email"],
        password: json["password"],
        role: json["role"],
        department: json["department"],
        departmentcode: json["departmentcode"],
        avatarUrl: json["avatarUrl"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "namefilter": namefilter == null ? [] : List<dynamic>.from(namefilter!.map((x) => x)),
        "email": email,
        "password": password,
        "role": role,
        "department": department,
        "departmentcode": departmentcode,
        "avatarUrl": avatarUrl,
        "status": status,
    };
}
