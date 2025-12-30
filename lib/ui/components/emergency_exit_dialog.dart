import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/habit_contract.dart';
import '../../data/services/contract_service.dart';

class EmergencyExitDialog extends StatefulWidget {
  final HabitContract contract;
  
  const EmergencyExitDialog({super.key, required this.contract});
  
  @override
  State<EmergencyExitDialog> createState() => _EmergencyExitDialogState();
}

class _EmergencyExitDialogState extends State<EmergencyExitDialog> {
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 12),
          Text('🚨 Emergency Exit'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will immediately dissolve the pact and:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildBulletPoint('• Stop all notifications and nudges'),
          _buildBulletPoint('• Reset all privacy settings to maximum'),
          _buildBulletPoint('• Log this action for safety review'),
          _buildBulletPoint('• This action cannot be undone'),
          
          const SizedBox(height: 24),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              hintText: 'e.g., Feeling pressured, harassment, privacy concerns',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          if (_isSubmitting) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _confirmEmergencyExit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Emergency Exit'),
        ),
      ],
    );
  }
  
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
    );
  }
  
  Future<void> _confirmEmergencyExit() async {
    setState(() => _isSubmitting = true);
    
    try {
      final contractService = context.read<ContractService>();
      final reason = _reasonController.text.trim();
      
      await contractService.emergencyDissolveContract(
        widget.contract,
        reason.isNotEmpty ? reason : 'Emergency exit initiated by user',
      );
      
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pact dissolved. You are safe.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }
  
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
