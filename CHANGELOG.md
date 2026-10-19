# Changelog

## 1.1.2

### Fixed

- Action buttons beyond the slide area (e.g. a tall column) were visible but ignored taps, because Flutter's Scaffold only hit-tests its FAB slot within the slot's bounds. The slot now sizes itself to the FAB plus the revealed actions, so every action is tappable.
- Calling `closeFab` after the widget was disposed (e.g. from an async action callback) no longer throws.
- The previous `CurvedAnimation` is now disposed when `openAnimationCurve` or
  `closeAnimationCurve` changes.

### Changed

- Action builders now run only while the menu is open.

### Documentation

- Documented that the foreground slides by `scale + fabSize + actionsSpacing`, that actions beyond
  that area overlay the foreground, and that column items should be no wider than `fabSize` and row
  items no taller than `fabSize`.
- README: corrected the `closeAnimationCurve` default (`Curves.easeInOut`) and the install
  version; the example no longer creates a `GlobalKey` inside `build`; added known limitations.
- Added library and constructor doc comments, enabled `public_member_api_docs`.
- Added pub.dev `screenshots` and refreshed `topics`.
- Added widget tests.

### Note

- 1.1.0 renamed `fabOpenIcon`/`fabCloseIcon` to `fabOpenWidget`/`fabCloseWidget` in a minor release.
  That is a breaking change for anyone upgrading from 1.0.x; see the 1.1.0 entry for the migration.

## 1.1.1

### Changes

- Replaced example assets with higher-quality, optimized versions.

## 1.1.0

### Breaking

- Renamed `fabOpenIcon` and `fabCloseIcon` (previously restricted to the standard `Icon` type) to
  `fabOpenWidget` and `fabCloseWidget` of type `Widget`. This grants full visual design freedom,
  allowing users to pass SVGs, custom images, or complex widgets.

### Added

- Added `fabSize` (default: `56.0`) to customize Floating Action Button dimensions.
- Added `actionsSpacing` (default: `16.0`) to define spacing between the FAB and revealed background
  actions.
- Introduced `foregroundDimColor` to render an animated fading background color overlay across the
  translated primary UI.

### Fixed

- **SnackBar Alignment Break:** Repositioned background actions inside the native
  `FloatingActionButtonLocation.endFloat` slot. This resolves the alignment issue where a SnackBar
  or keyboard shifted the FAB upward, leaving background actions behind.
- **Hit-Test Boundaries:** Introduced a customized `_OverflowTouchStack` to bypass default bounding
  box clipping, ensuring action buttons that extend past physical container sizes are fully
  clickable.
- **Visual Overflow Warnings:** Removed internal hardcoded constraints (`ConstrainedBox`), resolving
  yellow-and-red striped `BOTTOM OVERFLOWED` visual layout errors.

### Optimizations

- Switched from fractional `SlideTransition` math to absolute physical pixel translation via
  `Transform.translate`. This completely decouples calculations from `MediaQueryData` inside the
  build lifecycle, reducing GC allocations and performance overhead.

## 1.0.1

- Improved **README** with better structure, polished examples, and added demo GIF/video preview for
  web usage.

## 1.0.0

- Initial release
