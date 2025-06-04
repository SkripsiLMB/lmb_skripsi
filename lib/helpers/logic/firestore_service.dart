import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // NOTE: Singleton system
  FirestoreService._privateConstructor();
  static final FirestoreService _instance = FirestoreService._privateConstructor();
  static FirestoreService get instance => _instance;

  // NOTE: Firestore service
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // NOTE: Variable
  FirebaseFirestore get db => _db;

  // NOTE: Masukin data user
  Future<void> setUserData({
    required String email,
    required String name,
    required String nik,
  }) async {
    await _db.collection('users').doc(email).set({
      'name': name,
      'nik': nik,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // NOTE: Ambil data user
  Future<DocumentSnapshot> getUserByEmail(String email) {
    return _db.collection('users').doc(email).get();
  }
}