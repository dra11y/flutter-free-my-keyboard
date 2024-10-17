import 'package:flutter/material.dart';
import 'package:free_my_keyboard/free_my_keyboard.dart';

void main() {
  freeMyKeyboard();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(
          child: Text('Free My Keyboard!'),
        ),
      ),
    );
  }
}
