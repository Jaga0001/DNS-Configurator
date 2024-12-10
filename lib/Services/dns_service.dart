import 'dart:io';
import 'package:dns_configurator/Utils/ip_validator.dart';
import 'package:dns_configurator/Utils/log_manager.dart';
import 'package:flutter/foundation.dart';

class DNSService {
  final DNSLogManager _logManager = DNSLogManager();
  String? _currentDNS;

  Future<bool> updateDNS(String newDNS) async {
    // Validate IP address
    if (!IPValidator.isValidIPv4(newDNS) && !IPValidator.isValidIPv6(newDNS)) {
      throw ArgumentError('Invalid IP address format');
    }

    try {
      // Store current DNS before update
      final oldDNS = _currentDNS ?? 'Unknown';

      // Platform-specific DNS update logic
      bool updateResult = await _performDNSUpdate(newDNS);

      // Log the DNS change
      await _logManager.logDNSChange(
          oldDNS: oldDNS, newDNS: newDNS, success: updateResult);

      // Update current DNS if successful
      if (updateResult) {
        _currentDNS = newDNS;
      }

      return updateResult;
    } catch (e) {
      // Log any errors
      debugPrint('DNS Update Error: $e');
      return false;
    }
  }

  Future<bool> _performDNSUpdate(String dnsIP) async {
    if (Platform.isAndroid) {
      return _updateDNSAndroid(dnsIP);
    } else if (Platform.isWindows) {
      return _updateDNSWindows(dnsIP);
    } else if (Platform.isMacOS) {
      return _updateDNSMacOS(dnsIP);
    } else if (Platform.isLinux) {
      return _updateDNSLinux(dnsIP);
    }
    throw UnsupportedError('Platform not supported for DNS modification');
  }

  Future<bool> _updateDNSAndroid(String dnsIP) async {
    // Placeholder for Android-specific DNS update
    // This would typically involve using platform channels or specific Android APIs
    debugPrint('Updating DNS on Android: $dnsIP');
    return true; // Simulated success
  }

  Future<bool> _updateDNSWindows(String dnsIP) async {
    try {
      final result = await Process.run('netsh', [
        'interface',
        'ip',
        'set',
        'dns',
        'name="Ethernet"',
        'static',
        dnsIP
      ]);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Windows DNS Update Error: $e');
      return false;
    }
  }

  Future<bool> _updateDNSMacOS(String dnsIP) async {
    try {
      final result =
          await Process.run('networksetup', ['-setdnsservers', 'Wi-Fi', dnsIP]);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('MacOS DNS Update Error: $e');
      return false;
    }
  }

  Future<bool> _updateDNSLinux(String dnsIP) async {
    try {
      final result = await Process.run('nmcli',
          ['connection', 'modify', 'system-connection', 'ipv4.dns', dnsIP]);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Linux DNS Update Error: $e');
      return false;
    }
  }

  Future<List<String>> getDNSHistory() async {
    return await _logManager.retrieveLogs();
  }

  Future<void> clearDNSHistory() async {
    await _logManager.clearLogs();
  }
}
