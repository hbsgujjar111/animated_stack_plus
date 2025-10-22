import 'package:flutter/material.dart';

/// A custom FAB overlay system that slides the main content
/// to reveal a column and row of action buttons.
/// Inspired by the original `animated_stack` package.
class AnimatedStack extends StatefulWidget {
  /// The horizontal space (in pixels) that the revealed action buttons will occupy
  /// when the FAB is opened. Controls how far the foreground slides to the left.
  final double scaleWidth;

  /// The vertical space (in pixels) that the revealed action buttons will occupy
  /// when the FAB is opened. Controls how far the foreground slides upwards.
  final double scaleHeight;

  /// The main app UI shown initially. This widget is animated away when the FAB opens.
  /// Typically your `Scaffold` or main screen content goes here.
  final Widget foregroundWidget;

  /// A builder function that returns the column of vertical FAB actions (top-right).
  /// The `closeFab` callback should be called inside your buttons to close the FAB stack.
  final Widget Function(VoidCallback closeFab) columnWidgetBuilder;

  /// A builder function that returns the bottom row of FAB actions (bottom-right).
  /// The `closeFab` callback is passed to help automatically close the FAB on interaction.
  final Widget Function(VoidCallback closeFab) bottomWidgetBuilder;

  /// The background color behind the sliding foreground content.
  /// This color fills the area where FAB action buttons appear.
  final Color backgroundColor;

  /// The background color of the Floating Action Button.
  final Color fabBackgroundColor;

  /// The icon shown on the FAB when it's closed (e.g., menu icon).
  final Icon fabOpenIcon;

  /// The icon shown on the FAB when it's open (e.g., close icon).
  final Icon fabCloseIcon;

  /// Duration of the sliding animation when opening/closing the FAB.
  /// Controls how long the foreground takes to slide away.
  final Duration slideAnimationDuration;

  /// The curve (easing) used when opening the FAB. Affects animation style.
  /// For example, use `Curves.easeOutBack` for a springy opening.
  final Curve openAnimationCurve;

  /// The curve (easing) used when closing the FAB.
  /// For example, use `Curves.easeIn` for a smoother return.
  final Curve closeAnimationCurve;

  /// If true, tapping anywhere outside the FAB menu will automatically close it.
  /// Only works if `preventForegroundInteractions` is also true.
  final bool enableClickToDismiss;

  /// If true, prevents interaction with the `foregroundWidget` while the FAB is open.
  /// This is useful for enforcing focus on the FAB menu actions.
  final bool preventForegroundInteractions;

  /// Optional callback triggered whenever the FAB menu is closed manually or by tap.
  /// Can be used for side-effects like refreshing state or analytics tracking.
  final VoidCallback? onForegroundCallback;

  const AnimatedStack({
    super.key,
    this.scaleWidth = 60,
    this.scaleHeight = 60,
    required this.columnWidgetBuilder,
    required this.bottomWidgetBuilder,
    required this.foregroundWidget,
    required this.backgroundColor,
    required this.fabBackgroundColor,
    required this.fabOpenIcon,
    required this.fabCloseIcon,
    this.slideAnimationDuration = const Duration(milliseconds: 800),
    this.openAnimationCurve = const ElasticOutCurve(0.9),
    this.closeAnimationCurve = const ElasticInCurve(0.9),
    this.enableClickToDismiss = true,
    this.preventForegroundInteractions = true,
    this.onForegroundCallback,
  }) : assert(scaleHeight >= 40, 'scaleHeight must be at least 40'),
       assert(
         !(enableClickToDismiss && !preventForegroundInteractions),
         'enableClickToDismiss can only be true if preventForegroundInteractions is true',
       );

  @override
  State<AnimatedStack> createState() => _AnimatedStackState();
}

class _AnimatedStackState extends State<AnimatedStack> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideOffset;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: widget.slideAnimationDuration);

    // Define the offset for slide animation, updated later with screen size
    _slideOffset = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_animationController);
  }

  /// Toggle FAB open/close state
  void _toggle() {
    setState(() {
      _opened = !_opened;
    });

    if (_opened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      widget.onForegroundCallback?.call();
    }
  }

  /// Close FAB from child widgets
  void _closeFab() {
    if (_opened) _toggle();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate percentage movement based on screen size
    final mediaQuery = MediaQueryData.fromView(View.of(context));
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final xScale = ((widget.scaleWidth + 32) / screenWidth);
    final yScale = ((widget.scaleHeight + 32) / screenHeight);

    // Re-define slide offset on every build
    _slideOffset = Tween<Offset>(begin: Offset.zero, end: Offset(-xScale, -yScale)).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.openAnimationCurve,
        reverseCurve: widget.closeAnimationCurve,
      ),
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _toggle,
        backgroundColor: widget.fabBackgroundColor,
        child: _opened ? widget.fabCloseIcon : widget.fabOpenIcon,
      ),
      body: Stack(
        children: [
          // Background layer (with buttons)
          Container(
            color: widget.backgroundColor,
            child: Stack(
              children: [
                // Top Column Buttons
                Positioned(
                  bottom: widget.scaleHeight + 20,
                  right: 16,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: widget.scaleWidth),
                    child: widget.columnWidgetBuilder(_closeFab),
                  ),
                ),

                // Bottom Row Buttons
                Positioned(
                  right: widget.scaleWidth + 20,
                  bottom: 24,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: widget.scaleHeight - 16),
                    child: widget.bottomWidgetBuilder(_closeFab),
                  ),
                ),
              ],
            ),
          ),

          // Foreground UI (slides away)
          SlideTransition(
            position: _slideOffset,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (widget.enableClickToDismiss && _opened) {
                  _closeFab();
                }
              },
              child: IgnorePointer(
                ignoring: widget.preventForegroundInteractions && _opened,
                child: widget.foregroundWidget,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
