import 'dart:math';
import 'package:flutter/material.dart';

/// Device breakpoints for responsive layout calculations.
enum DeviceType {
  compactPhone, // width < 360
  normalPhone,  // 360 <= width < 414
  largePhone,   // 414 <= width < 600
  tablet,       // width >= 600
}

class ResponsiveBreakpoints {
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return DeviceType.compactPhone;
    if (width < 414) return DeviceType.normalPhone;
    if (width < 600) return DeviceType.largePhone;
    return DeviceType.tablet;
  }

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;
}

/// Helper class to resolve values based on responsive device types.
class ResponsiveValue<T> {
  final T compact;
  final T normal;
  final T large;
  final T tablet;

  const ResponsiveValue({
    required this.compact,
    required this.normal,
    required this.large,
    required this.tablet,
  });

  T resolve(BuildContext context) {
    switch (ResponsiveBreakpoints.getDeviceType(context)) {
      case DeviceType.compactPhone:
        return compact;
      case DeviceType.normalPhone:
        return normal;
      case DeviceType.largePhone:
        return large;
      case DeviceType.tablet:
        return tablet;
    }
  }
}

/// Dynamic game board layout calculator ensuring zero pixel overflow.
class BoardLayoutCalculator {
  final double availableWidth;
  final double availableHeight;
  final int gridCols;
  final int gridRows;
  final double outerPadding;

  BoardLayoutCalculator({
    required this.availableWidth,
    required this.availableHeight,
    required this.gridCols,
    required this.gridRows,
    this.outerPadding = 16.0,
  });

  /// Maximum safe dimension for a square board based on constraints.
  double get maxSafeBoardSize {
    final maxW = max(0.0, availableWidth - (outerPadding * 2));
    final maxH = max(0.0, availableHeight - (outerPadding * 2));
    return min(maxW, maxH);
  }

  /// Cell size calculated from grid dimensions and safe board size.
  double get cellSize {
    final maxGridDim = max(gridCols, gridRows);
    if (maxGridDim <= 0) return 40.0;
    return max(10.0, (maxSafeBoardSize - (cellGap * (maxGridDim - 1))) / maxGridDim);
  }

  double get cellGap => 4.0;

  double get actualBoardWidth => (cellSize * gridCols) + (cellGap * (gridCols - 1));
  double get actualBoardHeight => (cellSize * gridRows) + (cellGap * (gridRows - 1));
}

/// Wrapper widget providing responsive layout constraints.
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints, DeviceType deviceType) builder;

  const ResponsiveLayout({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveBreakpoints.getDeviceType(context);
        return builder(context, constraints, deviceType);
      },
    );
  }
}
