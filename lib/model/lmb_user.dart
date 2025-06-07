import 'package:cloud_firestore/cloud_firestore.dart';

class LmbUser {
  String? profilePictureUrl;
  String name;
  String nik;
  String email;
  DateTime createdAt;

  LmbUser({
    this.profilePictureUrl,
    required this.name,
    required this.nik,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'profile_picture_url': profilePictureUrl,
      'name': name,
      'nik': nik,
      'email': email,
      'created_at': createdAt.microsecondsSinceEpoch,
    };
  }

  factory LmbUser.fromJson(Map<String, dynamic> json) {
    final dynamic rawDate = json['created_at'];

    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate().toLocal();
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMicrosecondsSinceEpoch(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return LmbUser(
      profilePictureUrl: json['profile_picture_url'],
      name: json['name'],
      nik: json['nik'],
      email: json['email'],
      createdAt: parsedDate,
    );
  }
}