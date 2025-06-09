// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/logic/firestore_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
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

  // NOTE: Handle user data
  LmbUser? _userData;
  LmbUser? get userData => _userData;
  final StreamController<LmbUser?> _userDataController = StreamController<LmbUser?>.broadcast();
  Stream<LmbUser?> get userDataStream => _userDataController.stream;  

  set userData(LmbUser? value) {
    _userData = value;
    _userDataController.add(value);
  }
 
  void dispose() {
    _userDataController.close();
  }

  // NOTE: Update stream user data
  Future<void> setUserData(LmbUser userData) async {
    await LmbLocalStorage.setValue<LmbUser>("user_data", userData, toJson: (user) => user.toJson());
    this.userData = userData;
  }

  // NOTE: Set stream user data awal
  Future<void> initializeUserData(BuildContext context) async {
  final localUserData = await LmbLocalStorage.getValue<LmbUser>(
    "user_data",
    fromJson: (json) => LmbUser.fromJson(json),
  );

  final userNik = localUserData?.nik;

  if (userNik != null) {
    try {
      final firestoreUser = await FirestoreService.instance.getUserByNik(context, userNik);
      setUserData(firestoreUser);
    } catch (e) {
      userData = localUserData;
      WindowProvider.toastError(context, "Limited access due to an error", e);
    }
  } else {
    if (currentUser != null) {
      WindowProvider.toastError(context, "Session expired, please log in again");
    }
    handleLogout();
  }
}

  // NOTE: untuk login
  Future<User?> handleLogin(BuildContext context, String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final userData = await FirestoreService.instance.getUserByEmail(context, email);
      if (userData == null) {
        WindowProvider.toastError(context, 'Something went wrong');
        return null;
      }
      await setUserData(userData);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      WindowProvider.toastError(context, '[${e.code}] ${e.message}', e);
      return null;
    } catch (e) {
      WindowProvider.toastError(context, 'An unknown error occurred', e);
      return null;
    }
  }

  // NOTE: untuk register
  Future<User?> handleRegister(BuildContext context, String name, String nik, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final userData = LmbUser(name: name, nik: nik, email: email, createdAt: DateTime.now());
      await FirestoreService.instance.setUserData(user: userData);
      await setUserData(userData);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      WindowProvider.toastError(context, '[${e.code}] ${e.message}', e);
      return null;
    } catch (e) {
      WindowProvider.toastError(context, 'An unknown error occurred', e);
      return null;
    }
  }

  // NOTE: untuk lupa password
  Future<bool> handleForgotPassword(BuildContext context, String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      WindowProvider.toastError(context, '[${e.code}] ${e.message}', e);
      return false;
    } catch (e) {
      WindowProvider.toastError(context, 'An unknown error occurred', e);
      return false;
    }
  }

  // NOTE: untuk keluar
  Future<void> handleLogout() async {
    await _auth.signOut();
    await LmbLocalStorage.clearAllValue();
    userData = null;
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
      WindowProvider.toastError(context, 'Daily limit of 3 verification emails reached.');
      return false;
    }

    try {
      await currentUser?.sendEmailVerification();
      await LmbLocalStorage.setValue<int>(countKey, count + 1);
      return true;
    } on FirebaseAuthException catch (e) {
      WindowProvider.toastError(context, '[${e.code}] ${e.message}', e);
      return false;
    } catch (e) {
      WindowProvider.toastError(context, 'An unknown error occurred', e);
      return false;
    }
  }

  // NOTE: Change email
  Future<bool> handleChangeEmail(BuildContext context, String newEmail, String password) async {
    try {
      try {
        await _auth.signInWithEmailAndPassword(email: newEmail, password: password);
      } on FirebaseAuthException catch (e) {
        WindowProvider.toastError(context, '[${e.code}] ${e.message}', e);
        handleLogout();
        return false;
      } catch (e) {
        WindowProvider.toastError(context, 'An unknown error occurred', e);
        return false;
      }
      await currentUser?.updateEmail(newEmail);
      await currentUser?.sendEmailVerification();
      final userData = await LmbLocalStorage.getValue<LmbUser>("user_data", fromJson: (json) => LmbUser.fromJson(json));
      final userEmail = userData?.email;
      if (userEmail != null) {
        await FirestoreService.instance.updateUserField(userEmail, 'email', newEmail);
        await currentUser?.reload();
        return true;
      } else {
        WindowProvider.toastError(context, 'Something went wrong');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      WindowProvider.toastError(context, '[${e.code}] ${e.message}', e);
      return false;
    } catch (e) {
      WindowProvider.toastError(context, 'An unknown error occurred', e);
      return false;
    }
  }

  // NOTE: Change name
  Future<bool> handleChangeName(BuildContext context, String newName) async {
    try {
      final userData = await LmbLocalStorage.getValue<LmbUser>("user_data", fromJson: (json) => LmbUser.fromJson(json));
      final userNik = userData?.nik;
      if (userNik != null) {
        await FirestoreService.instance.updateUserField(userNik, 'name', newName);
        final userData = await FirestoreService.instance.getUserByNik(context, userNik);
        await setUserData(userData);
        return true;
      } else {
        WindowProvider.toastError(context, 'Something went wrong');
        return false;
      }
    } catch (e) {
      WindowProvider.toastError(context, 'Failed to update name.', e);
      return false;
    }
  }

  // NOTE: Paksa stream reload
  void forceReloadUserDataStream() {
    _userDataController.add(_userData);
  }
}