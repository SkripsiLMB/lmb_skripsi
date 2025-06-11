import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
import 'package:lmb_skripsi/model/lmb_loan.dart';
import 'package:lmb_skripsi/model/lmb_product.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_mandatory_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_principal_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_saving_history.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_voluntary_saving.dart';
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

  // NOTE: nambah loan ke user
  Future<void> addLoanToUser(LmbLoan model) async {
    final userRef = _db.collection('users').doc(model.loanMaker.nik);
    final loansCollection = userRef.collection('loans');
    await loansCollection.add(model.toJson());
  }

  // NOTE: Ambil loan dari user
  Future<List<LmbLoan>> getLoanList({int? limit}) async {
    final userData = await LmbLocalStorage.getValue<LmbUser>("user_data", fromJson: (json) => LmbUser.fromJson(json));
    final userRef = _db.collection('users').doc(userData?.nik ?? "");
    Query query = userRef.collection('loans').orderBy('created_at', descending: true);
    if (limit != null) {
      query = query.limit(limit);
    }

    final querySnapshot = await query.get();
    final loans = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return LmbLoan.fromJson(data, userData, id: doc.id);
    }).toList();

    return loans;
  }

  // NOTE: Bayar cicilan trus hapus kalo lunas
  Future<bool?> payLoanInstallment(LmbLoan loan) async {
    final userRef = _db.collection('users').doc(loan.loanMaker.nik);
    final loansCollection = userRef.collection('loans');
    
    if (loan.id == null) return null;
    final docRef = loansCollection.doc(loan.id);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      return null;
    }

    final currentCounter = loan.paymentCounter;
    final totalMonths = loan.loanInterestPeriod.months;

    if (currentCounter + 1 >= totalMonths) {
      await docRef.delete(); // Loan fully paid
      return false;
    } else {
      await docRef.update({'payment_counter': currentCounter + 1});
      return true;
    }
  }

  // NOTE: Ambil product
  Future<List<LmbProduct>> getProductList({int? limit}) async {
    Query query = _db
    .collection('products')
    .orderBy('name');
    if (limit != null) {
      query = query.limit(limit);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return LmbProduct.fromJson(data..['id'] = doc.id);
    }).toList();
  }

  // NOTE: Ambil Saving
  Future<LmbMandatorySaving> getMandatorySaving(String nik) async {
    final doc = await _db.collection('users').doc(nik).collection('savings').doc('mandatory').get();
    return LmbMandatorySaving.fromJson(doc.data() ?? {});
  }

  Future<LmbPrincipalSaving> getPrincipalSaving(String nik) async {
    final doc = await _db.collection('users').doc(nik).collection('savings').doc('principal').get();
    return LmbPrincipalSaving.fromJson(doc.data() ?? {});
  }

  Future<LmbVoluntarySaving> getVoluntarySaving(String nik) async {
    final doc = await _db.collection('users').doc(nik).collection('savings').doc('voluntary').get();
    return LmbVoluntarySaving.fromJson(doc.data() ?? {});
  }

  Future<List<LmbSavingHistory>> getSavingHistory() async {
    final user = await LmbLocalStorage.getValue<LmbUser>(
      "user_data",
      fromJson: (json) => LmbUser.fromJson(json),
    );
    final nik = user?.nik ?? "";

    final mandatory = await FirestoreService.instance.getMandatorySaving(nik);
    final principal = await FirestoreService.instance.getPrincipalSaving(nik);
    final voluntary = await FirestoreService.instance.getVoluntarySaving(nik);

    final combined = [
      ...mandatory.history,
      ...principal.history,
      ...voluntary.history,
    ];

    combined.sort((a, b) => b.date.compareTo(a.date)); // Sort by latest first

    return combined;
  }
}