class DailySeed {
  static int getSeedFromDate([DateTime? date]) {
    final target = date ?? DateTime.now();
    final dateStr = "${target.year.toString().padLeft(4, '0')}"
        "${target.month.toString().padLeft(2, '0')}"
        "${target.day.toString().padLeft(2, '0')}";
    return dateStr.hashCode.abs();
  }

  static String getDateString([DateTime? date]) {
    final target = date ?? DateTime.now();
    return "${target.year.toString().padLeft(4, '0')}-"
        "${target.month.toString().padLeft(2, '0')}-"
        "${target.day.toString().padLeft(2, '0')}";
  }
}
