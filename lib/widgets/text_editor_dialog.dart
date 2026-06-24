import 'package:flutter/material.dart';

class TextEditorDialog extends StatefulWidget {
  final String initialText;

  const TextEditorDialog({
    super.key,
    required this.initialText,
  });

  @override
  State<TextEditorDialog> createState() => _TextEditorDialogState();
}

class _TextEditorDialogState extends State<TextEditorDialog> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: widget.initialText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Text"),
      content: TextField(
        controller: controller,
        maxLines: 5,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              controller.text,
            );
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}