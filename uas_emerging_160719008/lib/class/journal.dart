import 'package:flutter/foundation.dart';
import 'package:uas_emerging_160719008/class/country.dart';

class Journal {
  final int id;
  String title;
  String content;
  // String createdAt;
  String user;
  String country;
  Journal(
      {required this.id,
      required this.title,
      required this.content,
      // required this.createdAt,
      required this.user,
      required this.country});
  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        // createdAt: json['created_at'].toString(),
        user: json['user_name'] == null ? "Default user" : json['user_name'],
        country: json['country'] == null ? "Default country" : json['country']);
  }
}
