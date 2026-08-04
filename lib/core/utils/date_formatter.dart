import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormatter {
  DateFormatter._();

  /// Format DateTime
  static String formatDate(DateTime date) {
    return DateFormat("dd MMM yyyy").format(date);
  }

  /// Format Date and Time
  static String formatDateTime(DateTime date) {
    return DateFormat("dd MMM yyyy, hh:mm a").format(date);
  }

  /// Only Time
  static String formatTime(DateTime date) {
    return DateFormat("hh:mm a").format(date);
  }

  /// Convert Firestore Timestamp
  static String fromTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return "";
    }
    return formatDateTime(timestamp.toDate());
  }

  /// Get Today Date
  static String today() {
    return formatDate(DateTime.now());
  }

  /// Check Same Day
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  /// Time Difference
  static String timeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inMinutes < 1) {
      return "Just now";
    }
    if (duration.inHours < 1) {
      return "${duration.inMinutes} min ago";
    }
    if (duration.inDays < 1) {
      return "${duration.inHours} hour ago";
    }
    if (duration.inDays < 30) {
      return "${duration.inDays} days ago";
    }
    return formatDate(date);
  }
}
