# animated_stack_plus

[![pub version](https://img.shields.io/pub/v/animated_stack_plus.svg)](https://pub.dev/packages/animated_stack_plus)
[![likes](https://img.shields.io/pub/likes/animated_stack_plus.svg)](https://pub.dev/packages/animated_stack_plus/score)

An enhanced and customizable **sliding FAB stack menu** for Flutter — inspired by the original [`animated_stack`](https://pub.dev/packages/animated_stack) package.

---

## Features
- Beautiful **FAB-based sliding stack**
- Customizable **top (column)** and **bottom (row)** actions
- Easy `closeFab()` callback passed to all buttons
- Configurable **FAB icons** for both Open/Close state
- Control animation duration, curves, background color
- Responsive on **mobile** & **web**
- Safe support for foreground UI interaction
- **Click outside to dismiss** FAB menu

---

## Getting Started

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  animated_stack_plus: ^1.0.0
```
Then run:
  flutter pub get

Import it
```import 'package:animated_stack_plus/animated_stack_plus.dart';
```


Usage

Here’s a full working example:
```
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
```

Parameters

| Name                            | Type                                     | Description                                   |
|---------------------------------|------------------------------------------|-----------------------------------------------|
| `foregroundWidget`              | `Widget`                                 | Main content under the FAB stack              |
| `columnWidgetBuilder`           | `Widget Function(VoidCallback closeFab)` | Builder for vertical actions (above FAB)      |
| `bottomWidgetBuilder`           | `Widget Function(VoidCallback closeFab)` | Builder for horizontal actions (beside FAB)   |
| `fabBackgroundColor`            | `Color`                                  | FAB button background color                   |
| `fabOpenIcon`                   | `IconData`                               | FAB icon when menu is closed                  |
| `fabCloseIcon`                  | `IconData`                               | FAB icon when menu is open                    |
| `scaleWidth` / `scaleHeight`    | `double`                                 | How much the foreground shifts when FAB opens |
| `slideAnimationDuration`        | `Duration`                               | Duration of sliding animation                 |
| `openAnimationCurve`            | `Curve`                                  | Curve when opening the FAB stack              |
| `closeAnimationCurve`           | `Curve`                                  | Curve when closing the FAB stack              |
| `enableClickToDismiss`          | `bool`                                   | Tapping outside the stack closes it           |
| `preventForegroundInteractions` | `bool`                                   | Blocks UI below stack while open              |
| `onForegroundCallback`          | `VoidCallback?`                          | Called when FAB stack closes                  |


Inspired By
This package is inspired by animated_stack created by Emadeddin Eibo.

This rework improves on:
- Modern Flutter compatibility
- Custom builder-based approach
- Better tap handling and callbacks
- Full control of Open/Close state icon
- More control over animations and layout

License
MIT License

Contributions Welcome
Found a bug or want to improve this widget?

Feel free to open issues at:
https://github.com/hbsgujjar111/animated_stack_plus