/// An animated FAB stack for Flutter.
///
/// [AnimatedStack] slides your primary screen up and to the left when the
/// floating action button is tapped, revealing a column and a row of action
/// widgets behind it.
library;

import 'package:flutter/material.dart';

/// A highly customizable overlay layout that slides your primary UI (foreground)
/// outward to reveal background action rows and columns behind it.
///
/// The foreground slides by `scale + fabSize + actionsSpacing` on each axis.
/// The actions are drawn in the [Scaffold] FAB slot, above the foreground, so
/// a column taller than [scaleHeight] (or a row wider than [scaleWidth]) simply
/// overlays the foreground. Keep the scale values small if you have many
/// actions and do not want the foreground to move far.
///
/// Items in the column should be no wider than [fabSize], and items in the row
/// no taller than [fabSize].
class AnimatedStack extends StatefulWidget {
  /// Extra horizontal distance (in pixels) the foreground slides to the left,
  /// on top of [fabSize] and [actionsSpacing]. The total slide is
  /// `scaleWidth + fabSize + actionsSpacing`.
  final double scaleWidth;

  /// Extra vertical distance (in pixels) the foreground slides up, on top of
  /// [fabSize] and [actionsSpacing]. The total slide is
  /// `scaleHeight + fabSize + actionsSpacing`. Must be at least 40.
  final double scaleHeight;

  /// The primary application UI shown initially (usually your [Scaffold] or screen container).
  /// This widget translates away along the slide animation offset.
  final Widget foregroundWidget;

  /// A builder callback returning the vertical stack of action buttons.
  /// The [closeFab] callback should be called inside your buttons to close the menu.
  final Widget Function(VoidCallback closeFab) columnWidgetBuilder;

  /// A builder callback returning the horizontal row of action buttons.
  /// The [closeFab] callback should be called inside your buttons to close the menu.
  final Widget Function(VoidCallback closeFab) bottomWidgetBuilder;

  /// The background color filling the area where your background buttons appear.
  final Color backgroundColor;

  /// The background color of the main [FloatingActionButton].
  final Color fabBackgroundColor;

  /// Any custom widget (e.g., an Icon, Svg, or Text) shown inside the FAB when closed.
  final Widget fabOpenWidget;

  /// Any custom widget (e.g., an Icon, Svg, or Text) shown inside the FAB when open.
  final Widget fabCloseWidget;

  /// Duration of the slide translation transition when opening and closing.
  final Duration slideAnimationDuration;

  /// Easing animation curve used when opening the FAB menu.
  final Curve openAnimationCurve;

  /// Easing animation curve used when closing the FAB menu.
  final Curve closeAnimationCurve;

  /// If true, tapping anywhere outside the FAB menu will automatically close it.
  /// Requires [preventForegroundInteractions] to be enabled.
  final bool enableClickToDismiss;

  /// If true, disables user interactions with [foregroundWidget] while the menu is open.
  final bool preventForegroundInteractions;

  /// Optional overlay color to dim the foreground widget when the FAB is open.
  /// Set to [Colors.transparent] to disable dimming.
  final Color foregroundDimColor;

  /// Optional callback triggered whenever the FAB menu is closed.
  final VoidCallback? onForegroundCallback;

  /// The dimensions of your Floating Action Button. Defaults to [56.0] (Material standard).
  final double fabSize;

  /// The margin space (in pixels) separating your main FAB from your background actions.
  final double actionsSpacing;

  /// Creates an [AnimatedStack].
  ///
  /// Asserts that [scaleHeight] is at least 40, and that
  /// [enableClickToDismiss] is only true when [preventForegroundInteractions]
  /// is also true.
  const AnimatedStack({
    super.key,
    this.scaleWidth = 60,
    this.scaleHeight = 60,
    required this.columnWidgetBuilder,
    required this.bottomWidgetBuilder,
    required this.foregroundWidget,
    required this.backgroundColor,
    required this.fabBackgroundColor,
    required this.fabOpenWidget,
    required this.fabCloseWidget,
    this.slideAnimationDuration = const Duration(milliseconds: 800),
    this.openAnimationCurve = Curves.easeOut,
    this.closeAnimationCurve = Curves.easeInOut,
    this.enableClickToDismiss = true,
    this.preventForegroundInteractions = true,
    this.foregroundDimColor = Colors.transparent,
    this.onForegroundCallback,
    this.fabSize = 56.0,
    this.actionsSpacing = 16.0,
  }) : assert(scaleHeight >= 40, 'scaleHeight must be at least 40'),
       assert(
         !(enableClickToDismiss && !preventForegroundInteractions),
         'enableClickToDismiss can only be true if preventForegroundInteractions is true',
       );

  @override
  State<AnimatedStack> createState() => _AnimatedStackState();
}

