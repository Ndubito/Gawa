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
  Future<void> deleteAccount() async {
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
  Future<AppUser?> getCurrentUser() async {
    try {
      //get current logged in user from firebase
      final user = firebaseAuth.currentUser;

      //no logged in user
      if (user == null) return null;

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
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      //attempt sign-up
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

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
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email sent! Check your inbox.";
    } catch (e) {
      return 'An error has occured: $e';
    }
  }


  //verify user's phone number
  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
  }) async {
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      //handle verification success
      verificationCompleted: (PhoneAuthCredential credential) async {
        await firebaseAuth.signInWithCredential(credential);
      },
      //handle errors
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(e.message ?? 'Verification failed');
      },
      //what to do when SMS code is sent to user
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      //what do do if inactive
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  //LOGIN with phone number using OTP
  @override
  Future<AppUser?> verifyOtp(String verificationId, String smsCode) async {
    try {
      //get credentials
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      //attempt sign in with credentials
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user == null) return null;

      //create user
      return AppUser(uid: user.uid, phone: user.phoneNumber);

    //handle errors
    } on Exception catch (e) {
      throw Exception("Failed to log in: $e");
    }
  }
}
