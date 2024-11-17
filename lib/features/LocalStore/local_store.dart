import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

// todo: test bad paths
final class LocalStore {
  static Future<void> append(String filename, String content) async {
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final filePath = '${appDocumentsDirectory.path}/$filename';

    final file = File(filePath);

    if (await file.exists()) {
      // Remove this block as it's not necessary for appending
      // final lines = await file.readAsLines();
      // final lineCount = lines.length;
      // debugPrint('Total lines: $lineCount');

      await file.writeAsString(
        '\n- $content',
        mode: FileMode.append,
      );
    } else {
      await file.create(recursive: true);
      await file.writeAsString("- $content");
    }
  }

  static Future<void> saveTestReminders(String filename) async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/$filename';

    File file = File(filePath);
    file.writeAsString('''
1. **Daily reminder** to take your flu medication in the morning and at night.
2. **Daily reminder** to spend at least 15 minutes stretching for muscle relief and flexibility.
3. **Daily reminder** to hydrate adequately, aiming for at least 8 glasses of water.
4. **Weekly reminder** on Wednesday to clean and check the condition of all the dogs.
5. **Daily reminder** to eat a balanced diet rich in vitamins and protein to ease your flu symptoms and support overall health.
6. **Weekly reminder** on Monday to review your fitness goals and progress.
7. **reminder** on July 9, visit your doctor for a flu check-up or vaccine if necessary.
8. **Daily reminder** to meditate or practice mindfulness for stress management.
9. **Weekly reminder** on Saturday to do a thorough laundry wash, ensuring all your gym kit is clean.
10. **Monthly reminder** every friday to check your weight and body measurements, tracking any changes to ensure your fitness plan is effective.
''');
  }

  static Future<void> save(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString("# User's reminders");
  }

// todo: security
  static Future<int> read(String filename) async {
    final file = File(
      '${(await getApplicationDocumentsDirectory()).path}/$filename',
    );

    final content = await file.readAsString();

    debugPrint('''
============= FILE CONTENT ===============
Total lines: ${content.split('\n').length}
$content
============= END FILE CONTENT ===========
'''
        .trim());

    return content.split('\n').length;
  }
}
