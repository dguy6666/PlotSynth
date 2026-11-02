import 'package:flutter/material.dart';

Future<String?> showProjectNameDialog({
  required BuildContext context,
  String initialValue = '',
  required String actionLabel, // 'Create' or 'Rename'
  required String title,
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Project Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final text = controller.text.trim();
            if (text.isNotEmpty) Navigator.pop(ctx, text);
          },
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}