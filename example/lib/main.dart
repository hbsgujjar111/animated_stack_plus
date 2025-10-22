import 'package:animated_stack_plus/animated_stack_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create the global key
    final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey, // assign the key
      title: 'AnimatedStackPlus Example',
      home: AnimatedStack(
        backgroundColor: Colors.grey[200]!,
        fabBackgroundColor: Colors.teal,
        fabOpenIcon: const Icon(Icons.menu, color: Colors.white),
        fabCloseIcon: const Icon(Icons.close, color: Colors.white),
        scaleWidth: 100,
        scaleHeight: 100,

        // Column of buttons (top stack)
        columnWidgetBuilder: (closeFab) => Column(
          spacing: 20,
          children: [
            IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () {
                closeFab();
                scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Share button pressed')));
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

        // Row of buttons (bottom stack)
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

        // Foreground main screen
        foregroundWidget: Scaffold(
          appBar: AppBar(
            title: const Text('AnimatedStackPlus Example', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.teal,
            centerTitle: true,
          ),
          body: const Center(child: Text('Hello World')),
        ),
      ),
    );
  }
}
