import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
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
  Future<void> setUserData({required LmbUser user}) async {
    await _db.collection('users').doc(user.email).set({
      'name': user.name,
      'nik': user.nik,
      'created_at': user.createdAt,
    });
  }

  // NOTE: Ambil data user
Future<LmbUser> getUserByEmail(BuildContext context, String email) async {
  final snapshot = await _db.collection('users').doc(email).get();
  if (!snapshot.exists) {
    WindowProvider.toastError(context, "Your account has invalidity please contact admin.");
  }

  final data = snapshot.data() as Map<String, dynamic>;
  return LmbUser(
    name: data['name'] ?? 'Unknown User',
    nik: data['nik'] ?? '-',
    email: email,
    createdAt: (data['created_at'] as Timestamp?)?.toDate().toLocal() ?? DateTime.now(),
  );
}
}