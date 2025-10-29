import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  static const Color primaryColor = Color(0xFF2E6D80);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asset Borrowing System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primaryColor: primaryColor,
        scaffoldBackgroundColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),


      home: const LoginPage(userType: 'Staff'),
    );
  }
}
