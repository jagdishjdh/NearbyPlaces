import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:nearby_places/services/database.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseUser user;
  static String errorMsg = '';


  // auth change user stream
  Stream<FirebaseUser> get userStream {
    return _auth.onAuthStateChanged;
  }
  AuthService(){
    initialize();
  }

  void initialize() async{
    user = await _auth.currentUser();
  }

  // sign in anonymous
//  Future signInAnon() async {
//    try {
//      AuthResult result = await _auth.signInAnonymously();
//      FirebaseUser user = result.user;
//      return user;
//    } catch (e) {
//      errorMsg = e.toString();
//      print(e.toString());
//      return null;
//    }
//  }

  // register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      await DatabaseService().updateUserData();
      return user;
    } catch (e) {
      handleError(e);
      print("registerWithEmailAndPassword Error : $e");
      return null;
    }
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      return user;
    }catch(e){
      handleError(e);
      print("signInWithEmailAndPassword Error : $e");
      return null;
    }
  }

  // sign in with google

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      handleError(e);
      print("Logout Error $e");
      return null;
    }
  }

  void handleError(e){
    if(e.runtimeType == PlatformException){
      errorMsg = e.message;
    }
    else{
      errorMsg = e.toString();
    }
  }
}
