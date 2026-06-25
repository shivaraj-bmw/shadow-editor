// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/layer_object.dart';
import '../models/editor_state.dart';
import '../widgets/layer_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:ui';
import '../services/ai_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_background_remover/image_background_remover.dart';
import 'package:image/image.dart' as img;


class EditorScreen extends StatefulWidget {
  final File imageFile;

  const EditorScreen({super.key, required this.imageFile});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final picker = ImagePicker();
  final ScreenshotController screenshotController =
    ScreenshotController();
  List<LayerObject> layers = [];
  String? selectedId;

  List<EditorState> redo = [];
  List<EditorState> undo = [];
  List<Color> recentColors = [];
  List<List<LayerObject>> undoStack = [];
List<List<LayerObject>> redoStack = [];

  final Color primaryPurple =
    const Color(0xFF8B5CF6);

final Color darkPurple =
    const Color(0xFF120020);

final Color glassPurple =
    const Color.fromARGB(
      80,
      139,
      92,
      246,
    );

  double startScale = 1.0;
  double startRotation = 0.0;
  
  String? resizingId;
  String? resizeDirection;
  String selectedFilter = "Original";

  int imageCount = 1;
  int textCount = 1;

  Offset? startResizePos;
  double startW = 0;
  double startH = 0;
 
  Offset? startFocalPoint;
  double startX = 0;
  double startY = 0;

  double shadowValue = 5;
  double strokeValue = 2;
  double glowValue = 20;
  bool compareMode = false;
  bool backgroundRemoveMode = false;

  double brightnessValue = 0;
  double contrastValue = 1;
  double saturationValue = 1;
  double blurValue = 0;
  double textPaddingValue = 10;

  bool magicEraseMode = false;

  bool restoreMode = false;

  LayerObject? get selectedObject {
  try {
    return layers.firstWhere((e) => e.id == selectedId);
  } catch (_) {
    return null;
  }
}

Widget glassIconButton({
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 10,
        sigmaY: 10,
      ),
      child: Container(
        width: 50,
        height: 50,

        decoration: BoxDecoration(
        
          color: Colors.white.withOpacity(0.08),

          borderRadius:
              BorderRadius.circular(15),

          border: Border.all(
            color:
                Colors.white.withOpacity(0.2),
          ),
        ),

        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
        ),
      ),
    ),
  );
}
@override
void initState() {
  super.initState();

  BackgroundRemover.instance.initializeOrt();

  _loadInitialImage();
}

Future<void> _loadInitialImage() async {

  final image = await decodeImageFromList(
    await widget.imageFile.readAsBytes(),
  );

  final aspectRatio =
      image.width / image.height;

  const double baseWidth = 250;

  layers = [
    LayerObject(
      id: UniqueKey().toString(),
      type: LayerType.image,

      x: 50,
      y: 80,

      width: baseWidth,
      height: baseWidth / aspectRatio,

      imagePath: widget.imageFile.path,

      label: "Image $imageCount",
    )
  ];

  selectedId = layers.first.id;
  imageCount = 2;

  if (mounted) {
    setState(() {});
  }
}
  void saveState() {
  undo.add(
    EditorState(
      layers: _cloneLayers(),
    ),
  );

  redo.clear();
}

void undoAction() {
  if (undo.isEmpty) return;

  // save current state to redo
  redo.add(
    EditorState(
      layers: _cloneLayers(),
    ),
  );

  final lastState = undo.removeLast();

  setState(() {
    layers = _cloneFromState(lastState);
  });
}

void duplicateLayer() {
  duplicate();
}

void redoAction() {
  if (redo.isEmpty) return;

  // save current state to undo
  undo.add(
    EditorState(
      layers: _cloneLayers(),
    ),
  );

  final nextState = redo.removeLast();

  setState(() {
    layers = _cloneFromState(nextState);
  });
}
  void addText() {
    setState(() {
      layers.add(LayerObject(
        id: UniqueKey().toString(),
        type: LayerType.text,
        x: 100,
        y: 200,
        width: 150,
        height: 50,
        text: "New Text",
        label: "Text $textCount",
      ));

      textCount++;

      selectedId = layers.last.id;
    });

    saveState();
  }

  void delete() {
    setState(() {
      layers.removeWhere((e) => e.id == selectedId);
      selectedId = null;
    });

    saveState();
  }

  void bringToFront() {

  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  saveState();

  final layer = layers.removeAt(i);

  layers.add(layer);

  setState(() {});
}

void bringToBack() {

  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  saveState();

  final layer = layers.removeAt(i);

  layers.insert(0, layer);

  setState(() {});
}

  void showLayersPanel() {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return ListView.builder(
        itemCount: layers.length,
        itemBuilder: (context, index) {
          final layer = layers.reversed.toList()[index];

          return Card(
  color: Colors.black,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(
      color: Colors.purpleAccent,
    ),
  ),
  child: ListTile(
    title: Text(
      layer.label,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
    subtitle: Text(
      layer.type.name,
      style: const TextStyle(
        color: Colors.white70,
      ),
    ),
    selected: layer.id == selectedId,
    onTap: () {
      setState(() {
        selectedId = layer.id;
      });

      Navigator.pop(context);
    },
  ),
);
        },
      );
    },
  );
}

  void editText(String value) {
    final i = layers.indexWhere((e) => e.id == selectedId);
    if (i == -1) return;

    setState(() {
      layers[i] = layers[i].copyWith(text: value);
    });

    saveState();
  }
    
void duplicate() {
  if (selectedId == null) return;

  final i = layers.indexWhere((e) => e.id == selectedId);

  if (i == -1) return;

  final layer = layers[i];

final copy = layer.copyWith(
  id: UniqueKey().toString(),
  x: layer.x + 30,
  y: layer.y + 30,
  label: "${layer.label} Copy",
);

  setState(() {
    layers.add(copy);
    selectedId = copy.id;
  });

  saveState();
}

void rotateLeft() {
  if (selectedId == null) return;

  final i = layers.indexWhere((e) => e.id == selectedId);

  if (i == -1) return;

  setState(() {
    layers[i].rotation =
    (layers[i].rotation - 0.2) % 6.28;
  });

  saveState();
}

void rotateRight() {
  if (selectedId == null) return;

  final i = layers.indexWhere((e) => e.id == selectedId);

  if (i == -1) return;

  setState(() {
    layers[i].rotation =
    (layers[i].rotation + 0.2) % 6.28;
  });

  saveState();
}

void increaseTextSize() {
  if (selectedId == null) return;

  final i = layers.indexWhere((e) => e.id == selectedId);

  if (i == -1) return;

  if (layers[i].type != LayerType.text) return;

  setState(() {
    layers[i] = layers[i].copyWith(
      fontSize: layers[i].fontSize + 2,
    );
  });

  saveState();
}

void decreaseTextSize() {
  if (selectedId == null) return;

  final i = layers.indexWhere((e) => e.id == selectedId);
  if (i == -1) return;

  if (layers[i].type != LayerType.text) return;

  setState(() {
    final newSize = layers[i].fontSize - 2;

    layers[i] = layers[i].copyWith(
      fontSize: newSize < 8 ? 8 : newSize,
    );
  });

  saveState();
}

