import 'package:ecosoftvmsstaff/services/firebase_options.dart';
import 'package:ecosoftvmsstaff/ui/SignInPage.dart';
import 'package:ecosoftvmsstaff/ui/StaffHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE1E8F0),
      ),
      home: (FirebaseAuth.instance.currentUser?.uid!=null)?const StaffHomeScreen():const StaffLogin()
    );
  }
}
//(FirebaseAuth.instance.currentUser?.uid!=null)?const StaffHomeScreen():
