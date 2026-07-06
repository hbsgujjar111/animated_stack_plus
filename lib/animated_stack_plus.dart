import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A custom [Stack] designed to resolve Flutter's touch clipping behavior.
///
/// By default, when widgets paint outside their parent bounds (using [Clip.none]),
/// standard Flutter hit-testing rejects any pointer/tap events occurring outside those bounds.
/// [_OverflowTouchStack] overrides this behavior to allow overflowing action
/// buttons to remain completely interactive.
class _OverflowTouchStack extends Stack {
  const _OverflowTouchStack({super.children = const <Widget>[]})
    : super(alignment: Alignment.bottomRight, clipBehavior: Clip.none);

  @override
  RenderStack createRenderObject(BuildContext context) {
    return _RenderOverflowTouchStack(
      alignment: alignment,
      textDirection: textDirection,
      fit: fit,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderOverflowTouchStack renderObject,
  ) {
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection
      ..fit = fit
      ..clipBehavior = clipBehavior;
  }
}

/// The low-level rendering proxy implementation of [_OverflowTouchStack].
///
/// It overrides the default [hitTest] method of [RenderBox] which restricts
/// pointer events to the standard bounding box (`size.contains(position)`).
/// Instead, it forwards hit-testing requests straight to its children regardless of bounds,
/// but preserves standard hit-testing transparency on empty background space.
class _RenderOverflowTouchStack extends RenderStack {
  _RenderOverflowTouchStack({
    super.alignment,
    super.textDirection,
    super.fit,
    super.clipBehavior,
  });

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Bypass the typical size boundary check to check overflowing children.
    // If a child is tapped (even if outside the container's formal dimensions),
    // we capture the hit and register the tap event.
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}

/// A highly customizable overlay layout that slides your primary UI (foreground)
/// outward to reveal background action rows and columns behind it.
class AnimatedStack extends StatefulWidget {
  /// The horizontal space (in pixels) that the revealed bottom row action
  /// buttons will occupy when the FAB menu is opened.
  final double scaleWidth;

  /// The vertical space (in pixels) that the revealed top column action
  /// buttons will occupy when the FAB menu is opened.
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
      _curvedAnimation = CurvedAnimation(
        parent: _animationController,
        curve: widget.openAnimationCurve,
        reverseCurve: widget.closeAnimationCurve,
      );
      _updateSlideOffset();
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
    if (_opened) _toggle();
  }

  @override
  Widget build(BuildContext context) {
    // Establish a cohesive bounding box for the entire interactive menu stack.
    // Standard FAB layouts read this size to position the widget relative to the screen.
    final double largeWidth =
        widget.scaleWidth + widget.fabSize + widget.actionsSpacing;
    final double largeHeight =
        widget.scaleHeight + widget.fabSize + widget.actionsSpacing;

    return Scaffold(
      // Placing the menu inside the Scaffold's FAB slot ensures that everything shifts
      // upward in perfect unison when SnackBars, persistent bottom sheets, or keyboard offsets occur.
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: SizedBox(
        width: largeWidth,
        height: largeHeight,
        child: _OverflowTouchStack(
          children: [
            // Vertical Column Stack (centered horizontally above the primary FAB)
            Positioned(
              bottom: widget.fabSize + widget.actionsSpacing,
              right: 0,
              child: SizedBox(
                width: widget.fabSize,
                child: Align(
                  alignment: Alignment
                      .center, // Automatically centers the column horizontally
                  child: Visibility(
                    visible: _opened,
                    child: widget.columnWidgetBuilder(_closeFab),
                  ),
                ),
              ),
            ),

            // Horizontal Row Stack (centered vertically to the left of the primary FAB)
            Positioned(
              right: widget.fabSize + widget.actionsSpacing,
              bottom: 0,
              child: SizedBox(
                height: widget.fabSize,
                child: Align(
                  alignment: Alignment
                      .center, // Automatically centers the row vertically
                  child: Visibility(
                    visible: _opened,
                    child: widget.bottomWidgetBuilder(_closeFab),
                  ),
                ),
              ),
            ),

            // Main FAB Trigger (handles visual transitions between open/closed widget states)
            Positioned(
              bottom: 0,
              right: 0,
              child: SizedBox(
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
            ),
          ],
        ),
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
