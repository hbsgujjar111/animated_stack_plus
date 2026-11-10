import 'package:animated_stack_plus/animated_stack_plus.dart';
import 'package:flutter/material.dart';

// Global ScaffoldMessengerState key allows posting SnackBar notifications
// from background actions that lack direct BuildContext access. Created once,
// outside build, so it survives rebuilds.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  // Lets the app open/close the menu from outside the widget.
  final AnimatedStackController _controller = AnimatedStackController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'AnimatedStackPlus Example',
      debugShowCheckedModeBanner: false,
      home: AnimatedStack(
        controller: _controller,
        backgroundColor: Colors.grey[200]!,
        fabBackgroundColor: Colors.teal,
        openTooltip: 'Open menu',
        closeTooltip: 'Close menu',

        // Custom Widgets (allowing complete design freedom over standard Icon constraints)
        fabOpenWidget: const Icon(Icons.menu, color: Colors.white),
        fabCloseWidget: const Icon(Icons.close, color: Colors.white),

        // How far the foreground slides (on top of FAB size + spacing).
        scaleWidth: 60,
        scaleHeight: 60,

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
          backgroundColor: Colors.teal[50]!,
          appBar: AppBar(
            title: const Text(
              'AnimatedStackPlus Example',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.teal,
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                const Text(
                  'Hello World',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                ElevatedButton(
                  onPressed: _controller.toggle,
                  child: const Text('Open menu from code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
