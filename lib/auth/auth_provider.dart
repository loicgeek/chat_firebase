import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    var result = await _auth.signInWithCredential(credential);
    await saveUserData(result);

    notifyListeners();
    return result;
  }

  saveUserData(UserCredential cred) async {
    try {
      var user = cred.user!;
      var _usersRef = _firestore.collection("users");
      var userDoc = await _usersRef.doc(user.uid).get();
      if (!userDoc.exists) {
        await _usersRef.doc(user.uid).set({
          "id": user.uid,
          "name": user.displayName,
          "email": user.email,
          "created_at": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print(e);
      log(e.toString());
    }
  }

  logout() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _auth.signOut(),
    ]);
    notifyListeners();
  }
}
