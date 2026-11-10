# animated_stack_plus

[![pub version](https://img.shields.io/pub/v/animated_stack_plus.svg)](https://pub.dev/packages/animated_stack_plus)
[![likes](https://img.shields.io/pub/likes/animated_stack_plus.svg)](https://pub.dev/packages/animated_stack_plus/score)

**[Live web demo](https://hbsgujjar111.github.io/animated_stack_plus/)**

![AnimatedStackPlus Demo Mobile](example/mobile-example.gif)
![AnimatedStackPlus Demo Web](example/web-example.gif)

A flexible and modern **animated Floating Action Button (FAB) stack menu** for Flutter — inspired by
the original [`animated_stack`](https://pub.dev/packages/animated_stack), but fully rebuilt with
customizable builders, animations, and interaction handling.

---

## Features

- Beautiful **FAB-based sliding stack**
- Customizable **top (column)** and **bottom (row)** action layouts
- Easy `closeFab()` callback passed to all actions
- Separate **open/close FAB widgets** (not just IconData)
- Fully configurable **animation duration**, **curves**, and **background colors**
- Safe foreground interaction with optional **fading dim overlay**
- **Click outside to dismiss** the FAB menu (foreground or revealed background)
- **`AnimatedStackController`** to open, close and observe the menu from code
- **Back button closes** an open menu (optional)
- **Right-to-left** layouts supported
- Optional **fading actions**, **tooltips** and **hero tag** control
- Optional **`maxSlideFraction`** so many actions don't push the foreground off screen
- **Native SnackBar support** (entire menu shifts together in unison with Scaffold layout shifts)
- Works on **Android**, **iOS**, **web**, and **desktop**
- Modern Flutter compatibility (Dart 3.x with updated SDK parameters)

---

## Getting Started

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  animated_stack_plus: ^1.2.0
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

## Usage Example

Here’s a complete working example:

```dart
import 'package:animated_stack_plus/animated_stack_plus.dart';
import 'package:flutter/material.dart';

// Created once (not inside build) so it survives rebuilds.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'AnimatedStackPlus Example',
      debugShowCheckedModeBanner: false,
      home: AnimatedStack(
        backgroundColor: Colors.grey[200]!,
        fabBackgroundColor: Colors.teal,
        // Accept generic widgets instead of icons
        fabOpenWidget: const Icon(Icons.menu, color: Colors.white),
        fabCloseWidget: const Icon(Icons.close, color: Colors.white),
        scaleWidth: 60,
        scaleHeight: 60,
        // extra slide distance (see Layout notes below)

        // Column of buttons (top stack)
        columnWidgetBuilder: (closeFab) =>
            Column(
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
        bottomWidgetBuilder: (closeFab) =>
            Row(
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

## Parameters

| Name                            | Type                                     | Description                                                                                                               | Default                       |
|---------------------------------|------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|-------------------------------|
| `foregroundWidget`              | `Widget`                                 | Main content shown under the FAB stack                                                                                    | Required                      |
| `columnWidgetBuilder`           | `Widget Function(VoidCallback closeFab)` | Builder for vertical (top) actions                                                                                        | Required                      |
| `bottomWidgetBuilder`           | `Widget Function(VoidCallback closeFab)` | Builder for horizontal (bottom) actions                                                                                   | Required                      |
| `backgroundColor`               | `Color`                                  | The background canvas color behind the sliding UI                                                                         | Required                      |
| `fabBackgroundColor`            | `Color`                                  | FAB background color                                                                                                      | Required                      |
| `fabOpenWidget`                 | `Widget`                                 | Custom widget shown inside FAB when the menu is closed                                                                    | Required                      |
| `fabCloseWidget`                | `Widget`                                 | Custom widget shown inside FAB when the menu is open                                                                      | Required                      |
| `scaleWidth` / `scaleHeight`    | `double`                                 | Extra distance the foreground slides left / up, on top of `fabSize + actionsSpacing`. `scaleHeight` must be >= 40         | `60` / `60`                   |
| `fabSize`                       | `double`                                 | The width and height of the Floating Action Button                                                                        | `56.0`                        |
| `actionsSpacing`                | `double`                                 | Spacing separation between FAB and action buttons                                                                         | `16.0`                        |
| `foregroundDimColor`            | `Color`                                  | Optional color overlay to dim foreground UI on open                                                                       | `Colors.transparent`          |
| `slideAnimationDuration`        | `Duration`                               | Duration of the slide animation                                                                                           | `Duration(milliseconds: 800)` |
| `openAnimationCurve`            | `Curve`                                  | Curve when opening the FAB stack                                                                                          | `Curves.easeOut`              |
| `closeAnimationCurve`           | `Curve`                                  | Curve when closing the FAB stack                                                                                          | `Curves.easeInOut`            |
| `enableClickToDismiss`          | `bool`                                   | Whether tapping the foreground or the revealed background closes the menu. Requires `preventForegroundInteractions: true` | `true`                        |
| `preventForegroundInteractions` | `bool`                                   | Prevents UI below the FAB from interaction when open                                                                      | `true`                        |
| `onForegroundCallback`          | `VoidCallback?`                          | Deprecated, use `onClose`. Removed in 2.0.0                                                                               | `null`                        |
| `onOpen` / `onClose`            | `VoidCallback?`                          | Called when the menu starts opening / closing                                                                             | `null`                        |
| `controller`                    | `AnimatedStackController?`               | Open, close and observe the menu from code                                                                                | `null`                        |
| `maxSlideFraction`              | `double?`                                | Caps the foreground slide to this fraction (0, 1] of the width/height                                                     | `null`                        |
| `closeOnBackPress`              | `bool`                                   | The system back button closes an open menu                                                                                | `true`                        |
| `animateActions`                | `bool`                                   | Fade actions in and out with the slide                                                                                    | `false`                       |
| `openTooltip` / `closeTooltip`  | `String?`                                | FAB tooltip while closed / open                                                                                           | `null`                        |
| `heroTag`                       | `Object?`                                | FAB hero tag; `null` disables the hero animation                                                                          | package-private tag           |

### Layout notes

The foreground slides by `scale + fabSize + actionsSpacing` on each axis. The actions are drawn
above the foreground, so you can add as many as you like: actions beyond the slid area simply
overlay
the foreground (pair this with `foregroundDimColor`). Keep `scaleWidth` / `scaleHeight` small if you
have many actions and do not want the foreground to move far. Items in the column should be no wider
than `fabSize`, and items in the row no taller than `fabSize`.

### Controller

```dart
class _MyScreenState extends State<MyScreen> {
  final controller = AnimatedStackController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedStack(
      controller: controller,
      // ... other required parameters
      foregroundWidget: ElevatedButton(
        onPressed: controller.toggle, // also open(), close() and isOpen
        child: const Text('Toggle menu'),
      ),
    );
  }
}
```

### Known limitations

- Actions appear and disappear instantly unless you set `animateActions: true`.
- There is no overlay blur; use `foregroundDimColor` to dim the foreground.

---

## Inspired By

This package is based on the original [`animated_stack`](https://pub.dev/packages/animated_stack) by
**Emadeddin Eibo** (MIT), and keeps its core idea and public parameter names. The implementation was
rewritten:

- Builder-based architecture for dynamic UI
- Any widget as the FAB content (not just `IconData`)
- Standard Material FAB slot with SnackBar alignment support
- Animations that react to changes in scale, curves and duration
- Defaults that satisfy the widget's own assertions
- Controller, back-button handling, RTL support and accessibility options

---

## License

MIT License. Includes the original `animated_stack` copyright notice (see `LICENSE`).

---

## Contributions Welcome

Found a bug or want to improve this widget?  
Open an issue or pull request on GitHub:

👉 [github.com/hbsgujjar111/animated_stack_plus](https://github.com/hbsgujjar111/animated_stack_plus)
