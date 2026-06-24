import 'package:flutter/material.dart';
import '../models/layer_object.dart';

class LayersPanel extends StatelessWidget {
  final List<LayerObject> layers;
  final String? selectedId;
  final Function(String id) onSelect;

  const LayersPanel({
    super.key,
    required this.layers,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Text(
            "Layers",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Divider(),

          Expanded(
  child: ListView.builder(
    itemCount: layers.length,
    itemBuilder: (context, index) {
      final layer = layers[layers.length - 1 - index];

      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple,
          child: Text("${index + 1}"),
        ),

        title: Text(layer.type.name.toUpperCase()),

        subtitle: Text(
          layer.type == LayerType.text
              ? (layer.text ?? "Text Layer")
              : "Image Layer",
        ),

        selected: selectedId == layer.id,

        onTap: () {
          onSelect(layer.id);
          Navigator.pop(context);
        },
      );
    },
  ),
),
        ],
      ),
    );
  }
}