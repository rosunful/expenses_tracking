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

  /// Renames a custom category in place — same document id, just a
  /// different 'name' field. Existing transactions/budgets/reminders
  /// that already stored the OLD name as plain text are NOT updated by
  /// this — they're independent snapshots taken at the time each was
  /// created, not live references to this category document.
  Future<void> updateCategoryName(String categoryId, String newName) async {
    await _categoriesRef.doc(categoryId).update({'name': newName});
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoriesRef.doc(categoryId).delete();
  }

  /// Finds every renamed category's real usages and rewrites them to
  /// the new name — this is what makes a rename actually propagate,
  /// instead of leaving old transactions/reminders stuck showing the
  /// old text forever.
  Future<void> cascadeRenameCategory(String oldName, String newName, CategoryType type) async {
    if (type == CategoryType.expense || type == CategoryType.income) {
      await _renameInCollection('transactions', oldName, newName);
    }
    if (type == CategoryType.reminder) {
      await _renameInCollection('reminders', oldName, newName);
    }
    if (type == CategoryType.expense) {
      // Budgets are special: category is the DOCUMENT ID, not just a
      // field (see BudgetRepository). Firestore can't rename a
      // document's id in place — the only way is to copy the data to
      // a new doc under the new id, then delete the old one. Wrapped
      // in a transaction so a crash mid-operation can't leave you with
      // neither doc (or both).
      await _migrateBudgetCategory(oldName, newName);
    }
  }

  Future<void> _renameInCollection(String collectionName, String oldValue, String newValue) async {
    final ref = _db.collection('users').doc(_uid).collection(collectionName);
    final matches = await ref.where('category', isEqualTo: oldValue).get();
    if (matches.docs.isEmpty) return;

    // Firestore batches cap at 500 writes — chunk in case someone has
    // a genuinely large transaction history under one category.
    const chunkSize = 450;
    for (var i = 0; i < matches.docs.length; i += chunkSize) {
      final chunk = matches.docs.skip(i).take(chunkSize);
      final batch = _db.batch();
      for (final doc in chunk) {
        batch.update(doc.reference, {'category': newValue});
      }
      await batch.commit();
    }
  }

  Future<void> _migrateBudgetCategory(String oldCategory, String newCategory) async {
    final budgetsRef = _db.collection('users').doc(_uid).collection('budgets');

    await _db.runTransaction((transaction) async {
      final oldDoc = await transaction.get(budgetsRef.doc(oldCategory));
      if (!oldDoc.exists) return; // no budget for this category — nothing to migrate

      final data = Map<String, dynamic>.from(oldDoc.data()!);
      data['category'] = newCategory;

      transaction.set(budgetsRef.doc(newCategory), data);
      transaction.delete(budgetsRef.doc(oldCategory));
    });
  }

  /// Streams ALL custom categories (both types together). CategoryProvider
  /// splits them by type — simpler than running two separate queries.
  Stream<List<CategoryModel>> streamCategories() {
    return _categoriesRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
        .toList());
  }
}