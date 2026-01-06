import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/transaction.dart';
import '../providers/task_provider.dart';
import '../providers/money_provider.dart';

class BackupService {
  static const String _lastBackupKey = 'last_backup_date';

  /// Creates a backup of all app data
  static Map<String, dynamic> createBackupData(
    TaskProvider taskProvider,
    MoneyProvider moneyProvider,
  ) {
    return {
      'version': 1,
      'backupDate': DateTime.now().toIso8601String(),
      'tasks': taskProvider.tasks.map((t) => t.toJson()).toList(),
      'transactions': moneyProvider.transactions.map((t) => t.toJson()).toList(),
    };
  }

  /// Shares the backup file using the system share sheet
  static Future<bool> shareBackup(
    TaskProvider taskProvider,
    MoneyProvider moneyProvider,
  ) async {
    try {
      final backupData = createBackupData(taskProvider, moneyProvider);
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // Get temp directory and create backup file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final backupFile = File('${tempDir.path}/task_manager_backup_$timestamp.json');
      await backupFile.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: 'Task Manager Backup',
        text: 'My Task Manager backup',
      );

      // Save last backup date
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastBackupKey, DateTime.now().toIso8601String());

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Picks a backup file and returns the parsed data
  static Future<Map<String, dynamic>?> pickBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate backup structure
      if (!data.containsKey('tasks') || !data.containsKey('transactions')) {
        return null;
      }

      return data;
    } catch (e) {
      return null;
    }
  }

  /// Restores data from backup to providers
  static Future<bool> restoreBackup(
    Map<String, dynamic> backupData,
    TaskProvider taskProvider,
    MoneyProvider moneyProvider,
  ) async {
    try {
      // Parse tasks
      final tasksJson = backupData['tasks'] as List<dynamic>;
      final tasks = tasksJson.map((json) => Task.fromJson(json)).toList();

      // Parse transactions
      final transactionsJson = backupData['transactions'] as List<dynamic>;
      final transactions = transactionsJson
          .map((json) => Transaction.fromJson(json))
          .toList();

      // Restore to providers
      taskProvider.setTasks(tasks);
      moneyProvider.setTransactions(transactions);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets the last backup date
  static Future<DateTime?> getLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastBackupKey);
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }
}
