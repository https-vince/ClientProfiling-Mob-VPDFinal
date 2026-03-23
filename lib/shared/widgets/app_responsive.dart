import 'package:flutter/material.dart';

/// Lightweight responsive utility — use via static methods anywhere you have
/// a [BuildContext].
///
/// Breakpoints:
///   phone  : width < 600
///   tablet : width >= 600
///   large  : width >= 900
class AppResponsive {
  AppResponsive._();

  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;

  static bool isLargeTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 900;

  /// Returns [tablet] on tablet, [phone] on phone.
  static T choose<T>(BuildContext context,
          {required T phone, required T tablet}) =>
      isTablet(context) ? tablet : phone;

  /// Number of analytics grid columns: 4 on tablet, 2 on phone.
  ///
  /// Optionally pass [tabletCols] / [phoneCols] to override.
  static int gridColumns(BuildContext context,
          {int phoneCols = 2, int tabletCols = 4}) =>
      isTablet(context) ? tabletCols : phoneCols;

  /// Scaled font size — clamps between [min] and [max].
  static double sp(BuildContext context, double base,
      {double min = 10, double max = 60}) {
    final factor = width(context) / 400.0;
    return (base * factor).clamp(min, max);
  }
}
