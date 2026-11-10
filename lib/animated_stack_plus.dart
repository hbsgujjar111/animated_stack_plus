/// An animated FAB stack for Flutter.
///
/// [AnimatedStack] slides your primary screen up and to the left when the
/// floating action button is tapped, revealing a column and a row of action
/// widgets behind it.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Default hero tag of the [AnimatedStack] FAB.
///
/// A private tag keeps the FAB from colliding with other floating action
/// buttons that use Flutter's default hero tag.
class _AnimatedStackHeroTag {
  const _AnimatedStackHeroTag();
}

/// Opens, closes and observes an [AnimatedStack] from outside the widget.
///
/// Create it, pass it as [AnimatedStack.controller] and dispose it when done.
/// Listeners are notified whenever [isOpen] changes.
///
/// ```dart
/// final controller = AnimatedStackController();
/// // ...
/// AnimatedStack(controller: controller, /* ... */);
/// // ...
/// controller.toggle();
/// ```
class AnimatedStackController extends ChangeNotifier {
  _AnimatedStackState? _state;
  bool _isOpen = false;

  /// Whether the menu is open (or opening).
  bool get isOpen => _isOpen;

  /// Opens the menu. Does nothing if it is open or no [AnimatedStack] is
  /// attached.
  void open() => _state?._setOpen(true);

  /// Closes the menu. Does nothing if it is closed or no [AnimatedStack] is
  /// attached.
  void close() => _state?._setOpen(false);

  /// Opens the menu if it is closed, closes it if it is open.
  void toggle() {
    final state = _state;
    if (state != null) state._setOpen(!state._opened);
  }

  void _attach(_AnimatedStackState state) {
    _state = state;
    _isOpen = state._opened;
  }

  void _detach(_AnimatedStackState state) {
    if (identical(_state, state)) {
      _state = null;
      // Silent on purpose: this runs while the widget tree is being torn down.
      _isOpen = false;
    }
  }

  void _update(bool open) {
    if (_isOpen == open) return;
    _isOpen = open;
    notifyListeners();
  }
}

/// A highly customizable overlay layout that slides your primary UI (foreground)
/// outward to reveal background action rows and columns behind it.
///
/// The foreground slides by `scale + fabSize + actionsSpacing` on each axis
/// (optionally capped by [maxSlideFraction]). The actions are drawn in the
/// [Scaffold] FAB slot, above the foreground, so a column taller than
/// [scaleHeight] (or a row wider than [scaleWidth]) simply overlays the
/// foreground. Keep the scale values small, or set [maxSlideFraction], if you
/// have many actions and do not want the foreground to move far.
///
/// Items in the column should be no wider than [fabSize], and items in the row
/// no taller than [fabSize].
///
/// The layout mirrors in right-to-left text directions. While the menu is open
/// the system back button closes it (see [closeOnBackPress]).
class AnimatedStack extends StatefulWidget {
  /// Extra horizontal distance (in pixels) the foreground slides towards the
  /// start side (left in LTR), on top of [fabSize] and [actionsSpacing]. The
  /// total slide is `scaleWidth + fabSize + actionsSpacing`.
  final double scaleWidth;

  /// Extra vertical distance (in pixels) the foreground slides up, on top of
  /// [fabSize] and [actionsSpacing]. The total slide is
  /// `scaleHeight + fabSize + actionsSpacing`. Must be at least 40.
  final double scaleHeight;

  /// Optional cap on the foreground slide, as a fraction of the available
  /// width and height (for example `0.3` for at most 30% of each axis).
  ///
  /// Use it when you have many actions and do not want the foreground to move
  /// far off screen. Must be greater than 0 and at most 1. When null, the slide
  /// is never capped.
  final double? maxSlideFraction;

  /// The primary application UI shown initially (usually your [Scaffold] or screen container).
  /// This widget translates away along the slide animation offset.
  final Widget foregroundWidget;

  /// A builder callback returning the vertical stack of action buttons.
  /// The [closeFab] callback should be called inside your buttons to close the menu.
  ///
  /// It is only called while the menu is open (and while it fades out when
  /// [animateActions] is true).
  final Widget Function(VoidCallback closeFab) columnWidgetBuilder;

