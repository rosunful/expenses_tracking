import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracking/models/category_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Only stores the user's CUSTOM categories. The built-in defaults
/// ("Food", "Salary", etc.) live as plain Dart lists in CategoryProvider
/// and never touch Firestore — no reason to store data that's identical
/// for every user and never changes.
class CategoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('No logged-in user — cannot access categories.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _db.collection('users').doc(_uid).collection('categories');

  Future<void> addCategory(String name, CategoryType type) async {
    await _categoriesRef.add({'name': name, 'type': type.name});
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoriesRef.doc(categoryId).delete();
  }

  /// Streams ALL custom categories (both types together). CategoryProvider
  /// splits them by type — simpler than running two separate queries.
  Stream<List<CategoryModel>> streamCategories() {
    return _categoriesRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
        .toList());
  }
}