class _AnimatedStackState extends State<AnimatedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late CurvedAnimation _curvedAnimation;
  late Animation<Offset> _slideOffset;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.slideAnimationDuration,
    );

    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: widget.openAnimationCurve,
      reverseCurve: widget.closeAnimationCurve,
    );

    _updateSlideOffset();
  }

  /// Calculates the physical translation distance in pixels.
  ///
  /// Decoupling this from [MediaQuery] removes unnecessary rebuild passes
  /// during layout recalculations and prevents screen rotation jitter.
  void _updateSlideOffset() {
    _slideOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(
        -(widget.scaleWidth + widget.fabSize + widget.actionsSpacing),
        -(widget.scaleHeight + widget.fabSize + widget.actionsSpacing),
      ),
    ).animate(_curvedAnimation);
  }

  @override
  void didUpdateWidget(covariant AnimatedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slideAnimationDuration != widget.slideAnimationDuration) {
      _animationController.duration = widget.slideAnimationDuration;
    }
    if (oldWidget.openAnimationCurve != widget.openAnimationCurve ||
        oldWidget.closeAnimationCurve != widget.closeAnimationCurve) {
      final oldCurved = _curvedAnimation;
      _curvedAnimation = CurvedAnimation(
        parent: _animationController,
        curve: widget.openAnimationCurve,
        reverseCurve: widget.closeAnimationCurve,
      );
      _updateSlideOffset();
      // Release the replaced animation's status listener on the controller.
      oldCurved.dispose();
    } else if (oldWidget.scaleWidth != widget.scaleWidth ||
        oldWidget.scaleHeight != widget.scaleHeight ||
        oldWidget.fabSize != widget.fabSize ||
        oldWidget.actionsSpacing != widget.actionsSpacing) {
      _updateSlideOffset();
    }
  }

  /// Toggles the menu's open or closed state and fires animation steps.
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

  /// Exposed callback used by children to close the menu.
  void _closeFab() {
    // Action callbacks may complete asynchronously after this widget is gone.
    if (!mounted) return;
    if (_opened) _toggle();
  }

  @override
  Widget build(BuildContext context) {
    // Distance from the slot's bottom/right edge to the revealed actions.
    final double actionsOffset = widget.fabSize + widget.actionsSpacing;

    return Scaffold(
      // Placing the menu inside the Scaffold's FAB slot ensures that everything shifts
      // upward in perfect unison when SnackBars, persistent bottom sheets, or keyboard offsets occur.
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // The slot is a Stack sized by its non-positioned children, so its bounds
      // always cover the FAB plus whatever actions are currently revealed.
      // Scaffold hit-tests the slot within those bounds only, so every action
      // must lie inside them to be tappable.
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Vertical column, centered horizontally above the primary FAB.
          if (_opened)
            Padding(
              padding: EdgeInsets.only(bottom: actionsOffset),
              child: SizedBox(
                width: widget.fabSize,
                child: UnconstrainedBox(
                  constrainedAxis: Axis.horizontal,
                  child: widget.columnWidgetBuilder(_closeFab),
                ),
              ),
            ),

          // Horizontal row, centered vertically to the left of the primary FAB.
          if (_opened)
            Padding(
              padding: EdgeInsets.only(right: actionsOffset),
              child: SizedBox(
                height: widget.fabSize,
                child: UnconstrainedBox(
                  constrainedAxis: Axis.vertical,
                  child: widget.bottomWidgetBuilder(_closeFab),
                ),
              ),
            ),

          // Main FAB trigger (handles visual transitions between open/closed widget states)
          SizedBox(
            width: widget.fabSize,
            height: widget.fabSize,
            child: FloatingActionButton(
              onPressed: _toggle,
              backgroundColor: widget.fabBackgroundColor,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: _opened
                    ? KeyedSubtree(
                        key: const ValueKey('fab_close'),
                        child: widget.fabCloseWidget,
                      )
                    : KeyedSubtree(
                        key: const ValueKey('fab_open'),
                        child: widget.fabOpenWidget,
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background canvas behind sliding main content
          Container(color: widget.backgroundColor),

          // Primary Foreground UI layer (utilizes performance-optimized translation)
          AnimatedBuilder(
            animation: _animationController,
            child: widget.foregroundWidget,
            builder: (context, child) {
              return Transform.translate(
                offset: _slideOffset.value,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (widget.enableClickToDismiss && _opened) {
                      _closeFab();
                    }
                  },
                  child: IgnorePointer(
                    ignoring: widget.preventForegroundInteractions && _opened,
                    child: Stack(
                      children: [
                        child!,
                        // Smoothly fades in a dimming layer over the foreground UI as it slides away
                        if (widget.foregroundDimColor != Colors.transparent)
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: true,
                              child: Container(
                                color: widget.foregroundDimColor.withValues(
                                  alpha:
                                      (widget.foregroundDimColor.a *
                                              _animationController.value)
                                          .clamp(0.0, 1.0),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _curvedAnimation.dispose();
    super.dispose();
  }
}
