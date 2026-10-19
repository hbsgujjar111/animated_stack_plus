import 'package:animated_stack_plus/animated_stack_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Keys & helpers
// ---------------------------------------------------------------------------
const _fgKey = Key('fg');
const _fgButtonKey = Key('fgButton');
const _colTopKey = Key('colTop');
const _colBottomKey = Key('colBottom');
const _rowLeftKey = Key('rowLeft');
const _rowRightKey = Key('rowRight');

class _Counts {
  int fg = 0;
  int colTop = 0;
  int colBottom = 0;
  int rowLeft = 0;
  int rowRight = 0;
  int closed = 0;
}

Widget _tile(Key key, VoidCallback onTap) => GestureDetector(
  key: key,
  behavior: HitTestBehavior.opaque,
  onTap: onTap,
  child: const SizedBox(
    width: 48,
    height: 48,
    child: ColoredBox(color: Colors.blue),
  ),
);

AnimatedStack _stack(
  _Counts c, {
  double scaleWidth = 60,
  double scaleHeight = 60,
  double fabSize = 56,
  double actionsSpacing = 16,
  bool enableClickToDismiss = true,
  bool preventForegroundInteractions = true,
  Color dim = Colors.transparent,
  Duration duration = const Duration(milliseconds: 800),
  Curve openCurve = Curves.easeOut,
  Curve closeCurve = Curves.easeInOut,
  void Function(VoidCallback close)? captureClose,
}) {
  return AnimatedStack(
    scaleWidth: scaleWidth,
    scaleHeight: scaleHeight,
    fabSize: fabSize,
    actionsSpacing: actionsSpacing,
    enableClickToDismiss: enableClickToDismiss,
    preventForegroundInteractions: preventForegroundInteractions,
    foregroundDimColor: dim,
    slideAnimationDuration: duration,
    openAnimationCurve: openCurve,
    closeAnimationCurve: closeCurve,
    backgroundColor: Colors.grey,
    fabBackgroundColor: Colors.teal,
    fabOpenWidget: const Icon(Icons.menu),
    fabCloseWidget: const Icon(Icons.close),
    onForegroundCallback: () => c.closed++,
    columnWidgetBuilder: (close) {
      captureClose?.call(close);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tile(_colTopKey, () {
            c.colTop++;
            close();
          }),
          const SizedBox(height: 20),
          _tile(_colBottomKey, () {
            c.colBottom++;
            close();
          }),
        ],
      );
    },
    bottomWidgetBuilder: (close) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tile(_rowLeftKey, () {
          c.rowLeft++;
          close();
        }),
        _tile(_rowRightKey, () {
          c.rowRight++;
          close();
        }),
      ],
    ),
    foregroundWidget: Container(
      key: _fgKey,
      color: Colors.white,
      child: Center(
        child: ElevatedButton(
          key: _fgButtonKey,
          onPressed: () => c.fg++,
          child: const Text('fg'),
        ),
      ),
    ),
  );
}

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) {
  return MaterialApp(
    builder: (context, w) =>
        Directionality(textDirection: direction, child: w!),
    home: child,
  );
}

final _fab = find.byType(FloatingActionButton);

Future<void> _toggle(WidgetTester tester) async {
  await tester.tap(_fab);
  await tester.pumpAndSettle();
}

bool _isRedDim(Widget w) =>
    w is ColoredBox && w.color.r > 0.99 && w.color.g < 0.01 && w.color.b < 0.01;

// Slide distance with defaults: scale(60) + fabSize(56) + spacing(16).
const _slide = 132.0;

