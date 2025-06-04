// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/ui/snackbar_handler.dart';

class AuthenticatorService {
  AuthenticatorService._privateConstructor();
  static final AuthenticatorService _instance = AuthenticatorService._privateConstructor();
  factory AuthenticatorService() {
    return _instance;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<User?> handleLogin(BuildContext context, String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      LmbSnackbar.onError(context, e.message ?? 'Login failed');
      return null;
    } catch (e) {
      LmbSnackbar.onError(context, 'An unknown error occurred');
      return null;
    }
  }

  Future<User?> handleRegister(BuildContext context, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      LmbSnackbar.onError(context, e.message ?? 'Create account failed');
      return null;
    } catch (e) {
      LmbSnackbar.onError(context, 'An unknown error occurred');
      return null;
    }
  }

  Future<void> handleForgotPassword(BuildContext context, String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      LmbSnackbar.onSuccess(context, 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      LmbSnackbar.onError(context, e.message ?? 'Failed to send reset email');
    } catch (e) {
      LmbSnackbar.onError(context, 'An unknown error occurred');
    }
  }

  Future<void> handleLogout() async {
    await _auth.signOut();
  }
}