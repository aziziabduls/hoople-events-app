class MyCommonValue {
  static const double borderRadiusDefault = 18;
  static const double borderRadiusOuter = 24;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
