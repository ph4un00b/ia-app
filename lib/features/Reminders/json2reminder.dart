import 'dart:convert';

enum ReminderKind { daily, weekly, monthly, oneTime }

class ReminderParser {
  static String parseJsonToReminderText(String reminderJson) {
    final Map<String, dynamic> reminder = jsonDecode(reminderJson);
    final String title = reminder['title'];
    final int? repeat = reminder['repeat'];
    final String? timeStr = reminder['time'];
    final String? day = reminder['day'];
    final String? date = reminder['date'];
    final ReminderKind kind = _determineReminderKind(reminder);

    final reminderTime = _parseTimeString(timeStr);

    return switch (kind) {
      ReminderKind.daily => _dailyReminder(title, reminderTime, repeat),
      ReminderKind.weekly => _weeklyReminder(title, day, reminderTime),
      ReminderKind.monthly => _monthlyReminder(title, day, reminderTime),
      ReminderKind.oneTime => _oneTimeReminder(title, day, date, reminderTime),
    };
  }

  static ReminderKind _determineReminderKind(
      Map<String, dynamic> reminderData) {
    final String? kindString = reminderData['kind'];
    final bool hasDay = reminderData['day'] != null;

    return switch ((kindString?.toUpperCase(), hasDay)) {
      ('DAILY', true) => ReminderKind.weekly,
      (String kind, _) => ReminderKind.values.firstWhere(
          (e) => e.name.toUpperCase() == kind,
          orElse: () => ReminderKind.oneTime,
        ),
      _ => ReminderKind.oneTime,
    };
  }

  static DateTime? _parseTimeString(String? timeStr) {
    if (timeStr == null) return null;
    return DateTime.parse('1970-01-01 $timeStr');
    // TODO: descomentar cuando existan más pruebas y evitar sorpresas de la ia
    // try {
    //   return DateTime.parse('1970-01-01 $timeStr');
    // } catch (e, st) {
    //   print('Error parsing time string: $timeStr, $st');
    //   return null;
    // }
  }

  static String _dailyReminder(
    String title,
    DateTime? time,
    int? repeat,
  ) {
    final lowercaseTitle = title.toLowerCase();
    final timeFormatted = time != null ? _formatTimeToAmPm(time) : '';
    return switch (repeat) {
      30 =>
        '**Daily reminder** to $lowercaseTitle at $timeFormatted for a month.',
      _ => '**Daily reminder** to $lowercaseTitle at $timeFormatted.',
    };
  }

  static String _weeklyReminder(
    String title,
    String? dayOfWeek,
    DateTime? time,
  ) {
    final lowercaseTitle = title.toLowerCase();
    final baseReminder = '**Weekly reminder** on $dayOfWeek to $lowercaseTitle';

    return time != null
        ? '$baseReminder at ${_formatTimeToAmPm(time)}.'
        : '$baseReminder.';
  }

  static String _monthlyReminder(
    String title,
    String? dayOfWeek,
    DateTime? time,
  ) {
    final lowercaseTitle = title.toLowerCase();
    final baseReminder =
        '**Monthly reminder** every $dayOfWeek to $lowercaseTitle';

    return time != null
        ? '$baseReminder at ${_formatTimeToAmPm(time)}.'
        : '$baseReminder.';
  }

  static String _oneTimeReminder(
    String title,
    String? dayOfWeek,
    String? date,
    DateTime? time,
  ) {
    final lowercaseTitle = title.toLowerCase();
    final datePhrase = switch ((dayOfWeek, date)) {
      (String day, String dt) => 'on $day, $dt',
      (String day, _) => 'on $day',
      (_, String dt) => 'on $dt',
      _ => '',
    };

    final timePhrase = time != null ? ' at ${_formatTimeToAmPm(time)}' : '';
    return '**Reminder** $datePhrase to $lowercaseTitle$timePhrase.';
  }

  static String _formatTimeToAmPm(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