void changeTextColor(Color color) {
  if (selectedId == null) return;

  final i = layers.indexWhere((e) => e.id == selectedId);

  if (i == -1) return;

  if (layers[i].type != LayerType.text) return;

  setState(() {
    layers[i] = layers[i].copyWith(
      textColor: color,
    );
  });

  saveState();
}

void toggleBold() {
  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  setState(() {
    layers[i] = layers[i].copyWith(
      bold: !layers[i].bold,
    );
  });
  saveState();
}

void toggleItalic() {
  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  setState(() {
    layers[i] = layers[i].copyWith(
      italic: !layers[i].italic,
    );
  });
  saveState();
}

void toggleUnderline() {
  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  setState(() {
    layers[i] = layers[i].copyWith(
      underline: !layers[i].underline,
    );
  });
  saveState();
}

void changeFontFamily(String font) {
  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  setState(() {
    layers[i] = layers[i].copyWith(
      fontFamily: font,
    );
  });
  saveState();
}

void showFontPicker() {
  final fonts = [
    "Roboto",
    "Poppins",
    "Montserrat",
    "Oswald",
    "Lato",
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E0033),
    builder: (context) {
      return ListView.builder(
        itemCount: fonts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              fonts[index],
              style: TextStyle(
                color: Colors.white,
                fontFamily: fonts[index],
                fontSize: 20,
              ),
            ),
            onTap: () {
              changeFontFamily(
                fonts[index],
              );

              Navigator.pop(context);
            },
          );
        },
      );
    },
  );
}

void showLetterSpacingSlider() {

  showPremiumSlider(

    title: "Letter Spacing",

    value:
        selectedObject?.letterSpacing ?? 0,

    min: 0,
    max: 20,

    onChanged: (value) {

      final i = layers.indexWhere(
        (e) => e.id == selectedId,
      );

      if (i == -1) return;

      setState(() {

        layers[i] =
            layers[i].copyWith(

          letterSpacing: value,

        );
      });
    },
  );
}

void changeTextAlignment(TextAlign align) {

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  setState(() {

    layers[i] = layers[i].copyWith(
      textAlign: align,
    );

  });
  saveState();
}

void showPremiumSlider({
  required String title,
  required double value,
  required double min,
  required double max,
  required Function(double) onChanged,

  VoidCallback? onColorTap,
}) {

  double currentValue = value;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,

    builder: (_) {

      return StatefulBuilder(

        builder: (context, setSheetState) {

          return Container(

            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: const Color(0xCC120022),

              borderRadius:
                  BorderRadius.circular(30),

              border: Border.all(
                color: Colors.purpleAccent,
              ),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [

                    Text(
                      "$title : ${currentValue.toStringAsFixed(1)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (onColorTap != null)

                      IconButton(

                        icon: const Icon(
                          Icons.palette,
                          color: Colors.white,
                        ),

                        onPressed: () {

                          Navigator.pop(context);

                          onColorTap();
                        },
                      ),
                  ],
                ),

                SliderTheme(

                  data: SliderTheme.of(context)
                      .copyWith(

                    activeTrackColor:
                        Colors.cyanAccent,

                    thumbColor:
                        Colors.purpleAccent,

                    overlayColor:
                        Colors.purpleAccent,
                  ),

                  child: Slider(

                    min: min,
                    max: max,

                    value: currentValue,

                    onChanged: (newValue) {

                      setSheetState(() {
                        currentValue = newValue;
                      });

                      onChanged(newValue);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showColorPicker([void Function(Color)? onColorSelected]) {
  Color selectedColor =
      selectedObject?.textColor ?? Colors.white;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF120020),

        title: const Text(
          "Choose Color",
          style: TextStyle(color: Colors.white),
        ),

        content: SingleChildScrollView(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [

      ColorPicker(
        pickerColor: selectedColor,

        onColorChanged: (color) {
          selectedColor = color;
        },

        enableAlpha: true,
        displayThumbColor: true,
        pickerAreaHeightPercent: 0.8,
      ),

      const SizedBox(height: 15),

      Wrap(
        spacing: 8,
        children: recentColors.map((c) {

          return GestureDetector(
            onTap: () {
              selectedColor = c;
            },

            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  ),
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
              if (!recentColors.contains(selectedColor)) {

  recentColors.insert(
    0,
    selectedColor,
  );

  if (recentColors.length > 8) {
    recentColors.removeLast();
  }
}

if (onColorSelected != null) {
  onColorSelected(selectedColor);
} else {
  changeTextColor(selectedColor);
}

              Navigator.pop(context);
            },
            child: const Text("Apply"),
          ),
        ],
      );
    },
  );
}

void changeShadowColor(Color color) {
  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  setState(() {
    layers[i] = layers[i].copyWith(
      shadowColor: color,
    );
  });
}

void changeGlowColor(Color color) {
  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  setState(() {
    layers[i] = layers[i].copyWith(
      glowColor: color,
    );
  });
}

void showGlowColorPicker() {
  Color tempColor = Colors.purple;

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Glow Color"),

        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (color) {
              tempColor = color;
            },
          ),
        ),

        actions: [
          ElevatedButton(
            onPressed: () {
              changeGlowColor(tempColor);
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          ),
        ],
      );
    },
  );
}

void showShadowColorPicker() {
  showDialog(
    context: context,
    builder: (_) {
      Color tempColor = Colors.black;

      return AlertDialog(
        title: const Text("Shadow Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (c) {
              tempColor = c;
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              changeShadowColor(tempColor);
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          ),
        ],
      );
    },
  );
}

void changeStrokeColor(Color color) {
  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  setState(() {
    layers[i] = layers[i].copyWith(
      strokeColor: color,
    );
  });
}

void showStrokeColorPicker() {
  showDialog(
    context: context,
    builder: (_) {
      Color tempColor = Colors.black;

      return AlertDialog(
        title: const Text("Stroke Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (c) {
              tempColor = c;
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              changeStrokeColor(tempColor);
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          ),
        ],
      );
    },
  );
}

void toggleGlow() {
  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  setState(() {
    layers[i] = layers[i].copyWith(
      glow: !layers[i].glow,
    );
  });
  saveState();
}

void toggleTextBackground() {

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  setState(() {

    layers[i] = layers[i].copyWith(
      textBackground:
          !layers[i].textBackground,
    );
  });
}

void showTextBackgroundColorPicker() {

  showColorPicker((color) {

    final i = layers.indexWhere(
      (e) => e.id == selectedId,
    );

    if (i == -1) return;

    setState(() {

      layers[i] = layers[i].copyWith(
        textBackgroundColor: color,
      );
    });
  });
}

void startResize(String id, String direction, DragStartDetails details) {
  final i = layers.indexWhere((e) => e.id == id);
  if (i == -1) return;

  resizingId = id;
  resizeDirection = direction;

  startResizePos = details.globalPosition;
  startW = layers[i].width;
  startH = layers[i].height;
  startX = layers[i].x;
  startY = layers[i].y;
}

