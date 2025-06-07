import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../providers/video_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer2<SecurityProvider, VideoProvider>(
        builder: (context, securityProvider, videoProvider, child) {
          return ListView(
            children: [
              _buildSection(
                title: 'Security Settings',
                children: [
                  SwitchListTile(
                    title: const Text('Screenshot Protection'),
                    subtitle: const Text('Prevent screenshots during video playback'),
                    value: securityProvider.isScreenshotProtectionEnabled,
                    onChanged: (value) => securityProvider.toggleScreenshotProtection(),
                  ),
                  SwitchListTile(
                    title: const Text('Secure Mode'),
                    subtitle: const Text('Enable additional security features'),
                    value: securityProvider.isSecureModeEnabled,
                    onChanged: (value) => securityProvider.toggleSecureMode(),
                  ),
                  ListTile(
                    title: const Text('Screenshot Attempts'),
                    subtitle: Text('${securityProvider.screenshotCount} attempts'),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => securityProvider.resetScreenshotCount(),
                    ),
                  ),
                ],
              ),
              _buildSection(
                title: 'Watermark Settings',
                children: [
                  ListTile(
                    title: const Text('Watermark Text'),
                    subtitle: Text(securityProvider.watermarkText),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showWatermarkDialog(context, securityProvider),
                    ),
                  ),
                ],
              ),
              _buildSection(
                title: 'Cache Settings',
                children: [
                  ListTile(
                    title: const Text('Clear Cache'),
                    subtitle: const Text('Remove all cached videos'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showClearCacheDialog(context, videoProvider),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Future<void> _showWatermarkDialog(
    BuildContext context,
    SecurityProvider securityProvider,
  ) async {
    final controller = TextEditingController(text: securityProvider.watermarkText);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Watermark Text'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter watermark text',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              securityProvider.setWatermarkText(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearCacheDialog(
    BuildContext context,
    VideoProvider videoProvider,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cached videos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              videoProvider.clearCache();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
} 