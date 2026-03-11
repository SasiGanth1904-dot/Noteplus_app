import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  Future addContentDetails(Map<String, dynamic> contentInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("app_data")
        .doc("public_content")
        .collection("items")
        .doc(id)
        .set(contentInfoMap);
  }

  Future updateContentDetails(String id, Map<String, dynamic> updateInfo) async {
    return await FirebaseFirestore.instance
        .collection("app_data")
        .doc(id)
        .update(updateInfo);
  }

  Future deleteContentDetails(String id) async {
    return await FirebaseFirestore.instance
        .collection("app_data")
        .doc(id)
        .delete();
  }

  // Method to add data to app_data collection
  Future addAppData(Map<String, dynamic> dataMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("app_data")
        .doc(id)
        .set(dataMap);
  }
}