void updateResize(DragUpdateDetails details) {
  if (resizingId == null) return;

  final i =
      layers.indexWhere((e) => e.id == resizingId);

  if (i == -1) return;

  final dx =
      details.globalPosition.dx -
      startResizePos!.dx;

  final dy =
      details.globalPosition.dy -
      startResizePos!.dy;

  setState(() {
    final obj = layers[i];

    double newW = startW;
    double newH = startH;
    double newX = startX;
    double newY = startY;

    // RIGHT
    if (resizeDirection!.contains("r")) {
      newW = startW + dx;
    }

    // LEFT
    if (resizeDirection!.contains("l")) {
      newW = startW - dx;
      newX = startX + dx;
    }

    // BOTTOM
    if (resizeDirection!.contains("b")) {
      newH = startH + dy;
    }

    // TOP
    if (resizeDirection!.contains("t")) {
      newH = startH - dy;
      newY = startY + dy;
    }

    layers[i] = obj.copyWith(
      width: newW.clamp(50, 2000),
      height: newH.clamp(50, 2000),
      x: newX,
      y: newY,
    );
  });
}

void endResize() {
  resizingId = null;
  resizeDirection = null;
}


void toggleGradient() {
  if (selectedObject == null) return;

  setState(() {
    final i = layers.indexWhere(
      (e) => e.id == selectedId,
    );

    if (i == -1) return;

    layers[i] = layers[i].copyWith(
      gradientEnabled:
          !layers[i].gradientEnabled,
    );
  });
  saveState();
}

void showUniversalColorPicker() {
  showColorPicker((color) {

    if (!recentColors.contains(color)) {

      recentColors.insert(0, color);

      if (recentColors.length > 8) {
        recentColors.removeLast();
      }
    }

    final i = layers.indexWhere(
      (e) => e.id == selectedId,
    );

    if (i == -1) return;

    setState(() {

      layers[i] = layers[i].copyWith(
  textColor: color,
  shadowColor: color,
  strokeColor: color,
  glowColor: color,
  shapeColor: color,
);

    });
  });
}

