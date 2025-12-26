import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// PermissionInstructionSheet
/// 
/// Phase 48: Sherlock UX - Device Specific Guidance.
/// 
/// Detects the device manufacturer and provides tailored instructions
/// for enabling "Usage Access" (Digital Truth) and ensuring "Health Connect" works.
/// 
/// Targeted Manufacturers:
/// - Xiaomi (HyperOS/MIUI): Notorious for killing background apps and hiding Usage Access.
/// - Samsung (OneUI): aggressive battery optimization.
class PermissionInstructionSheet extends StatefulWidget {
  const PermissionInstructionSheet({super.key});

  @override
  State<PermissionInstructionSheet> createState() => _PermissionInstructionSheetState();
}

class _PermissionInstructionSheetState extends State<PermissionInstructionSheet> {
  final _deviceInfoPlugin = DeviceInfoPlugin();
  String _manufacturer = 'Generic';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _detectDevice();
  }

  Future<void> _detectDevice() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        setState(() {
          _manufacturer = androidInfo.manufacturer;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      // iOS doesn't have these specific fragmentation issues usually
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A), // Slate 900
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 24),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                   const Icon(Icons.build_circle_outlined, color: Color(0xFF22C55E), size: 28),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Text(
                      'Enable Sherlock Sensors',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFF8FAFC),
                        fontWeight: FontWeight.bold,
                      ),
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Specific instructions for your $_manufacturer device.',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
              
              const SizedBox(height: 24),
              
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildHealthConnectSection(),
                      const SizedBox(height: 24),
                      _buildUsageAccessSection(),
                      const SizedBox(height: 24),
                      if (_manufacturer.toLowerCase().contains('xiaomi'))
                         _buildXiaomiSpecifics(),
                      if (_manufacturer.toLowerCase().contains('samsung'))
                         _buildSamsungSpecifics(),
                         
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthConnectSection() {
    return _InstructionCard(
      title: '1. Health Connect',
      icon: Icons.favorite,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required for Biometric Sensor (Sleep & HRV).',
            style: TextStyle(color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 12),
          _StepRow(number: 'A', text: 'If not installed, download "Health Connect" from Play Store.'),
          _StepRow(number: 'B', text: 'Open it -> App Permissions -> Allow "The Pact".'),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF334155),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
               launchUrl(Uri.parse("market://details?id=com.google.android.apps.healthdata"));
            },
            child: const Text('Find on Play Store'),
          )
        ],
      ),
    );
  }

  Widget _buildUsageAccessSection() {
    return _InstructionCard(
      title: '2. Usage Access',
      icon: Icons.data_usage,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required for Digital Truth Sensor (App Usage).',
            style: TextStyle(color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 12),
          _StepRow(number: 'A', text: 'Go to Settings > Privacy > Usage Access.'),
          _StepRow(number: 'B', text: 'Find "The Pact" in the list.'),
          _StepRow(number: 'C', text: 'Toggle "Permit usage access" ON.'),
        ],
      ),
    );
  }

  Widget _buildXiaomiSpecifics() {
    return _InstructionCard(
       title: 'Xiaomi / HyperOS Special',
       icon: Icons.bolt,
       color: Colors.orange,
       content: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text(
             'Xiaomi aggressively kills background sensors. You MUST fix this for the pact to work.',
             style: TextStyle(color: Color(0xFFFFCC80), fontWeight: FontWeight.bold),
           ),
           const SizedBox(height: 12),
            _StepRow(number: '1', text: 'Long press app icon -> App Date/Info.'),
            _StepRow(number: '2', text: 'Battery Saver -> select "No restrictions".'),
            _StepRow(number: '3', text: 'Autostart -> Toggle ON.'),
         ],
       ),
    );
  }

  Widget _buildSamsungSpecifics() {
    return _InstructionCard(
       title: 'Samsung Optimization',
       icon: Icons.battery_alert,
       color: Colors.blue,
       content: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           _StepRow(number: '1', text: 'Settings -> Apps -> The Pact.'),
           _StepRow(number: '2', text: 'Battery -> Select "Unrestricted".'),
         ],
       ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;
  final Color color;

  const _InstructionCard({
    required this.title,
    required this.icon,
    required this.content,
    this.color = const Color(0xFF22C55E),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF334155), height: 24),
          content,
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Container(
             width: 20,
             height: 20,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: const Color(0xFF334155),
             ),
             alignment: Alignment.center,
             child: Text(
               number,
               style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Text(
               text,
               style: const TextStyle(color: Color(0xFF94A3B8), height: 1.4),
             ),
           ),
        ],
      ),
    );
  }
}
