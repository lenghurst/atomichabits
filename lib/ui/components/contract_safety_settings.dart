import 'package:flutter/material.dart';
import '../../data/models/habit_contract.dart';

enum SafetySettingsMode { edit, view }

class ContractSafetySettings extends StatefulWidget {
  final SafetySettingsMode mode;
  final HabitContract contract;
  
  // Callbacks are required only in edit mode
  final ValueChanged<bool>? onSharePsychometricsChanged;
  final ValueChanged<bool>? onAllowNudgesChanged;
  final Function(TimeOfDay? start, TimeOfDay? end)? onQuietHoursChanged;
  final VoidCallback? onManageBlockedWitnesses;
  
  // Current user ID needed for "view" mode calculations
  final String? currentUserId;

  const ContractSafetySettings({
    super.key,
    required this.mode,
    required this.contract,
    this.currentUserId,
    this.onSharePsychometricsChanged,
    this.onAllowNudgesChanged,
    this.onQuietHoursChanged,
    this.onManageBlockedWitnesses,
  });

  @override
  State<ContractSafetySettings> createState() => _ContractSafetySettingsState();
}

class _ContractSafetySettingsState extends State<ContractSafetySettings> {
  // Local state for optimistic UI updates in Edit mode
  late bool _sharePsychometrics;
  late bool _allowNudges;
  late TimeOfDay? _quietStart;
  late TimeOfDay? _quietEnd;
  late bool _quietHoursEnabled;

  @override
  void initState() {
    super.initState();
    _updateLocalState();
  }
  
  @override
  void didUpdateWidget(ContractSafetySettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contract != widget.contract) {
      _updateLocalState();
    }
  }
  
  void _updateLocalState() {
    _sharePsychometrics = widget.contract.sharePsychometrics;
    _allowNudges = widget.contract.allowNudges;
    _quietStart = widget.contract.nudgeQuietStart;
    _quietEnd = widget.contract.nudgeQuietEnd;
    _quietHoursEnabled = _quietStart != null && _quietEnd != null;
  }

  Future<void> _showQuietHoursPicker() async {
    if (widget.mode == SafetySettingsMode.view) return;
    
    final start = await showTimePicker(
      context: context,
      initialTime: _quietStart ?? const TimeOfDay(hour: 22, minute: 0),
      helpText: 'Select Quiet Hours Start',
    );
    
    if (start == null && mounted) return;
    if (!mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: _quietEnd ?? const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Select Quiet Hours End',
    );

    if (end != null) {
      setState(() {
        _quietStart = start;
        _quietEnd = end;
        _quietHoursEnabled = true;
      });
      widget.onQuietHoursChanged?.call(start, end);
    }
  }

  void _clearQuietHours() {
    if (widget.mode == SafetySettingsMode.view) return;
    
    setState(() {
      _quietHoursEnabled = false;
      _quietStart = null;
      _quietEnd = null;
    });
    widget.onQuietHoursChanged?.call(null, null);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == SafetySettingsMode.view) {
      return _buildViewMode();
    }
    return _buildEditMode();
  }
  
  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Safety & Privacy', Icons.security),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'This pact uses a Fairness Algorithm to ensure a safe, supportive environment for everyone.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        const SizedBox(height: 8),
        _buildWitnessInfoSection(),
      ],
    );
  }
  
  Widget _buildEditMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Safety & Privacy', Icons.security),
        
        // Privacy Controls
        SwitchListTile(
          title: const Text('Share Deep Insights'),
          subtitle: const Text(
            'Allow witnesses to see your "Resistance Lie" and psychometric patterns.',
          ),
          value: _sharePsychometrics,
          onChanged: (value) {
            setState(() => _sharePsychometrics = value);
            widget.onSharePsychometricsChanged?.call(value);
          },
          activeColor: Colors.deepPurple,
        ),
        
        const Divider(),
        
        // Nudge Controls
        ListTile(
          title: const Text('Nudge Settings'),
          subtitle: const Text('Control how friends can remind you.'),
        ),
        
        SwitchListTile(
          title: const Text('Allow Nudges'),
          subtitle: Text(
            _allowNudges 
                ? 'Witnesses can send up to 3 nudges per day.' 
                : 'Nudges are currently disabled.',
          ),
          value: _allowNudges,
          onChanged: (value) {
            setState(() => _allowNudges = value);
            widget.onAllowNudgesChanged?.call(value);
          },
        ),
        
        if (_allowNudges) ...[
          ListTile(
            title: const Text('Quiet Hours'),
            subtitle: Text(
              _quietHoursEnabled && _quietStart != null && _quietEnd != null
                  ? 'No nudges from ${_quietStart!.format(context)} to ${_quietEnd!.format(context)}'
                  : 'Receive nudges at any time',
            ),
            trailing: Switch(
              value: _quietHoursEnabled,
              onChanged: (value) {
                if (value) {
                  _showQuietHoursPicker();
                } else {
                  _clearQuietHours();
                }
              },
            ),
          ),
        ],
        
        const Divider(),
        
        // Boundary Controls
        ListTile(
          title: const Text('Blocked Witnesses'),
          subtitle: Text(
            widget.contract.blockedWitnessIds.isEmpty
                ? 'No one is blocked from this pact.'
                : '${widget.contract.blockedWitnessIds.length} person(s) blocked.',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.block),
            onPressed: widget.onManageBlockedWitnesses,
            tooltip: 'Manage Block List',
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildWitnessInfoSection() {
    final currentUid = widget.currentUserId;
    if (currentUid == null) return const SizedBox.shrink();

    // Calculate usage
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    
    final myNudgesToday = widget.contract.nudgeHistory[currentUid]
        ?.where((time) => time.isAfter(startOfToday))
        .length ?? 0;
        
    final totalNudgesToday = widget.contract.nudgeHistory.values
        .expand((list) => list)
        .where((time) => time.isAfter(startOfToday))
        .length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Your Nudge Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Allow Nudges Status
            _buildInfoRow(
              'Nudges Allowed',
              widget.contract.allowNudges ? 'Yes' : 'No (Paused by Builder)',
              widget.contract.allowNudges ? Colors.green : Colors.red,
            ),
            
            // Individual usage
            if (widget.contract.allowNudges) ...[
              _buildInfoRow(
                'Your nudges today',
                '$myNudgesToday / 3',
                myNudgesToday >= 3 ? Colors.red : Colors.green.shade700,
              ),
              
              // Global usage
              _buildInfoRow(
                'Pact total today',
                '$totalNudgesToday / 6',
                 totalNudgesToday >= 6 ? Colors.orange : Colors.blue.shade700,
              ),
              
              // Quiet hours
              if (widget.contract.nudgeQuietStart != null)
                _buildInfoRow(
                  'Quiet hours',
                  '${widget.contract.nudgeQuietStart!.format(context)} - '
                  '${widget.contract.nudgeQuietEnd!.format(context)}',
                  Colors.grey.shade700,
                ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