void showGradientPicker() {

  if (selectedObject == null) return;

  showModalBottomSheet(

    context: context,

    isScrollControlled: true,

    backgroundColor: Colors.transparent,

    builder: (_) {

      return Container(

        height: 400,

        decoration: const BoxDecoration(

          color: Color(0xFF1A0028),

          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),

        child: Column(

          children: [

            const SizedBox(height: 12),

            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Gradient Presets",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(

              child: ListView(

                children: [

                  _gradientTile(
                    "Purple → Blue",
                    Colors.purple,
                    Colors.blue,
                  ),

                  _gradientTile(
                    "Red → Orange",
                    Colors.red,
                    Colors.orange,
                  ),

                  _gradientTile(
                    "Green → Cyan",
                    Colors.green,
                    Colors.cyan,
                  ),

                  _gradientTile(
                    "Solo Leveling",
                    Colors.deepPurpleAccent,
                    Colors.cyanAccent,
                  ),

                  _gradientTile(
                    "Fire",
                    Colors.orange,
                    Colors.redAccent,
                  ),

                  _gradientTile(
                    "Ocean",
                    Colors.blue,
                    Colors.cyanAccent,
                  ),

                  _gradientTile(
                    "Gold",
                    Colors.amber,
                    Colors.yellow,
                  ),

                  _gradientTile(
                    "Neon",
                    Colors.pinkAccent,
                    Colors.cyanAccent,
                  ),

                  ListTile(

                    leading: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),

                    title: const Text(
                      "Remove Gradient",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),

                    onTap: () {

                      final i = layers.indexWhere(
                        (e) => e.id == selectedId,
                      );

                      if (i == -1) return;

                      setState(() {

                        layers[i] = layers[i].copyWith(
                          gradientEnabled: false,
                        );
                      });

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _gradientTile(

  String title,

  Color c1,

  Color c2,

) {

  return ListTile(

    leading: Container(

      width: 40,
      height: 40,

      decoration: BoxDecoration(

        gradient: LinearGradient(
          colors: [c1, c2],
        ),

        borderRadius:
            BorderRadius.circular(10),
      ),
    ),

    title: Text(

      title,

      style: const TextStyle(
        color: Colors.white,
      ),
    ),

    onTap: () {

      final i = layers.indexWhere(
        (e) => e.id == selectedId,
      );

      if (i == -1) return;

      setState(() {

        layers[i] = layers[i].copyWith(
          gradientColor1: c1,
          gradientColor2: c2,
          gradientEnabled: true,
        );
      });

      Navigator.pop(context);
    },
  );
}

void showShapePicker() {
  showModalBottomSheet(
    context: context,
    builder: (_) {
      return SizedBox(
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            IconButton(
              icon: const Icon(Icons.square, size: 50),
              onPressed: () {
                addShape("square");
                Navigator.pop(context);
              },
            ),

            IconButton(
              icon: const Icon(Icons.circle, size: 50),
              onPressed: () {
                addShape("circle");
                Navigator.pop(context);
              },
            ),

            IconButton(
              icon: const Icon(Icons.favorite, size: 50),
              onPressed: () {
                addShape("heart");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

void addShape(String type) {
 saveState();

  setState(() {

    layers.add(
      LayerObject(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),

        type: LayerType.shape,

        x: 100,
        y: 100,

        width: 120,
        height: 120,

        shapeType: type,

        shapeColor: Colors.purpleAccent,

        label: type,
      ),
    );

    selectedId = layers.last.id;
  });

  saveState();
}

void showShadowSlider() {

  showPremiumSlider(
  title: "Shadow",

  onColorTap:
      showShadowColorPicker,
    value: shadowValue,
    min: 0,
    max: 100,

    onChanged: (value) {

      setState(() {
        shadowValue = value;
      });

      final i = layers.indexWhere(
        (e) => e.id == selectedId,
      );

      if (i == -1) return;

      setState(() {
        layers[i] = layers[i].copyWith(
          shadowBlur: value,
        );
      });
    },
  );
}

void showStrokeSlider() {

  showPremiumSlider(
  title: "Stroke",

  onColorTap:
      showStrokeColorPicker,
    value: strokeValue,
    min: 0,
    max: 100,

    onChanged: (value) {

      setState(() {
        strokeValue = value;
      });

      final i = layers.indexWhere(
        (e) => e.id == selectedId,
      );

      if (i == -1) return;

      setState(() {
        layers[i] = layers[i].copyWith(
          strokeWidth: value,
        );
      });
    },
  );
}

void showGlowSlider() {

  if (selectedObject == null) return;

  showPremiumSlider(
  title: "Glow",

  onColorTap:
      showGlowColorPicker,

    value:
        selectedObject!.glowStrength,

    min: 0,
    max: 100,

    onChanged: (value) {

      final i = layers.indexWhere(
        (e) => e.id == selectedId,
      );

      if (i == -1) return;

      setState(() {

        layers[i] = layers[i].copyWith(
          glowStrength: value,
          glow: true,
        );
      });
    },
  );
}

void showTextPaddingSlider() {

  showPremiumSlider(
    title: "Text Padding",
    value: textPaddingValue,
    min: 0,
    max: 100,

    onChanged: (value) {

      setState(() {
        textPaddingValue = value;
      });

      final i = layers.indexWhere(
        (e) => e.id == selectedId,
      );

      if (i == -1) return;

      setState(() {
        layers[i] = layers[i].copyWith(
          padding: value,
        );
      });
    },
  );
}

void showRadiusSlider() {

  showPremiumSlider(

    title: "Corner Radius",

    value:
        selectedObject
            ?.backgroundRadius ?? 8,

    min: 0,
    max: 50,

    onChanged: (value) {

      final i = layers.indexWhere(
        (e) => e.id == selectedId,
      );

      if (i == -1) return;

      setState(() {

        layers[i] = layers[i].copyWith(
          backgroundRadius: value,
        );
      });
    },
  );
}

void applyPreset(String preset) {
  saveState();

  final i =
      layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  switch (preset) {

    case "Neon":

      layers[i] = layers[i].copyWith(
        glow: true,
        glowStrength: 20,
        glowColor: Colors.cyan,
        textColor: Colors.white,
      );

      break;

    case "Fire":

      layers[i] = layers[i].copyWith(
        glow: true,
        glowStrength: 20,
        glowColor: Colors.orange,
        textColor: Colors.red,
      );

      break;

    case "Gold":

      layers[i] = layers[i].copyWith(
        textColor: Colors.amber,
        shadowBlur: 10,
        shadowColor: Colors.black,
      );

      break;

    case "Cyber":

      layers[i] = layers[i].copyWith(
        glow: true,
        glowStrength: 15,
        glowColor: Colors.purpleAccent,
        textColor: Colors.cyan,
      );

      break;

    case "Monarch":

      layers[i] = layers[i].copyWith(
        glow: true,
        glowStrength: 25,
        glowColor: Colors.deepPurpleAccent,
        textColor: Colors.white,
        shadowBlur: 12,
      );

      break;
  }

  setState(() {});
}

void showFontSizePicker() {

  final sizes = [
    8,10,12,14,16,18,
    20,24,28,32,40,
    48,64,72,96,128
  ];

  showModalBottomSheet(
    context: context,
    builder: (_) {

      return ListView.builder(
        itemCount: sizes.length,

        itemBuilder: (_, index) {

          return ListTile(
            title: Text(
              sizes[index].toString(),
            ),

            onTap: () {

              final i =
                  layers.indexWhere(
                (e) =>
                    e.id ==
                    selectedId,
              );

              if (i == -1) return;

              setState(() {

                layers[i] =
                    layers[i]
                        .copyWith(
                  fontSize:
                      sizes[index]
                          .toDouble(),
                );
              });

              Navigator.pop(
                context,
              );
            },
          );
        },
      );
    },
  );
}

void showAdjustPanel() {

  showModalBottomSheet(
    context: context,

    backgroundColor:
        const Color(0xFF120020),

    builder: (_) {

      return SizedBox(
        height: 350,

        child: ListView(

          children: [

            ListTile(
              leading:
                  const Icon(Icons.light_mode),
              title:
                  const Text("Brightness"),
              onTap: () {
                Navigator.pop(context);
                showBrightnessSlider();
              },
            ),

            ListTile(
              leading:
                  const Icon(Icons.contrast),
              title:
                  const Text("Contrast"),
              onTap: () {
                Navigator.pop(context);
                showContrastSlider();
              },
            ),

            ListTile(
              leading:
                  const Icon(Icons.palette),
              title:
                  const Text("Saturation"),
              onTap: () {
                Navigator.pop(context);
                showSaturationSlider();
              },
            ),

            ListTile(
              leading:
                  const Icon(Icons.blur_on),
              title:
                  const Text("Blur"),
              onTap: () {
                Navigator.pop(context);
                showBlurSlider();
              },
            ),
          ],
        ),
      );
    },
  );
}

void showBrightnessSlider() {

  showPremiumSlider(

    title: "Brightness",

    value: selectedObject?.brightness ?? 0,

    min: -1,
    max: 1,

    onChanged: (value) {

      final i = layers.indexWhere(
        (e) => e.id == selectedId,
      );

      if (i == -1) return;

      setState(() {

        layers[i] =
            layers[i].copyWith(
          brightness: value,
        );
      });
    },
  );
}

void showContrastSlider() {

  showPremiumSlider(

    title: "Contrast",

    value: selectedObject?.contrast ?? 1,

    min: 0,
    max: 3,

    onChanged: (value) {

      final i = layers.indexWhere(
        (e) => e.id == selectedId,
      );

      if (i == -1) return;

      setState(() {

        layers[i] =
            layers[i].copyWith(
          contrast: value,
        );
      });
    },
  );
}

void showSaturationSlider() {

  showPremiumSlider(

    title: "Saturation",

    value: selectedObject?.saturation ?? 1,

    min: 0,
    max: 3,

    onChanged: (value) {

      final i = layers.indexWhere(
        (e) => e.id == selectedId,
      );

      if (i == -1) return;

      setState(() {

        layers[i] =
            layers[i].copyWith(
          saturation: value,
        );
      });
    },
  );
}

void showBlurSlider() {

  showPremiumSlider(

    title: "Blur",

    value: selectedObject?.blur ?? 0,

    min: 0,
    max: 20,

    onChanged: (value) {

      final i = layers.indexWhere(
        (e) => e.id == selectedId,
      );

      if (i == -1) return;

      setState(() {

        layers[i] =
            layers[i].copyWith(
          blur: value,
        );
      });
    },
  );
}

void showFilterPresets() {

  showModalBottomSheet(

    context: context,

    backgroundColor: Colors.black,

    builder: (_) {

      return SizedBox(

        height: 120,

        child: ListView(

          scrollDirection: Axis.horizontal,

          children: [

            filterCard("Original"),
            filterCard("B&W"),
            filterCard("Warm"),
            filterCard("Cool"),
            filterCard("HDR"),
            filterCard("Vintage"),
            filterCard("Cyber"),
            filterCard("Neon"),
            filterCard("Fire"),
            filterCard("Dream"),
            filterCard("Dark"),

          ],
        ),
      );
    },
  );
}

void applyFilterPreset(String preset) {

   saveState();

  setState(() {
    selectedFilter = preset;
  });

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  switch (preset) {

    case "Original":

      layers[i] = layers[i].copyWith(
        brightness: 0,
        contrast: 1,
        saturation: 1,
        blur: 0,
      );
      break;

    case "B&W":

      layers[i] = layers[i].copyWith(
        saturation: 0,
        contrast: 1.2,
      );
      break;

    case "Warm":

      layers[i] = layers[i].copyWith(
        brightness: 0.1,
        saturation: 1.4,
      );
      break;

    case "Cool":

      layers[i] = layers[i].copyWith(
        brightness: -0.05,
        saturation: 0.8,
      );
      break;

    case "HDR":

      layers[i] = layers[i].copyWith(
        contrast: 2,
        saturation: 1.5,
      );
      break;

    case "Vintage":

      layers[i] = layers[i].copyWith(
        contrast: 0.8,
        saturation: 0.7,
      );
      break;
      case "Cyber":

  layers[i] = layers[i].copyWith(
    contrast: 2,
    saturation: 2,
    brightness: 0.1,
  );
  break;

case "Neon":

  layers[i] = layers[i].copyWith(
    saturation: 3,
    contrast: 2.2,
  );
  break;

case "Fire":

  layers[i] = layers[i].copyWith(
    brightness: 0.2,
    saturation: 2.5,
  );
  break;

case "Dream":

  layers[i] = layers[i].copyWith(
    blur: 2,
    brightness: 0.15,
    saturation: 1.4,
  );
  break;

case "Dark":

  layers[i] = layers[i].copyWith(
    brightness: -0.3,
    contrast: 1.8,
  );
  break;
  }

  setState(() {});
}

Widget filterCard(String name) {

  final isSelected =
      selectedFilter == name;

  return GestureDetector(

    onTap: () {

      applyFilterPreset(name);

      Navigator.pop(context);
    },

    child: Container(

      width: 110,

      margin: const EdgeInsets.all(8),

      decoration: BoxDecoration(

        color: isSelected
            ? Colors.deepPurple
            : Colors.white12,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(

          color: isSelected
              ? Colors.cyan
              : Colors.transparent,

          width: 2,
        ),
      ),

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          const Icon(
            Icons.image,
            color: Colors.white,
            size: 40,
          ),

          const SizedBox(height: 10),

          Text(

            name,

            style: TextStyle(

              color: isSelected
                  ? Colors.cyan
                  : Colors.white,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> saveImage() async {
  try {
    final image = await screenshotController.capture(
  pixelRatio: 3.0,
);

    if (image == null) return;

    final dir = await getTemporaryDirectory();

    final file = File(
      '${dir.path}/editor_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await file.writeAsBytes(image);

    await Gal.putImage(file.path);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Saved To Gallery ✅"),
      ),
    );
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<void> saveRemovedBackground() async {

  if (selectedObject == null) return;

  if (selectedObject!.imagePath == null) return;

  try {

    await Gal.putImage(
      selectedObject!.imagePath!,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "PNG Saved ✅",
        ),
      ),
    );

  } catch (e) {

    debugPrint(e.toString());
  }
}

Future<void> shareImage() async {
  try {
    final image = await screenshotController.capture(
  pixelRatio: 3.0,
);

    if (image == null) return;

    final dir = await getTemporaryDirectory();

    final file = File(
      '${dir.path}/share_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await file.writeAsBytes(image);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
      ),
    );
  } catch (e) {
    debugPrint(e.toString());
  }
}

  Future<void> addImage() async {
  final XFile? img = await picker.pickImage(
  source: ImageSource.gallery,
);

if (img == null) return;

// ignore: unused_local_variable
final bytes = await img.readAsBytes();
final decodedImage =
    await decodeImageFromList(
  await File(img.path).readAsBytes(),
);

final aspectRatio =
    decodedImage.width /
    decodedImage.height;

setState(() {

  const double baseWidth = 250;

  double calculatedHeight =
      baseWidth / aspectRatio;

  // Portrait image-na height limit
  if (calculatedHeight > 400) {

    calculatedHeight = 400;
  }

  layers.add(

    LayerObject(

      id: UniqueKey().toString(),

      type: LayerType.image,

      x: 80,
      y: 80,

      width: baseWidth,

      height: calculatedHeight,

      imagePath: img.path,

      label: "Image $imageCount",

      opacity: 1.0,
      scale: 1.0,
      rotation: 0,
    ),
  );

  imageCount++;

  selectedId = layers.last.id;
});

  saveState();
}

Future<void> removeBackgroundAI() async {

  if (selectedObject == null) return;

  if (selectedObject!.imagePath == null) return;

  try {

    final bytes =
        await AIService.removeBackground(
      selectedObject!.imagePath!,
    );

    if (bytes == null) {

      debugPrint(
        "REMOVE BG FAILED",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Background removal failed",
          ),
        ),
      );

      return;
    }

    final tempDir =
        await getTemporaryDirectory();

    final file = File(
  "${tempDir.path}/removed_bg_${DateTime.now().millisecondsSinceEpoch}.png",
);

    await file.writeAsBytes(bytes);

    final i = layers.indexWhere(
      (e) => e.id == selectedId,
    );

    if (i == -1) return;

    saveState();

    setState(() {

      layers[i] =
          layers[i].copyWith(
        imagePath: file.path,
      );
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Background removed!",
        ),
      ),
    );

  } catch (e) {

    debugPrint(
      "REMOVE BG ERROR : $e",
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "Error : $e",
        ),
      ),
    );
  }
}

Future<void> upscaleImageAI() async {

  if(selectedObject == null) return;

  if(selectedObject!.imagePath == null) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        const Center(
      child:
          CircularProgressIndicator(),
    ),
  );

  final path =
      await AIService.upscaleImage(
    selectedObject!.imagePath!,
  );

  Navigator.pop(context);

  if(path == null){

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text(
          "Upscale failed",
        ),
      ),
    );

    return;
  }

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if(i == -1) return;

  saveState();

  setState(() {

    layers[i] =
        layers[i].copyWith(

      imagePath: path,

      width:
          layers[i].width * 2,

      height:
          layers[i].height * 2,
    );
  });

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(
      content: Text(
        "HD Upscale Complete",
      ),
    ),
  );
}

// ignore: unused_element
static Future<String?> generateImage(
  String prompt,
) async {

  final response = await http.post(

    Uri.parse(
      "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0",
    ),

    headers: {

      

      "Content-Type":
          "application/json",
    },

    body:
        '{"inputs":"$prompt"}',
  );

  print(response.statusCode);
  print(response.body);

  if (response.statusCode == 200) {

    final file = File(

      "${Directory.systemTemp.path}/ai_${DateTime.now().millisecondsSinceEpoch}.png",
    );

    await file.writeAsBytes(
      response.bodyBytes,
    );

    return file.path;
  }

  return null;
}

Future<void> showAIGenerator() async {

  final controller =
      TextEditingController();

  showDialog(

    context: context,

    builder: (_) {

      return AlertDialog(

        backgroundColor:
            Colors.black,

        title: const Text(
          "AI Image Generator",
        ),

        content: TextField(

          controller: controller,

          decoration:
              const InputDecoration(
            hintText:
                "Enter prompt...",
          ),
        ),

        actions: [

          TextButton(

            onPressed: () async {

              Navigator.pop(context);

              await generateAIImage(
                controller.text,
              );
            },

            child: const Text(
              "Generate",
            ),
          ),
        ],
      );
    },
  );
}

Future<void> generateAIImage(
  String prompt,
) async {

  // LOADING START
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  final path =
      await AIService.generateImage(
    prompt,
  );

  // LOADING STOP
  Navigator.pop(context);

  if (path == null) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "AI generation failed",
        ),
      ),
    );

    return;
  }
  saveState();

  setState(() {

    layers.add(

      LayerObject(

        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),

        type: LayerType.image,

        x: 100,
        y: 100,

        width: 300,
        height: 300,

        imagePath: path,

        label: "AI Image",
      ),
    );
  });

  ScaffoldMessenger.of(context)
      .showSnackBar(
    const SnackBar(
      content: Text(
        "AI image generated!",
      ),
    ),
  );
}

Future<void> showAIStickerGenerator() async {

  final controller =
      TextEditingController();

  showDialog(
    context: context,
    builder: (_) {

      return AlertDialog(

        backgroundColor: Colors.black,

        title: const Text(
          "AI Sticker Generator",
        ),

        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText:
                "Example: Cute cyber cat sticker",
          ),
        ),

        actions: [

          TextButton(
            onPressed: () async {

              Navigator.pop(context);

              await generateAISticker(
                controller.text,
              );
            },
            child: const Text(
              "Generate",
            ),
          ),
        ],
      );
    },
  );
}

Future<void> generateAISticker(
  String prompt,
) async {

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child:
          CircularProgressIndicator(),
    ),
  );
  

  final path =
    await AIService.generateSticker(
  "$prompt sticker, transparent background, vector style",
);

  Navigator.pop(context);

  if (path == null) return;
  saveState();

  setState(() {

    layers.add(

      LayerObject(

        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),

        type: LayerType.image,

        x: 100,
        y: 100,

        width: 250,
        height: 250,

        imagePath: path,

        label: "AI Sticker",
      ),
    );
  });
}


