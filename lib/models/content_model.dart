import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  String id;
  String title;
  String description;
  String? imageUrl;
  Timestamp createdAt;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.createdAt,
  });

  factory ContentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ContentModel(
      id: doc.id,
      title: data['title'] ?? data['Title'] ?? '',
      description: data['description'] ?? data['Description'] ?? '',
      imageUrl: data['imageUrl'] ?? data['ImageUrl'],
      createdAt: data['createdAt'] ?? data['CreatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}
