import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../providers/screenshot_provider.dart';
import '../providers/video_provider.dart';

class SecurityStatusScreen extends StatelessWidget {
  const SecurityStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Status'),
      ),
      body: Consumer2<SecurityProvider, ScreenshotProvider>(
        builder: (context, securityProvider, screenshotProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildStatusCard(
                title: 'Screenshot Protection',
                isEnabled: securityProvider.isScreenshotProtectionEnabled,
                onToggle: () => securityProvider.toggleScreenshotProtection(),
                children: [
                  _buildStatItem(
                    icon: Icons.screenshot,
                    title: 'Screenshot Attempts',
                    value: '${securityProvider.screenshotCount}',
                    onReset: () => securityProvider.resetScreenshotCount(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                title: 'Secure Mode',
                isEnabled: securityProvider.isSecureMode,
                onToggle: () => securityProvider.toggleSecureMode(),
                children: [
                  _buildStatItem(
                    icon: Icons.security,
                    title: 'Security Level',
                    value: securityProvider.isSecureMode ? 'High' : 'Normal',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                title: 'Watermark',
                isEnabled: true,
                children: [
                  _buildStatItem(
                    icon: Icons.text_fields,
                    title: 'Current Watermark',
                    value: securityProvider.watermarkText,
                  ),
                  const SizedBox(height: 8),
                  _buildStatItem(
                    icon: Icons.access_time,
                    title: 'Last Updated',
                    value: 'Updates every 30 seconds',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required bool isEnabled,
    VoidCallback? onToggle,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onToggle != null)
                  Switch(
                    value: isEnabled,
                    onChanged: (value) => onToggle(),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onReset,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (onReset != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onReset,
          ),
      ],
    );
  }
} 