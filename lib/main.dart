import 'package:flutter/material.dart';
import 'features/authentication/pages/login_page.dart';
import 'features/main/pages/main_navigation_page.dart';

void main() {
  runApp(const BaksoAngkringanApp());
}

class BaksoAngkringanApp extends StatelessWidget {
  const BaksoAngkringanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bakso Angkringan',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const LoginPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
            );
          case '/home':
            final data =
                settings.arguments as Map<String, dynamic>;
            final customer =
                data['data'] as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (_) => MainNavigationPage(
                userName: customer['nama'] ?? '',
                noHp: customer['no_hp'] ?? '',
                kodeReferral: customer['kode_referral'] ?? '',
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}