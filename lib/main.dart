import 'package:firebase_core/firebase_core.dart';
import 'package:fishery_management_client/auth/login_page.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "soil-monitoring-9a1a4",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// To Change - Package name and change App name in AndroidManifest.xml

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LogInPage(),
    );
  }
}