void cropImage() {
  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;
  saveState();

  setState(() {
    layers[i] = layers[i].copyWith(
      cropMode: true,
      cropRect: Rect.fromLTWH(
  20,
  20,

  layers[i].width * 0.7,
  layers[i].height * 0.7,
),
    );
  });
}

Future<void> applyCrop() async {

  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  final layer = layers[i];

  if (layer.imagePath == null) return;

  if (layer.cropRect == null) return;

  final bytes =
      await File(
        layer.imagePath!,
      ).readAsBytes();

  final image =
      img.decodeImage(bytes);

  if (image == null) return;

  final cropRect =
      layer.cropRect!;

  // 🔥 Screen size -> Original image size conversion

  final scaleX =
      image.width / layer.width;

  final scaleY =
      image.height / layer.height;

  final cropX =
      (cropRect.left * scaleX).toInt();

  final cropY =
      (cropRect.top * scaleY).toInt();

  final cropWidth =
      (cropRect.width * scaleX).toInt();

  final cropHeight =
      (cropRect.height * scaleY).toInt();

  final cropped =
      img.copyCrop(
    image,
    x: cropX,
    y: cropY,
    width: cropWidth,
    height: cropHeight,
  );

  final tempDir =
      await getTemporaryDirectory();

  final file = File(
    "${tempDir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png",
  );

  await file.writeAsBytes(
    img.encodePng(cropped),
  );

  saveState();

  setState(() {

    layers[i] =
        layers[i].copyWith(
      imagePath: file.path,
      cropMode: false,
      cropRect: null,

      width: cropRect.width,
      height: cropRect.height,
    );
  });

  if (!mounted) return;

  ScaffoldMessenger.of(context)
      .showSnackBar(
    const SnackBar(
      content: Text(
        "Image Cropped ✅",
      ),
    ),
  );
}

