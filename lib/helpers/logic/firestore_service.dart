import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/ui/snackbar_handler.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';

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
Future<LmbUser> getUserByEmail(BuildContext context, String email) async {
  final snapshot = await _db.collection('users').doc(email).get();
  if (!snapshot.exists) {
    LmbSnackbar.onError(context, "Your account has invalidity please contact admin.");
  }

  final data = snapshot.data() as Map<String, dynamic>;
  return LmbUser(
    name: data['name'] ?? 'Unknown User',
    nik: data['nik'] ?? '-',
    email: email,
    createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
}