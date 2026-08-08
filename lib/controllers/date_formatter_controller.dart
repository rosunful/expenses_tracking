/// Formats a DateTime the way your screenshots show dates:
/// "Today", "Yesterday", or "Jul 14" for anything older.
/// Shared so ActivityScreen, Home, and anywhere else showing
/// transactions all display dates the same way.
String formatTransactionDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final givenDay = DateTime(date.year, date.month, date.day);
  final difference = today.difference(givenDay).inDays;

  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}