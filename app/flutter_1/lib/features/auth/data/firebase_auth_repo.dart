import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_1/features/auth/domain/entities/app_user.dart';
import 'package:flutter_1/features/auth/domain/repos/auth_repo.dart';


/*
  FIREBASE IS OUR AUTHENTICATION BACKEND
*/

class FirebaseAuthRepo extends AuthRepo {
  //access to firebase
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //DELETE ACCOUNT
  @override
  Future<void> deleteAccount() async{
    try {
      //get current user
      final user = firebaseAuth.currentUser;

      //check if there is a logged in user
      if (user == null) throw Exception('No user logged in');

      //delete account
      await user.delete();

      //logout
      await logout();
    } catch (e) {
      throw Exception('Failed to delete accont: $e');
    }
  }
  
  //GET CURRENT USER
  @override
  Future<AppUser?> getCurrentUser() async{
    try {
      //get current logged in user from firebase
      final user = firebaseAuth.currentUser;

      //no logged in user
      if (user ==null) return null;

      return AppUser(uid: user.uid, email: user.email!);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  //LOGIN: Email and Password 
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      //attemp sign-in
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //create user
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);

      //return user
      return user;
      
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  // LOGOUT
  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
  //REGISTER: Email and Password
  @override
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password) async{
    try {
      //attempt sign-up
      UserCredential userCredential = await firebaseAuth.
      createUserWithEmailAndPassword(email: email, password: password);

      //create user
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);

      //return user
      return user;
    
    //find any errors
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // RESET PASSWORD
  @override
  Future<String> sendPasswordResetEmail(String email) async{
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email sent! Check your inbox.";
    } catch (e) {
      return 'An error has occured: $e';  
    }
  }
}
