import 'package:flutter/material.dart';

class AddWordDialog extends StatefulWidget {
  const AddWordDialog({super.key});

  @override
  State<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends State<AddWordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Capture Power Word'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'e.g., Antifragile',
          border: OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, _controller.text.trim());
          },
          child: const Text('Enrich'),
        ),
      ],
    );
  }
}