  /// A builder callback returning the horizontal row of action buttons.
  /// The [closeFab] callback should be called inside your buttons to close the menu.
  ///
  /// It is only called while the menu is open (and while it fades out when
  /// [animateActions] is true).
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

  /// If true, tapping the foreground or the revealed background area while the
  /// menu is open closes it.
  /// Requires [preventForegroundInteractions] to be enabled.
  final bool enableClickToDismiss;

  /// If true, disables user interactions with [foregroundWidget] while the menu is open.
  final bool preventForegroundInteractions;

  /// Optional overlay color to dim the foreground widget when the FAB is open.
  /// Set to [Colors.transparent] to disable dimming.
  final Color foregroundDimColor;

  /// Optional callback triggered whenever the FAB menu is closed.
  @Deprecated('Use onClose instead. Will be removed in 2.0.0.')
  final VoidCallback? onForegroundCallback;

  /// Called when the menu starts opening.
  final VoidCallback? onOpen;

  /// Called when the menu starts closing (by the FAB, a dismiss tap, the back
  /// button, an action calling `closeFab`, or the [controller]).
  final VoidCallback? onClose;

  /// Optional controller to open, close and observe the menu from outside.
  final AnimatedStackController? controller;

  /// If true (default), the system back button closes an open menu instead of
  /// popping the route.
  final bool closeOnBackPress;

  /// If true, the actions fade in and out in sync with the slide animation.
  /// Defaults to false (actions appear and disappear instantly).
  ///
  /// The action builders run on every animation frame while this is enabled and
  /// the menu is animating, so keep them cheap.
  final bool animateActions;

  /// Tooltip (and accessibility label) of the FAB while the menu is closed.
  final String? openTooltip;

  /// Tooltip (and accessibility label) of the FAB while the menu is open.
  final String? closeTooltip;

  /// Hero tag of the FAB. Defaults to a tag private to this package so it does
  /// not collide with other floating action buttons. Pass null to disable the
  /// hero animation.
  final Object? heroTag;

  /// The dimensions of your Floating Action Button. Defaults to [56.0] (Material standard).
  final double fabSize;

  /// The margin space (in pixels) separating your main FAB from your background actions.
  final double actionsSpacing;

