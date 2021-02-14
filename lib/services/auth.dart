import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mwloadouts/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create User object based on FirebaseUser
  WZUser _userFromFirebaseUser(User user) {
    print("In the _userFromFirebaseUser() function");
    print(user);
    return user != null ? WZUser(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<WZUser> get user {
    // return _auth.onAuthStateChanged.map(
    //   (User user) => _userFromFirebaseUser(user),
    // );
    _auth.authStateChanges().listen((User user) {
      if (user == null) {
        print('user is currently signed out');
        return null;
      } else {
        print('user is currently signed in!');
        return _userFromFirebaseUser(user);
      }
    });
  }

  // sign in with Email and Password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      print("Email is: " + email);
      print("Password is: " + password);
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register with Email and Password
  Future registerWithEmailAndPassword(String email, String password) async {
    print("auth.dart: starting 'registerWithEmailAndPassword()");
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      print("auth.dart: User is registered and retreived");
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future signOut() async {
    try {
      await _auth.signOut();
      // return await _auth.signOut();
      return _userFromFirebaseUser(null);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
