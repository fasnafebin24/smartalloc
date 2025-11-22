import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp timestamp) {
  DateTime date = timestamp.toDate();
  return DateFormat('dd-MM-yyyy HH:mm:ss').format(date);
}

String formatTimeAgo(Timestamp timestamp) {
  DateTime date = timestamp.toDate();
  DateTime now = DateTime.now();
  Duration diff = now.difference(date);

  if (diff.inSeconds < 60) {
    return "Just now";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago";
  } else if (diff.inDays == 1) {
    return "Yesterday";
  } else if (diff.inDays < 7) {
    return "${diff.inDays} days ago";
  } else if (diff.inDays < 30) {
    int weeks = (diff.inDays / 7).floor();
    return "$weeks week${weeks > 1 ? 's' : ''} ago";
  } else if (diff.inDays < 365) {
    int months = (diff.inDays / 30).floor();
    return "$months month${months > 1 ? 's' : ''} ago";
  } else {
    int years = (diff.inDays / 365).floor();
    return "$years year${years > 1 ? 's' : ''} ago";
  }
}