void showFilterPicker() {
  
  if (selectedId == null) return;

  showModalBottomSheet(
    context: context,

    backgroundColor: Colors.transparent,

    builder: (_) {

      return Container(

        height: 180,

        decoration: BoxDecoration(
          color: const Color(0xFF120022),

          borderRadius:
              BorderRadius.circular(25),
        ),

        child: ListView(
          scrollDirection: Axis.horizontal,

          children: [

            filterTile(
              "Solo Leveling",
              () => applyImagePreset(
                "solo",
              ),
            ),

            filterTile(
              "Cyberpunk",
              () => applyImagePreset(
                "cyber",
              ),
            ),

            filterTile(
              "Neon Glow",
              () => applyImagePreset(
                "neon",
              ),
            ),

            filterTile(
              "Anime HDR",
              () => applyImagePreset(
                "anime",
              ),
            ),

            filterTile(
              "Dark Monarch",
              () => applyImagePreset(
                "monarch",
              ),
            ),

            filterTile(
              "Golden Hour",
              () => applyImagePreset(
                "gold",
              ),
            ),

            filterTile(
              "Cinematic",
              () => applyImagePreset(
                "cinematic",
              ),
            ),

            filterTile(
              "Moody Black",
              () => applyImagePreset(
                "moody",
              ),
            ),
          ],
        ),
      );
    },
  );
}

void applyImagePreset(
  String preset,
) {

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  switch (preset) {

    case "solo":

      layers[i] = layers[i].copyWith(
        brightness: -0.1,
        contrast: 1.6,
        saturation: 1.4,
      );

      break;

    case "cyber":

      layers[i] = layers[i].copyWith(
        contrast: 2,
        saturation: 2,
      );

      break;

    case "neon":

      layers[i] = layers[i].copyWith(
        saturation: 2.5,
        contrast: 1.8,
      );

      break;

    case "anime":

      layers[i] = layers[i].copyWith(
        brightness: 0.15,
        contrast: 1.5,
        saturation: 1.8,
      );

      break;

    case "monarch":

      layers[i] = layers[i].copyWith(
        brightness: -0.25,
        contrast: 2.2,
      );

      break;

    case "gold":

      layers[i] = layers[i].copyWith(
        brightness: 0.2,
        saturation: 1.6,
      );

      break;

    case "cinematic":

      layers[i] = layers[i].copyWith(
        contrast: 1.8,
        saturation: 0.9,
      );

      break;

    case "moody":

      layers[i] = layers[i].copyWith(
        brightness: -0.3,
        saturation: 0.5,
        contrast: 1.7,
      );

      break;
  }
  saveState();

  setState(() {});
}

