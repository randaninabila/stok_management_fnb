
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'utils/app_theme.dart';

import 'screens/auth/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NuTrackApp());
}

class NuTrackApp extends StatelessWidget {
  const NuTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NuTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      home: const AuthWrapper(),

      routes: {
        '/register': (context) => const Scaffold(
          body: Center(
            child: Text('Register Page sedang dibuat'),
          ),
        ),
      },
    );
  }
}