void main() {
  group('defaults (documents code truth for README)', () {
    test('constructor defaults', () {
      final s = _stack(_Counts());
      expect(s.slideAnimationDuration, const Duration(milliseconds: 800));
      expect(s.openAnimationCurve, Curves.easeOut);
      expect(
        s.closeAnimationCurve,
        Curves.easeInOut,
      ); // README says easeInToLinear
      expect(s.fabSize, 56.0);
      expect(s.actionsSpacing, 16.0);
      expect(s.enableClickToDismiss, isTrue);
      expect(s.preventForegroundInteractions, isTrue);
      expect(s.foregroundDimColor, Colors.transparent);
    });
  });

  group('assertions (failure paths)', () {
    test('scaleHeight below 40 asserts', () {
      expect(() => _stack(_Counts(), scaleHeight: 39), throwsAssertionError);
    });
    test('click-to-dismiss without foreground blocking asserts', () {
      expect(
        () => _stack(
          _Counts(),
          enableClickToDismiss: true,
          preventForegroundInteractions: false,
        ),
        throwsAssertionError,
      );
    });
  });

  group('open / close', () {
    testWidgets('starts closed: no actions, menu icon, foreground at origin', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_stack(_Counts())));
      expect(find.byKey(_colTopKey), findsNothing);
      expect(find.byKey(_rowLeftKey), findsNothing);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(tester.getTopLeft(find.byKey(_fgKey)), Offset.zero);
    });

    testWidgets('FAB tap opens: actions visible, close icon, fg slid', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_stack(_Counts())));
      await _toggle(tester);
      expect(find.byKey(_colTopKey), findsOneWidget);
      expect(find.byKey(_rowLeftKey), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      final o = tester.getTopLeft(find.byKey(_fgKey));
      expect(o.dx, moreOrLessEquals(-_slide));
      expect(o.dy, moreOrLessEquals(-_slide));
    });

    testWidgets('second FAB tap closes and fires onForegroundCallback once', (
      tester,
    ) async {
      final c = _Counts();
      await tester.pumpWidget(_host(_stack(c)));
      await _toggle(tester);
      expect(c.closed, 0); // not fired on open
      await _toggle(tester);
      expect(c.closed, 1);
      expect(find.byKey(_colTopKey), findsNothing);
      expect(tester.getTopLeft(find.byKey(_fgKey)), Offset.zero);
    });

    testWidgets('closeFab from a bottom-column action closes the menu', (
      tester,
    ) async {
      final c = _Counts();
      await tester.pumpWidget(_host(_stack(c)));
      await _toggle(tester);
      await tester.tap(find.byKey(_colBottomKey));
      await tester.pumpAndSettle();
      expect(c.colBottom, 1);
      expect(c.closed, 1);
      expect(find.byKey(_colBottomKey), findsNothing);
    });

    testWidgets('closeFab when already closed is a no-op', (tester) async {
      final c = _Counts();
      late VoidCallback saved;
      await tester.pumpWidget(_host(_stack(c, captureClose: (f) => saved = f)));
      await _toggle(tester); // builders only run while open
      await _toggle(tester);
      expect(c.closed, 1);
      saved(); // already closed
      await tester.pumpAndSettle();
      expect(c.closed, 1);
    });

    testWidgets('mid-animation offset is between origin and target', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_stack(_Counts())));
      await tester.tap(_fab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final dx = tester.getTopLeft(find.byKey(_fgKey)).dx;
      expect(dx, lessThan(0));
      expect(dx, greaterThan(-_slide));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(_fgKey)).dx,
        moreOrLessEquals(-_slide),
      );
    });

    testWidgets('rapid double tap ends closed with callback once', (
      tester,
    ) async {
      final c = _Counts();
      await tester.pumpWidget(_host(_stack(c)));
      await tester.tap(_fab);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(_fab);
      await tester.pumpAndSettle();
      expect(c.closed, 1);
      expect(find.byKey(_colTopKey), findsNothing);
      expect(tester.getTopLeft(find.byKey(_fgKey)), Offset.zero);
    });

    testWidgets('toggles on every target platform', (tester) async {
      await tester.pumpWidget(_host(_stack(_Counts())));
      await _toggle(tester);
      expect(find.byKey(_colTopKey), findsOneWidget);
      await _toggle(tester);
      expect(find.byKey(_colTopKey), findsNothing);
    }, variant: TargetPlatformVariant.all());
  });

  group('foreground interaction', () {
    testWidgets(
      'tapping foreground while open dismisses and is not delivered',
      (tester) async {
        final c = _Counts();
        await tester.pumpWidget(_host(_stack(c)));
        await _toggle(tester);
        await tester.tap(find.byKey(_fgButtonKey), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(c.fg, 0);
        expect(c.closed, 1);
        expect(find.byKey(_colTopKey), findsNothing);
      },
    );

    testWidgets(
      'enableClickToDismiss=false keeps menu open, blocks foreground',
      (tester) async {
        final c = _Counts();
        await tester.pumpWidget(_host(_stack(c, enableClickToDismiss: false)));
        await _toggle(tester);
        await tester.tap(find.byKey(_fgButtonKey), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(c.fg, 0);
        expect(find.byKey(_colTopKey), findsOneWidget);
      },
    );

    testWidgets(
      'preventForegroundInteractions=false lets foreground receive taps',
      (tester) async {
        final c = _Counts();
        await tester.pumpWidget(
          _host(
            _stack(
              c,
              enableClickToDismiss: false,
              preventForegroundInteractions: false,
            ),
          ),
        );
        await _toggle(tester);
        await tester.tap(find.byKey(_fgButtonKey));
        await tester.pumpAndSettle();
        expect(c.fg, 1);
        expect(find.byKey(_colTopKey), findsOneWidget);
      },
    );

    testWidgets('foreground tappable when closed', (tester) async {
      final c = _Counts();
      await tester.pumpWidget(_host(_stack(c)));
      await tester.tap(find.byKey(_fgButtonKey));
      expect(c.fg, 1);
    });
  });

  group('dim overlay', () {
    testWidgets('alpha follows the animation', (tester) async {
      await tester.pumpWidget(
        _host(_stack(_Counts(), dim: const Color(0x80FF0000))),
      );
      ColoredBox dim() =>
          tester.widget<ColoredBox>(find.byWidgetPredicate(_isRedDim));
      expect(dim().color.a, moreOrLessEquals(0.0, epsilon: 0.001));
      await _toggle(tester);
      expect(dim().color.a, moreOrLessEquals(0.5, epsilon: 0.01));
      await _toggle(tester);
      expect(dim().color.a, moreOrLessEquals(0.0, epsilon: 0.001));
    });

    testWidgets('transparent dim builds no overlay', (tester) async {
      await tester.pumpWidget(_host(_stack(_Counts())));
      expect(find.byWidgetPredicate(_isRedDim), findsNothing);
    });
  });

  group('hit-testing of actions', () {
    testWidgets('action fully inside the slot bounds is tappable', (
      tester,
    ) async {
      final c = _Counts();
      await tester.pumpWidget(_host(_stack(c)));
      await _toggle(tester);
      await tester.tap(find.byKey(_colBottomKey)); // spans 72..120 of 132
      await tester.pumpAndSettle();
      expect(c.colBottom, 1);
    });

    testWidgets('action in the row inside bounds is tappable', (tester) async {
      final c = _Counts();
      await tester.pumpWidget(_host(_stack(c)));
      await _toggle(tester);
      await tester.tap(find.byKey(_rowRightKey)); // right-most, inside slot
      await tester.pumpAndSettle();
      expect(c.rowRight, 1);
    });

    // H1 (fixed in 1.1.2): top column button lies beyond the scaleHeight-based
    // slide area; the slot must still cover and hit-test it.
    testWidgets('column action beyond slot bounds is tappable (H1)', (
      tester,
    ) async {
      final c = _Counts();
      await tester.pumpWidget(_host(_stack(c)));
      await _toggle(tester);
      await tester.tap(find.byKey(_colTopKey));
      await tester.pumpAndSettle();
      expect(c.colTop, 1);
    });

    // H1 (fixed in 1.1.2): two 48px row tiles (96) vs scaleWidth 60.
    testWidgets('row action beyond slot bounds is tappable (H1)', (
      tester,
    ) async {
      final c = _Counts();
      await tester.pumpWidget(_host(_stack(c)));
      await _toggle(tester);
      await tester.tap(find.byKey(_rowLeftKey));
      await tester.pumpAndSettle();
      expect(c.rowLeft, 1);
    });
  });

  group('FAB slot size', () {
    testWidgets('closed slot is just the FAB; open slot covers the actions', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_stack(_Counts())));
      final slot = find.ancestor(
        of: _fab,
        matching: find.byWidgetPredicate(
          (w) => w is Stack && w.alignment == Alignment.bottomRight,
        ),
      );
      expect(tester.getSize(slot.first), const Size(56, 56));
      await _toggle(tester);
      final open = tester.getRect(slot.first);
      expect(open.contains(tester.getCenter(find.byKey(_colTopKey))), isTrue);
      expect(open.contains(tester.getCenter(find.byKey(_rowLeftKey))), isTrue);
    });
  });

  group('didUpdateWidget', () {
    testWidgets('changing scaleWidth/scaleHeight while open re-targets slide', (
      tester,
    ) async {
      final scale = ValueNotifier<double>(60);
      final c = _Counts();
      await tester.pumpWidget(
        _host(
          ValueListenableBuilder<double>(
            valueListenable: scale,
            builder: (context, v, child) =>
                _stack(c, scaleWidth: v, scaleHeight: v),
          ),
        ),
      );
      await _toggle(tester);
      expect(tester.getTopLeft(find.byKey(_fgKey)).dx, moreOrLessEquals(-132));
      scale.value = 100;
      await tester.pump();
      expect(tester.getTopLeft(find.byKey(_fgKey)).dx, moreOrLessEquals(-172));
    });

    testWidgets('changing curves keeps the menu working', (tester) async {
      final curve = ValueNotifier<Curve>(Curves.easeOut);
      final c = _Counts();
      await tester.pumpWidget(
        _host(
          ValueListenableBuilder<Curve>(
            valueListenable: curve,
            builder: (context, v, child) =>
                _stack(c, openCurve: v, closeCurve: v),
          ),
        ),
      );
      curve.value = Curves.linear;
      await tester.pump();
      await _toggle(tester);
      expect(
        tester.getTopLeft(find.byKey(_fgKey)).dx,
        moreOrLessEquals(-_slide),
      );
      await _toggle(tester);
      expect(tester.getTopLeft(find.byKey(_fgKey)), Offset.zero);
      expect(tester.takeException(), isNull);
    });

    testWidgets('changing duration applies to the next animation', (
      tester,
    ) async {
      final d = ValueNotifier<Duration>(const Duration(milliseconds: 800));
      await tester.pumpWidget(
        _host(
          ValueListenableBuilder<Duration>(
            valueListenable: d,
            builder: (context, v, child) => _stack(_Counts(), duration: v),
          ),
        ),
      );
      d.value = const Duration(milliseconds: 100);
      await tester.pump();
      await tester.tap(_fab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(
        tester.getTopLeft(find.byKey(_fgKey)).dx,
        moreOrLessEquals(-_slide),
      );
    });
  });

  group('sizing', () {
    // Expectation not run by the author: verify FAB honours fabSize.
    testWidgets('fabSize resizes the FAB', (tester) async {
      await tester.pumpWidget(_host(_stack(_Counts(), fabSize: 72)));
      expect(tester.getSize(_fab), const Size(72, 72));
    });
  });

  group('lifecycle', () {
    testWidgets('disposing mid-animation throws nothing', (tester) async {
      await tester.pumpWidget(_host(_stack(_Counts())));
      await tester.tap(_fab);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    // M1 (fixed in 1.1.2): closeFab captured by an async handler after dispose.
    testWidgets('closeFab after dispose does not throw (M1)', (tester) async {
      late VoidCallback saved;
      await tester.pumpWidget(
        _host(_stack(_Counts(), captureClose: (f) => saved = f)),
      );
      await _toggle(tester);
      await tester.pumpWidget(const SizedBox());
      expect(() => saved(), returnsNormally);
    });
  });

  group('known gaps (skipped until fixed)', () {
    // M3: tap on the revealed background strip should dismiss.
    testWidgets('tap on revealed background strip dismisses (M3)', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_stack(_Counts())));
      await _toggle(tester);
      await tester.tapAt(const Offset(700, 100));
      await tester.pumpAndSettle();
      expect(find.byKey(_colTopKey), findsNothing);
    }, skip: true);

    // M4: in RTL the row should extend away from the screen edge, to the
    // opposite side of the FAB compared with LTR.
    testWidgets('RTL mirrors the action row (M4)', (tester) async {
      await tester.pumpWidget(
        _host(_stack(_Counts()), direction: TextDirection.rtl),
      );
      await _toggle(tester);
      expect(
        tester.getCenter(find.byKey(_rowRightKey)).dx,
        greaterThan(tester.getCenter(_fab).dx),
      );
    }, skip: true);

    // M5: system back should close an open menu.
    testWidgets('back button closes the open menu (M5)', (tester) async {
      await tester.pumpWidget(_host(_stack(_Counts())));
      await _toggle(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(_colTopKey), findsNothing);
    }, skip: true);
  });
}
