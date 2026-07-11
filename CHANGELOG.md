# Changelog

## 1.1.1

### Changes

- Replaced example assets with higher-quality, optimized versions.

## 1.1.0

### Changes

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

## [1.0.1] - 2025-10-22

- Improved **README** with better structure, polished examples, and added demo GIF/video preview for
  web usage.

## [1.0.0] - 2025-10-22

- Initial release
