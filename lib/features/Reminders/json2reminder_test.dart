import 'package:test/test.dart';
import 'json2reminder.dart';

void main() {
  group('ReminderParser', () {
    test('parses basic reminders correctly', () {
      final testCases = [
        (
          name: "Beber yogurt",
          context: null,
          json: '''
          {
            "title": "Beber yogurt",
            "kind": "DAILY",
            "time": "10:00",
            "dayTime": "MORNING"
          }''',
          expected: "**Daily reminder** to beber yogurt at 10:00 AM."
        ),
        (
          name: "Beber leche",
          context: null,
          json: '''
          {
            "title": "Beber leche",
            "kind": "DAILY",
            "repeat": 30,
            "time": "21:00"
          }''',
          expected: "**Daily reminder** to beber leche at 09:00 PM for a month."
        ),
        (
          name: "Cita con nutricionista",
          context: null,
          json: '''
          {
            "title": "Cita con nutricionista",
            "kind": "ONE_TIME",
            "day": "MONDAY",
            "date": "2024-11-04",
            "time": "18:00"
          }''',
          expected:
              "**Reminder** on MONDAY, 2024-11-04 to cita con nutricionista at 06:00 PM."
        ),
        (
          name: "Sacar la basura",
          context: null,
          json: '''
          {
            "title": "Sacar la basura",
            "kind": "WEEKLY",
            "day": "FRIDAY",
            "modifier": "EVERY",
            "time": "20:00"
          }''',
          expected:
              "**Weekly reminder** on FRIDAY to sacar la basura at 08:00 PM."
        ),
        (
          name: "Hacer yogurt",
          context: null,
          json: '''
          {
            "title": "Hacer yogurt",
            "kind": "MONTHLY",
            "day": "SUNDAY",
            "modifier": "EVERY",
            "repeat": 4,
            "time": "08:00",
            "dayTime": "MORNING"
          }''',
          expected:
              "**Monthly reminder** every SUNDAY to hacer yogurt at 08:00 AM."
        ),
        (
          name: "Operación de nariz",
          context: null,
          json: '''
          {
            "title": "Operación de nariz",
            "kind": "ONE_TIME",
            "date": "2024-11-30"
          }''',
          expected: "**Reminder** on 2024-11-30 to operación de nariz."
        ),
        (
          name: "Beber cerveza",
          context: null,
          json: '''
          {
            "title": "Beber cerveza",
            "kind": "ONE_TIME",
            "day": "MONDAY",
            "time": "14:00"
          }''',
          expected: "**Reminder** on MONDAY to beber cerveza at 02:00 PM."
        ),
        (
          name: "Comer Tacos los Martes",
          context: "AI should interpret this as a weekly event",
          json: '''
          {
            "title": "Comer Tacos",
            "kind": "DAILY",
            "day": "TUESDAY",
            "time": "00:00",
            "dayTime": "MIDNIGHT"
          }''',
          expected: "**Weekly reminder** on TUESDAY to comer tacos at 12:00 AM."
        ),
      ];

      for (final testCase in testCases) {
        final sentence = ReminderParser.parseJsonToReminderText(testCase.json);
        expect(sentence, equals(testCase.expected),
            reason: 'Failed at test case: ${testCase.name}');
      }
    });
  });
}