void showBackgroundOptions() {

  showModalBottomSheet(

    context: context,

    backgroundColor: Colors.black,

    builder: (_) {

      return SafeArea(

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            ListTile(

              leading: const Icon(
                Icons.auto_fix_high,
                color: Colors.white,
              ),

              title: const Text(
                "AI Background Remove",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

              onTap: () {

                Navigator.pop(context);

                
                backgroundRemoveMode = true;

                removeBackgroundAI();
              },
            ),

            const Divider(
              color: Colors.white24,
            ),

            const Padding(

              padding: EdgeInsets.all(12),

              child: Text(

                "Manual Eraser Coming Soon",

                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget filterTile(
  String title,
  VoidCallback onTap,
) {

  return GestureDetector(

    onTap: onTap,

    child: Container(

      width: 120,

      margin: const EdgeInsets.all(10),

      decoration: BoxDecoration(

        color: Colors.deepPurple,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Center(

        child: Text(
          title,

          textAlign: TextAlign.center,

          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

void flipImage() {
  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;
  saveState();

  setState(() {
    layers[i] = layers[i].copyWith(
      flipped: !layers[i].flipped,
    );
  });
}

void changeOpacity() {

  if (selectedId == null) return;

  final i = layers.indexWhere(
    (e) => e.id == selectedId,
  );

  if (i == -1) return;

  showPremiumSlider(

    title: "Opacity",

    value: layers[i].opacity * 100,

    min: 10,
    max: 100,

    onChanged: (value) {

      setState(() {

        layers[i] =
            layers[i].copyWith(

          opacity: value / 100,
        );
      });
    },
  );
}

  Widget buildItem(LayerObject obj) {
  switch (obj.type) {

    case LayerType.image:
      return Image.file(
        File(obj.imagePath ?? ""),
        fit: BoxFit.contain,
      );

    case LayerType.shape:

      if (obj.shapeType == "square") {
        return Container(
          width: obj.width,
          height: obj.height,
          color: Colors.purple,
        );
      }

      if (obj.shapeType == "circle") {
        return Container(
          width: obj.width,
          height: obj.height,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        );
      }

      if (obj.shapeType == "heart") {
        return const Icon(
          Icons.favorite,
          color: Colors.red,
          size: 60,
        );
      }

      return const SizedBox();

    case LayerType.box:
      return Container(
        color: Colors.blue,
      );

    case LayerType.text:
  return Text(
    obj.text ?? "",
    style: TextStyle(
      color: obj.textColor.withOpacity(
        obj.opacity,
      ),
      fontSize: obj.fontSize,
      fontFamily: obj.fontFamily,
    ),
  );
  }
}

  

  @override
  Widget build(BuildContext context) {
    Widget buildImageToolbar() {
  return Container(
    height: 70,
    decoration: BoxDecoration(
      color: const Color(0xFF120020),
      border: Border(
        top: BorderSide(
          color: const Color.fromARGB(255, 223, 64, 251),
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color.fromARGB(255, 223, 64, 251),
          blurRadius: 20,
        ),
      ],
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [

          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: delete,
          ),

          IconButton(
            icon: const Icon(
              Icons.copy,
              color: Colors.white,
            ),
            onPressed: duplicate,
          ),

          IconButton(
            icon: const Icon(
              Icons.layers,
              color: Colors.white,
            ),
            onPressed: showLayersPanel,
          ),

          IconButton(
            icon: const Icon(
              Icons.crop,
              color: Colors.white,
            ),
            onPressed: cropImage,
          ),

          IconButton(
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ),
             onPressed: applyCrop,
          ),

          IconButton(
            icon: const Icon(
              Icons.flip,
              color: Colors.white,
            ),
            onPressed: flipImage,
          ),

          IconButton(
  icon: const Icon(Icons.auto_awesome),
  onPressed: showFilterPicker,
),

          IconButton(
            icon: const Icon(
              Icons.opacity,
              color: Colors.white,
            ),
            onPressed: changeOpacity,
          ),
 
IconButton(
  icon: const Icon(
    Icons.hd,
  ),
  onPressed: upscaleImageAI,
),

IconButton(
  icon: const Icon(
    Icons.cleaning_services,
  ),
  onPressed: () {

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(

      content: Text(
        "Magic Eraser Coming Soon",
      ),
    ),
  );
},
),

Container(
  margin: const EdgeInsets.symmetric(
    horizontal: 4,
  ),

  decoration: BoxDecoration(
    color: Colors.white10,
    borderRadius:
        BorderRadius.circular(8),
  ),

  child: TextButton(
    onPressed: showBackgroundOptions,

    child: const Text(
      "BG",
      style: TextStyle(
        color: Colors.white,
        fontWeight:
            FontWeight.bold,
      ),
    ),
  ),
),

IconButton(
  icon: const Icon(Icons.filter),
  onPressed: showFilterPresets,
),

          IconButton(
  icon: const Icon(
    Icons.tune,
    color: Colors.white,
  ),
  onPressed: showAdjustPanel,
),

        ],
      ),
    ),
  );
}

    Widget buildTextToolbar() {
  return Container(
    height: 60,
    color: const Color(0xFF1E0033),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
  
  PopupMenuButton<TextAlign>(

  icon: const Icon(
    Icons.format_align_center,
  ),

  onSelected:
      changeTextAlignment,

  itemBuilder: (_) => [

    const PopupMenuItem(
      value: TextAlign.left,
      child: Text("Left"),
    ),

    const PopupMenuItem(
      value: TextAlign.center,
      child: Text("Center"),
    ),

    const PopupMenuItem(
      value: TextAlign.right,
      child: Text("Right"),
    ),

  ],
),

  PopupMenuButton<String>(

  icon: const Icon(
    Icons.auto_awesome,
  ),

  onSelected: applyPreset,

  itemBuilder: (_) => [

    const PopupMenuItem(
      value: "Neon",
      child: Text("Neon"),
    ),

    const PopupMenuItem(
      value: "Fire",
      child: Text("Fire"),
    ),

    const PopupMenuItem(
      value: "Gold",
      child: Text("Gold"),
    ),

    const PopupMenuItem(
      value: "Cyber",
      child: Text("Cyber"),
    ),

    const PopupMenuItem(
      value: "Monarch",
      child: Text("Shadow Monarch"),
    ),
  ],
),
  // DELETE
  IconButton(
    tooltip: "Delete",
    icon: const Icon(Icons.delete),
    onPressed: delete,
  ),

  // DUPLICATE
  IconButton(
    tooltip: "Duplicate",
    icon: const Icon(Icons.copy),
    onPressed: duplicate,
  ),

  // LAYERS
  IconButton(
    tooltip: "Layers",
    icon: const Icon(Icons.layers),
    onPressed: showLayersPanel,
  ),

IconButton(
            icon: const Icon(
              Icons.opacity,
              color: Colors.white,
            ),
            onPressed: changeOpacity,
          ),

  // TEXT COLOR
  IconButton(
    tooltip: "Text Color",
    icon: const Icon(Icons.palette),
    onPressed: showColorPicker,
  ),

  IconButton(
  icon: const Icon(
    Icons.rectangle,
  ),
  onPressed:
      toggleTextBackground,
),

  IconButton(
  icon: const Icon(
    Icons.format_color_fill,
  ),
  onPressed:
      showTextBackgroundColorPicker,
),

  // FONT
  IconButton(
    tooltip: "Font",
    icon: const Icon(Icons.font_download),
    onPressed: showFontPicker,
  ),

  // BOLD
  IconButton(
    tooltip: "Bold",
    icon: const Icon(Icons.format_bold),
    onPressed: toggleBold,
  ),
 
  IconButton(
  icon: const Icon(
    Icons.text_fields,
  ),
  onPressed:
      showFontSizePicker,
),

  // ITALIC
  IconButton(
    tooltip: "Italic",
    icon: const Icon(Icons.format_italic),
    onPressed: toggleItalic,
  ),

  // UNDERLINE
  IconButton(
    tooltip: "Underline",
    icon: const Icon(Icons.format_underlined),
    onPressed: toggleUnderline,
  ),

  // SHADOW STRENGTH
  IconButton(
    tooltip: "Shadow",
    icon: const Icon(Icons.dark_mode),
    onPressed: showShadowSlider,
  ),
  // STROKE STRENGTH
  IconButton(
    tooltip: "Stroke",
    icon: const Icon(Icons.outlined_flag),
    onPressed: showStrokeSlider,
  ),
  // GLOW STRENGTH
  IconButton(
    tooltip: "Glow",
    icon: const Icon(Icons.auto_awesome),
    onPressed: showGlowSlider,
  ),

  IconButton(
  icon: const Icon(Icons.gradient),
  onPressed: toggleGradient,
),

  IconButton(
  icon: const Icon(Icons.colorize),
  onPressed: showGradientPicker,
),

  IconButton(
  icon: const Icon(Icons.space_bar),
  onPressed: showLetterSpacingSlider,
),

  IconButton(
  icon: const Icon(
    Icons.padding,
  ),
  onPressed:
      showTextPaddingSlider,
),

  IconButton(
  icon: const Icon(
    Icons.rounded_corner,
  ),
  onPressed:
      showRadiusSlider,
),

],
      ),
    ),
    ),
  );
}

    return Scaffold(
      backgroundColor: const Color(0xFF120022),

      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(70),

  child: AppBar(
    backgroundColor: const Color(0xFF120020),

    titleSpacing: 0,

    title: SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: IconTheme(
  data: const IconThemeData(
    color: Colors.white,
    size: 26,
  ),
  child: Row(
    children: [

  glassIconButton(
  icon: Icons.undo,
  onPressed: undoAction,
),

  glassIconButton(
  icon: Icons.redo,
  onPressed: redoAction,
),

  glassIconButton(
  icon: Icons.image,
  onPressed: addImage,
),

glassIconButton(
  icon: Icons.text_fields,
  onPressed: addText,
),

  glassIconButton(
  icon: selectedObject?.locked == true
      ? Icons.lock
      : Icons.lock_open,

  onPressed: () {

    if (selectedId == null) return;

    final i = layers.indexWhere(
      (e) => e.id == selectedId,
    );

    if (i == -1) return;

    saveState();

    setState(() {

      layers[i] = layers[i].copyWith(
        locked: !layers[i].locked,
      );
    });
  },
),

  glassIconButton(
  icon: Icons.category,
  onPressed: showShapePicker,
),

glassIconButton(
  icon: Icons.emoji_emotions,
  onPressed: showAIStickerGenerator,
),

  glassIconButton(
  icon: Icons.palette,
  onPressed: showUniversalColorPicker,
),

  glassIconButton(

  icon: Icons.save,

  onPressed: () {

    if (backgroundRemoveMode) {

      saveRemovedBackground();

    } else {

      saveImage();
    }
  },
),

  glassIconButton(
  icon: Icons.auto_awesome,
  onPressed: showAIGenerator,
),

  glassIconButton(
  icon: 
    compareMode
        ? Icons.visibility
        : Icons.compare,

  onPressed: () {

    setState(() {

      compareMode =
          !compareMode;
    });
  },
),

  PopupMenuButton<String>(
    onSelected: (value) {

      if (value == "delete") {
        delete();
      }

      if (value == "layers") {
        showLayersPanel();
      }

      if (value == "duplicate") {
        duplicateLayer();
      }

      if (value == "front") {
        bringToFront();
      }

      if (value == "back") {
        bringToBack();
      }

      if (value == "share") {
        shareImage();
      }
    },

    itemBuilder: (context) => [

      const PopupMenuItem(
        value: "layers",
        child: Text("Layers"),
      ),

      const PopupMenuItem(
        value: "duplicate",
        child: Text("Duplicate"),
      ),

      const PopupMenuItem(
        value: "front",
        child: Text("Bring To Front"),
      ),

      const PopupMenuItem(
        value: "back",
        child: Text("Bring To Back"),
      ),

      const PopupMenuItem(
        value: "share",
        child: Text("Share"),
      ),

      const PopupMenuItem(
        value: "delete",
        child: Text("Delete"),
      ),
    ],
  ),
],
  ),
      ),
    ),
  ),
      ),

      bottomNavigationBar: selectedObject == null
          ? null
          : selectedObject!.type == LayerType.text
              ? buildTextToolbar()
              : buildImageToolbar(),

      body: GestureDetector(
  onTap: () {
    setState(() {
      selectedId = null;
    });
  },
  child: Screenshot(
  controller: screenshotController,
  child: Center(
    child: Container(
  width: 350,
  height: 600,

  clipBehavior: Clip.hardEdge,

  decoration: BoxDecoration(
    color: Colors.black,
    border: Border.all(
      color: Colors.cyanAccent,
      width: 2,
    ),
  ),

  child: Stack(
        children: [
          Container(color: const Color(0xFF120022)),

         ...layers.map((obj) {
  return LayerWidget(
    obj: obj,
    selected: obj.id == selectedId,

    compareMode: compareMode,

    magicEraseMode: magicEraseMode,

  
    onResizeStart: startResize,
    onResizeUpdate: updateResize,
    onResizeEnd: endResize,

    onSelect: () {
      setState(() {
        selectedId = obj.id;
      });
    },

    onUpdateDrag: (dx, dy) {
      if (selectedId != obj.id) return; // 🔥 CRITICAL FIX
      setState(() {
       final i = layers.indexWhere((e) => e.id == obj.id);
       if (i == -1) return;
       
       if (layers[i].locked) return;

       double newX =
    layers[i].x + dx;

double newY =
    layers[i].y + dy;

if (newX < 0) newX = 0;
if (newY < 0) newY = 0;

if (newX >
    350 - layers[i].width) {

  newX =
      350 - layers[i].width;
}

if (newY >
    600 - layers[i].height) {

  newY =
      600 - layers[i].height;
}

layers[i] = layers[i].copyWith(
  x: newX,
  y: newY,
);
      });
    },

    onDoubleTap: () {
      if (obj.type != LayerType.text) return;

      final controller = TextEditingController(
        text: obj.text ?? "",
      );

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Edit Text"),

            content: TextField(
              controller: controller,
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
                  setState(() {
                    obj.text = controller.text;
                  });

                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },

    onUpdate: () {
      setState(() {});
    },
    onScaleStart: (scale, rotation) {

      startFocalPoint = null;
      startX = obj.x;
      startY = obj.y;

      startScale = scale;
      startRotation = rotation;
    },

onScaleGesture: (details) {
  setState(() {
    final i = layers.indexWhere((e) => e.id == obj.id);
    if (i == -1) return;

    final layer = layers[i];

    if (layer.locked) return;
    // Move (using scale gesture translation)
    layers[i] = layer.copyWith(
      x: layer.x + details.focalPointDelta.dx,
      y: layer.y + details.focalPointDelta.dy,
      scale: startScale * details.scale,
      rotation: startRotation + details.rotation,
    );
  });
},
onCropMove: (dx, dy) {

  final i =
      layers.indexWhere(
        (e) => e.id == obj.id,
      );

  if (i == -1) return;

  final rect =
      layers[i].cropRect;

  if (rect == null) return;

  setState(() {

    layers[i] =
        layers[i].copyWith(

      cropRect:

          Rect.fromLTWH(

        rect.left + dx,
        rect.top + dy,

        rect.width,
        rect.height,
      ),
    );
  });
},

onCropResize: (dx, dy) {

  final i =
      layers.indexWhere(
        (e) => e.id == obj.id,
      );

  if (i == -1) return;

  final rect =
      layers[i].cropRect;

  if (rect == null) return;

  double newWidth =
      rect.width + dx;

  double newHeight =
      rect.height + dy;

  if (newWidth < 50) {
    newWidth = 50;
  }

  if (newHeight < 50) {
    newHeight = 50;
  }

  setState(() {

    layers[i] =
        layers[i].copyWith(

      cropRect:
          Rect.fromLTWH(

        rect.left,
        rect.top,

        newWidth,
        newHeight,
      ),
    );
  });
},

  );
}),
        ],
      ),
    ),
  ),
  ),
      ),
); 
  }
  List<LayerObject> _cloneLayers() {
  return layers.map((e) => e.copyWith()).toList();
}

List<LayerObject> _cloneFromState(EditorState state) {
  return state.layers.map((e) => e.copyWith()).toList();
}
}