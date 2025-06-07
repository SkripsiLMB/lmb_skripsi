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
    await _db.collection('users').doc(user.nik).set({
      'name': user.name,
      'email': user.email,
      'created_at': user.createdAt,
    });
    }

  // NOTE: Ambil data user pake nik
  Future<LmbUser> getUserByNik(BuildContext context, String nik) async {
    final snapshot = await _db.collection('users').doc(nik).get();
    if (!snapshot.exists) {
      WindowProvider.toastError(context, "Your account has invalidity please contact admin");
    }

    final data = snapshot.data() as Map<String, dynamic>;
    return LmbUser(
      name: data['name'] ?? 'Unknown User',
      nik: nik,
      email: data['email'] ?? '-',
      createdAt: (data['created_at'] as Timestamp?)?.toDate().toLocal() ?? DateTime.now(),
    );
  }

  // NOTE: Ambil data user pake email
  Future<LmbUser?> getUserByEmail(BuildContext context, String email) async {
    final query = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      WindowProvider.toastError(context, "No user found with the provided email.");
      return null;
    }

    final doc = query.docs.first;
    final data = doc.data();

    return LmbUser(
      name: data['name'] ?? 'Unknown User',
      nik: doc.id,
      email: email,
      createdAt: (data['created_at'] as Timestamp?)?.toDate().toLocal() ?? DateTime.now(),
    );
  }

  // NOTE: update data user pake email
  Future<void> updateUserField(String nik, String field, dynamic value) async {
    await FirebaseFirestore.instance.collection('users').doc(nik).update({field: value});
  }
}