import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_keys.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase untuk Push Notification
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Daftarkan background messaging handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Inisialisasi Supabase (Ganti URL & Anon Key dengan project Supabase Anda)
  await Supabase.initialize(
    url: 'https://gbywcfvycbeilebvpjfc.supabase.co',
    anonKey: 'sb_publishable_C3kGXEv6SaZDu_w3-kvwTg_hSICG-g-'
  );
  
  runApp(const KosFinderApp());
}

class KosFinderApp extends StatelessWidget {
  const KosFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KosFinder',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      // Cek Session: Jika sudah login langsung ke HomePage, jika belum ke LoginPage
      home: AuthService.instance.isLoggedIn
          ? const HomePage()
          : const LoginPage(),
    );
  }
}