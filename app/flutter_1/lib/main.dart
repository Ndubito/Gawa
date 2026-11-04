import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_1/firebase_options.dart';
import 'app.dart';

// Local testing only: skips reCAPTCHA so Firebase *test* phone numbers can sign
// in. Real numbers stop working while this is on. Opt in per run with
// --dart-define=DISABLE_APP_VERIFICATION=true; never set it for a release.
const _disableAppVerification = bool.fromEnvironment('DISABLE_APP_VERIFICATION');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (_disableAppVerification) {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }
  runApp(App());
}