  /// Creates an [AnimatedStack].
  ///
  /// Asserts that [scaleHeight] is at least 40, that [maxSlideFraction] (when
  /// set) is in the range (0, 1], and that [enableClickToDismiss] is only true
  /// when [preventForegroundInteractions] is also true.
  const AnimatedStack({
    super.key,
    this.scaleWidth = 60,
    this.scaleHeight = 60,
    this.maxSlideFraction,
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
    this.onOpen,
    this.onClose,
    this.controller,
    this.closeOnBackPress = true,
    this.animateActions = false,
    this.openTooltip,
    this.closeTooltip,
    this.heroTag = const _AnimatedStackHeroTag(),
    this.fabSize = 56.0,
    this.actionsSpacing = 16.0,
  }) : assert(scaleHeight >= 40, 'scaleHeight must be at least 40'),
       assert(
         (maxSlideFraction ?? 1) > 0 && (maxSlideFraction ?? 1) <= 1,
         'maxSlideFraction must be greater than 0 and at most 1',
       ),
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

    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant AnimatedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
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
      // Release the replaced animation's status listener on the controller.
      oldCurved.dispose();
    }
  }

  /// Opens or closes the menu and fires the matching animation and callbacks.
  void _setOpen(bool open) {
    // Callers (e.g. async action callbacks) may run after this widget is gone.
    if (!mounted || _opened == open) return;
    setState(() {
      _opened = open;
    });
    widget.controller?._update(open);

    if (open) {
      _animationController.forward();
      widget.onOpen?.call();
    } else {
      _animationController.reverse();
      widget.onClose?.call();
      // ignore: deprecated_member_use_from_same_package
      widget.onForegroundCallback?.call();
    }
  }

  void _toggle() => _setOpen(!_opened);

  /// Exposed callback used by children to close the menu.
  void _closeFab() => _setOpen(false);

  void _dismissFromTap() {
    if (widget.enableClickToDismiss && _opened) _setOpen(false);
  }

  /// Slide distance on one axis, optionally capped by [maxSlideFraction].
  double _slideDistance(double total, double extent) {
    final fraction = widget.maxSlideFraction;
    if (fraction == null || !extent.isFinite) return total;
    return math.min(total, extent * fraction);
  }

  Widget _wrapActions(Widget child) {
    if (!widget.animateActions) return child;
    return IgnorePointer(
      ignoring: !_opened,
      child: FadeTransition(opacity: _animationController, child: child),
    );
  }

  Widget _buildFabSlot() {
    final double actionsOffset = widget.fabSize + widget.actionsSpacing;
    // With animateActions the actions stay mounted while the close animation
    // runs; otherwise they exist only while the menu is open.
    final bool showActions =
        _opened || (widget.animateActions && !_animationController.isDismissed);

    // The slot is a Stack sized by its non-positioned children, so its bounds
    // always cover the FAB plus whatever actions are currently revealed.
    // Scaffold hit-tests the slot within those bounds only, so every action
    // must lie inside them to be tappable.
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        // Vertical column, centered horizontally above the primary FAB.
        if (showActions)
          _wrapActions(
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: actionsOffset),
              child: SizedBox(
                width: widget.fabSize,
                child: UnconstrainedBox(
                  constrainedAxis: Axis.horizontal,
                  child: widget.columnWidgetBuilder(_closeFab),
                ),
              ),
            ),
          ),

        // Horizontal row, centered vertically beside the primary FAB.
        if (showActions)
          _wrapActions(
            Padding(
              padding: EdgeInsetsDirectional.only(end: actionsOffset),
              child: SizedBox(
                height: widget.fabSize,
                child: UnconstrainedBox(
                  constrainedAxis: Axis.vertical,
                  child: widget.bottomWidgetBuilder(_closeFab),
                ),
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
            heroTag: widget.heroTag,
            tooltip: _opened ? widget.closeTooltip : widget.openTooltip,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final double slideX =
        widget.scaleWidth + widget.fabSize + widget.actionsSpacing;
    final double slideY =
        widget.scaleHeight + widget.fabSize + widget.actionsSpacing;

    return PopScope(
      // While open, the back button closes the menu instead of popping.
      canPop: !(_opened && widget.closeOnBackPress),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.closeOnBackPress) _setOpen(false);
      },
      child: Scaffold(
        // Placing the menu inside the Scaffold's FAB slot ensures that everything shifts
        // upward in perfect unison when SnackBars, persistent bottom sheets, or keyboard offsets occur.
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: widget.animateActions
            ? AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => _buildFabSlot(),
              )
            : _buildFabSlot(),
        body: Stack(
          children: [
            // Background canvas behind sliding main content. Tapping the
            // revealed area dismisses the menu.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _dismissFromTap,
              child: ColoredBox(
                color: widget.backgroundColor,
                child: const SizedBox.expand(),
              ),
            ),

            // Primary Foreground UI layer (utilizes performance-optimized translation)
            LayoutBuilder(
              builder: (context, constraints) {
                final double distanceX = _slideDistance(
                  slideX,
                  constraints.maxWidth,
                );
                final double distanceY = _slideDistance(
                  slideY,
                  constraints.maxHeight,
                );
                return AnimatedBuilder(
                  animation: _animationController,
                  child: widget.foregroundWidget,
                  builder: (context, child) {
                    final double t = _curvedAnimation.value;
                    return Transform.translate(
                      offset: Offset(
                        (rtl ? distanceX : -distanceX) * t,
                        -distanceY * t,
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _dismissFromTap,
                        child: IgnorePointer(
                          ignoring:
                              widget.preventForegroundInteractions && _opened,
                          child: Stack(
                            children: [
                              child!,
                              // Smoothly fades in a dimming layer over the foreground UI as it slides away
                              if (widget.foregroundDimColor !=
                                  Colors.transparent)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    ignoring: true,
                                    child: Container(
                                      color: widget.foregroundDimColor
                                          .withValues(
                                            alpha:
                                                (widget.foregroundDimColor.a *
                                                        _animationController
                                                            .value)
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _animationController.dispose();
    _curvedAnimation.dispose();
    super.dispose();
  }
}
