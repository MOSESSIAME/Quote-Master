import 'package:flutter/material.dart';
import 'screens/welcome_page.dart';
import 'screens/home_screen.dart'; // Your home screen

/// The entry point of the QuoteMaster app.
void main() {
  runApp(const MyApp());
}

/// Root widget of the app.
/// Sets up routing, theming, and the initial landing page.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuoteMaster',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Sets the main color theme
      ),
      // Define named routes for navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(), // Landing page
        '/home': (context) => const HomeScreen(), // Main quotations page
      },
      debugShowCheckedModeBanner: false, // Hide debug banner
    );
  }
}