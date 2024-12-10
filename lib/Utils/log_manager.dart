import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class DNSLogManager {
  static final DNSLogManager _instance = DNSLogManager._internal();

  factory DNSLogManager() {
    return _instance;
  }

  DNSLogManager._internal();

  Future<File> get _logFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/dns_changes.log');
  }

  Future<void> logDNSChange(
      {required String oldDNS,
      required String newDNS,
      required bool success}) async {
    final logEntry = _createLogEntry(oldDNS, newDNS, success);

    final file = await _logFile;
    await file.writeAsString(logEntry, mode: FileMode.append);
  }

  String _createLogEntry(String oldDNS, String newDNS, bool success) {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    return '$timestamp | '
        'Old DNS: $oldDNS | '
        'New DNS: $newDNS | '
        'Status: ${success ? 'Success' : 'Failed'}\n';
  }

  Future<List<String>> retrieveLogs() async {
    final file = await _logFile;

    if (!await file.exists()) {
      return [];
    }

    return await file.readAsLines();
  }

  Future<void> clearLogs() async {
    final file = await _logFile;
    await file.writeAsString('');
  }
}
