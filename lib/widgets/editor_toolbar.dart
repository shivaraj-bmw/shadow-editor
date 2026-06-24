import 'package:flutter/material.dart';

class EditorToolbar extends StatelessWidget {
  final VoidCallback onAddImage;
  final VoidCallback onAddText;
  final VoidCallback onDelete;
  final VoidCallback onLayers;

  const EditorToolbar({
    super.key,
    required this.onAddImage,
    required this.onAddText,
    required this.onDelete,
    required this.onLayers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      color: const Color(0xFF1E0033),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(
              Icons.image,
              color: Colors.white,
            ),
            onPressed: onAddImage,
          ),
          IconButton(
            icon: const Icon(
              Icons.text_fields,
              color: Colors.white,
            ),
            onPressed: onAddText,
          ),
          IconButton(
            icon: const Icon(
              Icons.layers,
              color: Colors.white,
            ),
            onPressed: onLayers,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}