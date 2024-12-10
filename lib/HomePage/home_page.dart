import 'package:dns_configurator/Services/dns_service.dart';
import 'package:dns_configurator/Utils/ip_validator.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dnsController = TextEditingController();
  final _dnsService = DNSService();
  String _statusMessage = '';

  void _updateDNS() async {
    final dnsIP = _dnsController.text.trim();

    // Validate IP address
    if (!IPValidator.isValidIPv4(dnsIP) && !IPValidator.isValidIPv6(dnsIP)) {
      _showErrorDialog('Invalid IP address format');
      return;
    }

    try {
      final success = await _dnsService.updateDNS(dnsIP);

      setState(() {
        _statusMessage =
            success ? 'DNS Updated Successfully!' : 'Failed to update DNS';
      });

      // Show success/error dialog
      _showResultDialog(success);
    } catch (e) {
      _showErrorDialog('Error updating DNS: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(bool success) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(success ? 'Success' : 'Failed'),
        content: Text(success
            ? 'DNS updated successfully!'
            : 'Could not update DNS. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System DNS Configurator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async {
              // Show DNS change history
              final history = await _dnsService.getDNSHistory();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('DNS Change History'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: history.map((log) => Text(log)).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: _dnsController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter DNS IP (e.g., 8.8.8.8)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: _updateDNS,
            child: const Text('Update DNS'),
          ),
          const SizedBox(height: 15),
          Text(
            _statusMessage,
            style: TextStyle(
              color: _statusMessage.contains('Successfully')
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
