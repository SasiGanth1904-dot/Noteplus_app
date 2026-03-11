import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Collection reference
  CollectionReference get _itemsCollection => _db.collection('app_data');

  // Add new content (Users & Admins)
  Future<void> addContent(ContentModel content) async {
    try {
      await _itemsCollection.add(content.toMap());
    } catch (e) {
      print("Error adding content: ${e.toString()}");
      throw e;
    }
  }

  // Update existing content (Admin only)
  Future<void> updateContent(String id, Map<String, dynamic> data) async {
    if (!_authService.isAdmin) throw Exception("Unauthorized: Admin access required");

    try {
      await _itemsCollection.doc(id).update(data);
    } catch (e) {
      print("Error updating content: ${e.toString()}");
      throw e;
    }
  }

  // Delete content (Admin only)
  Future<void> deleteContent(String id) async {
    if (!_authService.isAdmin) throw Exception("Unauthorized: Admin access required");

    try {
      await _itemsCollection.doc(id).delete();
    } catch (e) {
      print("Error deleting content: ${e.toString()}");
      throw e;
    }
  }

  // Stream of all content ordered by created date
  Stream<List<ContentModel>> getContentStream() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ContentModel.fromFirestore(doc)).toList();
    });
  }
}
