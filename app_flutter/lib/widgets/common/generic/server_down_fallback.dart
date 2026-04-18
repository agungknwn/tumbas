import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/common_provider.dart';

class ServerDownScreen extends StatefulWidget {
  const ServerDownScreen({super.key});

  @override
  State<ServerDownScreen> createState() => _ServerDownScreenState();
}

class _ServerDownScreenState extends State<ServerDownScreen> {
  bool _isRetrying = false;

  Future<void> _retry() async {
    setState(() => _isRetrying = true);
    final provider = context.read<CommonProvider>();
    await provider.checkHealth();
    if (mounted) setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme appTheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Cannot reach server',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check your connection or the server may be down.\nContact admin if the problem persists.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _isRetrying
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appTheme.tertiary,
                      ),
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
