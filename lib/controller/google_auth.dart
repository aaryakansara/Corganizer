import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corganizer/controller/google_drive.dart';
import 'package:corganizer/pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth auth = FirebaseAuth.instance;
CollectionReference users = FirebaseFirestore.instance.collection('users');

// changing return type to void
// as bool was not needed here
Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);

      final UserCredential authResult =
          await auth.signInWithCredential(credential);

      final User? user = authResult.user;
      // Call GoogleDrive functions here
      final googleDrive = GoogleDrive();
      googleDrive.init();
      googleDrive.createMainFolder();

      var userData = {
        'name': googleSignInAccount.displayName,
        'provider': 'google',
        'photoUrl': googleSignInAccount.photoUrl,
        'email': googleSignInAccount.email,
      };

      users.doc(user?.uid).get().then((doc) async {
        if (doc.exists) {
          // old user
          doc.reference.update(userData);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(url: '', did: '', type: '',),
            ),
          );
        } else {
          // new user

          users.doc(user?.uid).set(userData);

          // Call GoogleDrive functions here
          final googleDrive = GoogleDrive();
          await googleDrive.init();
          await googleDrive.createMainFolder();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(url: '', did: '', type: '',),
            ),
          );
        }
      });
    }
  } catch (platformException) {
    if (kDebugMode) {
      print(platformException);
    }
    if (kDebugMode) {
      print("Sign in not successful !");
    }
    // better show an alert here
  }
}

// new function to sign out user
Future<void> signOutUser(BuildContext context) async {
  try {
    // sign out from firebase
    await auth.signOut();
    // sign out from google
    await googleSignIn.signOut();

    // navigate to the login page
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (Route<dynamic> route) => false,
    );
  } catch (platformException) {
    if (kDebugMode) {
      print(platformException);
    }
    // better show an alert here
  }
}

// new function to switch account
Future<void> switchAccount(BuildContext context) async {
  try {
    // sign out from firebase
    await auth.signOut();
    // sign out from google
    await googleSignIn.signOut();
    // navigate to the login page
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (Route<dynamic> route) => false,
    );
    // sign in with google
    await signInWithGoogle(context);
  } catch (platformException) {
    if (kDebugMode) {
      print(platformException);
    }
    // better show an alert here
  }
}
