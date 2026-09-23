import 'package:flutter/material.dart';
import 'features/authentication/pages/login_page.dart';

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
    );
  }
}