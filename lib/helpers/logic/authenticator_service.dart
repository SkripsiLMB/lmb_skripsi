// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/logic/firestore_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/ui/snackbar_handler.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';

class AuthenticatorService {
  // NOTE: Properti singleton
  AuthenticatorService._privateConstructor();
  static final AuthenticatorService _instance = AuthenticatorService._privateConstructor();
  static AuthenticatorService get instance => _instance;

  // NOTE: Properti firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // NOTE: Variable
  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // NOTE: untuk login
  Future<User?> handleLogin(BuildContext context, String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final userData = await FirestoreService.instance.getUserByEmail(context, email);
      await LmbLocalStorage.setValue<LmbUser>("user_data", userData, toJson: (user) => user.toJson());
      return credential.user;
    } on FirebaseAuthException catch (e) {
      LmbSnackbar.onError(context, '[${e.code}] ${e.message}', e);
      return null;
    } catch (e) {
      LmbSnackbar.onError(context, 'An unknown error occurred', e);
      return null;
    }
  }

  // NOTE: untuk register
  Future<User?> handleRegister(BuildContext context, String name, String nik, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final userData = LmbUser(name: name, nik: nik, email: email, createdAt: DateTime.now());
      await FirestoreService.instance.setUserData(user: userData);
      await LmbLocalStorage.setValue<LmbUser>("user_data", userData, toJson: (user) => user.toJson());
      return credential.user;
    } on FirebaseAuthException catch (e) {
      LmbSnackbar.onError(context, '[${e.code}] ${e.message}', e);
      return null;
    } catch (e) {
      LmbSnackbar.onError(context, 'An unknown error occurred', e);
      return null;
    }
  }

  // NOTE: untuk lupa password
  Future<bool> handleForgotPassword(BuildContext context, String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      LmbSnackbar.onError(context, '[${e.code}] ${e.message}', e);
      return false;
    } catch (e) {
      LmbSnackbar.onError(context, 'An unknown error occurred', e);
      return false;
    }
  }

  // NOTE: untuk keluar
  Future<void> handleLogout() async {
    await _auth.signOut();
    await LmbLocalStorage.deleteValue("user_data");
    await LmbLocalStorage.setValue<bool>("remember_me", false);
  }

  // NOTE: untuk verif email
  Future<bool> handleEmailVerification(BuildContext context) async {
    const countKey = 'email_verification_count';
    const dateKey = 'email_verification_date';

    final now = DateTime.now();
    final today = now.toIso8601String().split('T').first;

    final storedDate = await LmbLocalStorage.getValue<String>(dateKey) ?? today;
    int count = await LmbLocalStorage.getValue<int>(countKey) ?? 0;

    if (storedDate != today) {
      count = 0;
      await LmbLocalStorage.setValue<String>(dateKey, today);
      await LmbLocalStorage.setValue<int>(countKey, count);
    }

    if (count >= 3) {
      LmbSnackbar.onError(context, 'Daily limit of 3 verification emails reached.');
      return false;
    }

    try {
      await currentUser?.sendEmailVerification();
      await LmbLocalStorage.setValue<int>(countKey, count + 1);
      return true;
    } on FirebaseAuthException catch (e) {
      LmbSnackbar.onError(context, '[${e.code}] ${e.message}', e);
      return false;
    } catch (e) {
      LmbSnackbar.onError(context, 'An unknown error occurred', e);
      return false;
    }
  }
}