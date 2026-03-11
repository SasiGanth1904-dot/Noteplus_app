import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  String id;
  String title;
  String description;
  Timestamp createdAt;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory ContentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ContentModel(
      id: doc.id,
      title: data['Title'] ?? data['title'] ?? '',
      description: data['Description'] ?? data['description'] ?? '',
      createdAt: data['createdAt'] ?? data['CreatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Title': title,
      'Description': description,
      'createdAt': createdAt,
    };
  }
}
