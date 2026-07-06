import 'package:animated_stack_plus/animated_stack_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Global ScaffoldMessengerState Key allows posting SnackBar notifications
    // globally from background actions that lack direct nestedBuildContext access.
    final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
        GlobalKey<ScaffoldMessengerState>();

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'AnimatedStackPlus Example',
      debugShowCheckedModeBanner: false,
      home: AnimatedStack(
        backgroundColor: Colors.grey[200]!,
        fabBackgroundColor: Colors.teal,

        // Custom Widgets (allowing complete design freedom over standard Icon constraints)
        fabOpenWidget: const Icon(Icons.menu, color: Colors.white),
        fabCloseWidget: const Icon(Icons.close, color: Colors.white),

        // Decoupled spacing definitions
        scaleWidth: 60,
        scaleHeight: 40,
        // Expanded height to comfortably accommodate vertical action rows
        // Vertical action buttons builder
        columnWidgetBuilder: (closeFab) => Column(
          spacing: 20,
          children: [
            IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () {
                closeFab(); // Automatically closes the menu drawer
                scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(content: Text('Share button pressed')),
                );
              },
              icon: const Icon(Icons.share, color: Colors.white),
            ),
            IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                closeFab();
                scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(content: Text('Contact button pressed')),
                );
              },
              icon: const Icon(Icons.call, color: Colors.white),
            ),
          ],
        ),

        // Horizontal action buttons builder
        bottomWidgetBuilder: (closeFab) => Row(
          children: [
            IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                closeFab();
                scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(content: Text('Message button pressed')),
                );
              },
              icon: const Icon(Icons.message, color: Colors.white),
            ),
          ],
        ),

        // Your main application scaffold which translates back during active FAB states
        foregroundWidget: Scaffold(
          appBar: AppBar(
            title: const Text(
              'AnimatedStackPlus Example',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.teal,
            centerTitle: true,
          ),
          body: const Center(
            child: Text(
              'Hello World',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
