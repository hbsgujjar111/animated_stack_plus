# animated_stack_plus

[![pub version](https://img.shields.io/pub/v/animated_stack_plus.svg)](https://pub.dev/packages/animated_stack_plus)
[![likes](https://img.shields.io/pub/likes/animated_stack_plus.svg)](https://pub.dev/packages/animated_stack_plus/score)

![AnimatedStackPlus Demo](example/mobile-example.gif)

A flexible and modern **animated Floating Action Button (FAB) stack menu** for Flutter — inspired by the original [`animated_stack`](https://pub.dev/packages/animated_stack), but fully rebuilt with customizable builders, animations, and interaction handling.

---

## 🚀 Features

- Beautiful **FAB-based sliding stack**
- Customizable **top (column)** and **bottom (row)** action layouts
- Easy `closeFab()` callback passed to all actions
- Separate **open/close FAB icons** as full Widgets (not just IconData)
- Fully configurable **animation duration**, **curves**, and **background color**
- Safe foreground interaction with optional blocking overlay
- **Click outside to dismiss** the FAB menu
- Works on **mobile**, **tablet**, and **web**
- Modern Flutter compatibility with updated APIs

---

## 🧩 Getting Started

### Installation

Add to your `pubspec.yaml`:
```yaml
dependencies:
  animated_stack_plus: ^1.0.0
```

Then run:
```bash
flutter pub get
```

Import it:
```dart
import 'package:animated_stack_plus/animated_stack_plus.dart';
```

---

## 💡 Usage Example

Here’s a complete working example:

```dart
import 'package:animated_stack_plus/animated_stack_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
        GlobalKey<ScaffoldMessengerState>();

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
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
            title: const Text('AnimatedStackPlus Example',
                style: TextStyle(color: Colors.white)),
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

---

## ⚙️ Parameters

| Name                            | Type                                     | Description                                          |
|---------------------------------|------------------------------------------|------------------------------------------------------|
| `foregroundWidget`              | `Widget`                                 | Main content shown under the FAB stack               |
| `columnWidgetBuilder`           | `Widget Function(VoidCallback closeFab)` | Builder for vertical (top) actions                   |
| `bottomWidgetBuilder`           | `Widget Function(VoidCallback closeFab)` | Builder for horizontal (bottom) actions              |
| `fabBackgroundColor`            | `Color`                                  | FAB background color                                 |
| `fabOpenIcon`                   | `Widget`                                 | Icon widget when the menu is closed                  |
| `fabCloseIcon`                  | `Widget`                                 | Icon widget when the menu is open                    |
| `scaleWidth` / `scaleHeight`    | `double`                                 | How much the foreground scales when FAB opens        |
| `slideAnimationDuration`        | `Duration`                               | Duration of the slide animation                      |
| `openAnimationCurve`            | `Curve`                                  | Curve when opening the FAB stack                     |
| `closeAnimationCurve`           | `Curve`                                  | Curve when closing the FAB stack                     |
| `enableClickToDismiss`          | `bool`                                   | Whether tapping outside closes the menu              |
| `preventForegroundInteractions` | `bool`                                   | Prevents UI below the FAB from interaction when open |
| `onForegroundCallback`          | `VoidCallback?`                          | Called when the FAB stack closes                     |

---

## 🧠 Inspired By

This package is based on the original [`animated_stack`](https://pub.dev/packages/animated_stack) by **Emadeddin Eibo**, but rebuilt with:
- Builder-based architecture for dynamic UI
- Modern Flutter compatibility
- Better tap handling and callbacks
- Full control over icons, animations, and layout

---

## 📜 License
MIT License

---

## 🤝 Contributions Welcome

Found a bug or want to improve this widget?  
Open an issue or pull request on GitHub:

👉 [github.com/hbsgujjar111/animated_stack_plus](https://github.com/hbsgujjar111/animated_stack_plus)
