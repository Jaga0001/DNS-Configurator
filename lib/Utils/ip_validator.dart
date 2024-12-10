class IPValidator {
  static bool isValidIPv4(String ip) {
    final ipv4Regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');

    if (!ipv4Regex.hasMatch(ip)) return false;

    return ip.split('.').every((octet) {
      final value = int.parse(octet);

      return value >= 0 && value <= 255;
    });
  }

  static bool isValidIPv6(String ip) {
    final ipv6Regex = RegExp(r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$');
    return ipv6Regex.hasMatch(ip);
  }
}
