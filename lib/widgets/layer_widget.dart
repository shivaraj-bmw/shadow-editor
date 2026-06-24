import 'dart:io';
import 'package:flutter/material.dart';
import '../models/layer_object.dart';
import 'dart:ui';

class LayerWidget extends StatelessWidget {
  final LayerObject obj;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onUpdate;
  final VoidCallback? onDoubleTap;
  final bool compareMode;

  final Function(double dx, double dy)?
    onCropMove;
  final Function(
  double dx,
  double dy,
)? onCropResize;  
  final Function(String,String,DragStartDetails)? onResizeStart;
  final Function(DragUpdateDetails)? onResizeUpdate;
  final VoidCallback? onResizeEnd;

  final Function(double,double)? onScaleStart;
  final Function(double,double)? onScaleUpdate;
  final Function(ScaleUpdateDetails)? onScaleGesture;
  final Function(double dx, double dy)? onUpdateDrag;

  final bool magicEraseMode;

  const LayerWidget({
    super.key,
    required this.obj,
    required this.selected,
    required this.onSelect,
    required this.onUpdate,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onDoubleTap,
    required this.compareMode,
    this.onCropMove,
    this.onCropResize,
    this.onResizeStart,
    this.onResizeUpdate,
    this.onResizeEnd,
    this.onScaleGesture,
    this.onUpdateDrag,
this.magicEraseMode = false,
});

  Widget _build() {
  switch (obj.type) {

    case LayerType.shape:

      if (obj.shapeType == "square") {
        return Container(
          width: obj.width,
          height: obj.height,
          color: obj.shapeColor,
        );
      }

      if (obj.shapeType == "circle") {
        return Container(
  width: obj.width,
  height: obj.height,
  decoration: BoxDecoration(
    color: obj.shapeColor,
    shape: BoxShape.circle,
  ),
);
      }

      if (obj.shapeType == "heart") {
        return Icon(
  Icons.favorite,
  color: obj.shapeColor,
  size: 120,
);
      }

      return const SizedBox();

    case LayerType.image:
    if (compareMode) {

  return SizedBox(
  width: obj.width,
  height: obj.height,
  child: Image.file(
    File(obj.imagePath ?? ""),
    fit: BoxFit.fill,
  ),
);
}

  final s = obj.saturation;

  return Opacity(
    opacity: obj.opacity,

    child: Transform.flip(
      flipX: obj.flipped,

      child: ColorFiltered(
        colorFilter: ColorFilter.matrix([

          // SATURATION MATRIX
          0.213 + 0.787 * s,
          0.715 - 0.715 * s,
          0.072 - 0.072 * s,
          0,
          0,

          0.213 - 0.213 * s,
          0.715 + 0.285 * s,
          0.072 - 0.072 * s,
          0,
          0,

          0.213 - 0.213 * s,
          0.715 - 0.715 * s,
          0.072 + 0.928 * s,
          0,
          0,

          0,
          0,
          0,
          1,
          0,
        ]),

        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: obj.blur,
            sigmaY: obj.blur,
          ),

          child: ColorFiltered(
            colorFilter: ColorFilter.matrix([

              obj.contrast,
              0,
              0,
              0,
              obj.brightness * 255,

              0,
              obj.contrast,
              0,
              0,
              obj.brightness * 255,

              0,
              0,
              obj.contrast,
              0,
              obj.brightness * 255,

              0,
              0,
              0,
              1,
              0,
            ]),

            child: SizedBox(

  width: obj.width,

  height: obj.height,

  child: Image.file(

    File(obj.imagePath ?? ""),

    fit: BoxFit.fill,
  ),
),
            ),
          ),
        ),
      ),
    );
  
    case LayerType.text:

      Shader? shader;

      if (obj.gradientEnabled) {
        shader = LinearGradient(
          colors: [
            obj.gradientColor1,
            obj.gradientColor2,
          ],
        ).createShader(
          const Rect.fromLTWH(
            0,
            0,
            300,
            100,
          ),
        );
      }

      return Opacity(

  opacity: obj.opacity,

  child: Container(
  padding: EdgeInsets.all(
    obj.textBackground
        ? obj.padding
        : 0,
  ),

  decoration:
      obj.textBackground
          ? BoxDecoration(
              color:
                  obj.textBackgroundColor,
              borderRadius:
    BorderRadius.circular(
      obj.backgroundRadius,
    ),
            )
          : null,

  child: Stack(
        children: [

          // STROKE TEXT
          if (obj.strokeWidth > 0)
  SizedBox(
    width: obj.width,
    child: Text(
      obj.text ?? "Text",
      textAlign: obj.textAlign,
      style: TextStyle(
                fontSize: obj.fontSize,
                letterSpacing: obj.letterSpacing,
                fontFamily: obj.fontFamily,

                fontWeight: obj.bold
                    ? FontWeight.bold
                    : FontWeight.normal,

                fontStyle: obj.italic
                    ? FontStyle.italic
                    : FontStyle.normal,

                decoration: obj.underline
                    ? TextDecoration.underline
                    : TextDecoration.none,

                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = obj.strokeWidth
                  ..color = obj.strokeColor,
              ),
    ),
            ),

          // MAIN TEXT
          SizedBox(
  width: obj.width,
  child: Text(
    obj.text ?? "Text",
    textAlign: obj.textAlign,
            style: TextStyle(
              fontSize: obj.fontSize,
              letterSpacing: obj.letterSpacing,
              fontFamily: obj.fontFamily,

              fontWeight: obj.bold
                  ? FontWeight.bold
                  : FontWeight.normal,

              fontStyle: obj.italic
                  ? FontStyle.italic
                  : FontStyle.normal,

              decoration: obj.underline
                  ? TextDecoration.underline
                  : TextDecoration.none,

              foreground: shader != null
                  ? (Paint()..shader = shader)
                  : null,

              color: shader == null
                  ? obj.textColor
                  : null,

              shadows: [

                if (obj.shadowBlur > 0)
                  Shadow(
                    color: obj.shadowColor,
                    blurRadius: obj.shadowBlur,
                    offset: const Offset(2, 2),
                  ),

                if (obj.glow)
                  Shadow(
                    color: obj.glowColor,
                    blurRadius: obj.glowStrength,
                  ),

                if (obj.glow)
                  Shadow(
                    color: obj.glowColor,
                    blurRadius: obj.glowStrength * 2,
                  ),
              ],
            ),
          ),
          ),
        ],
  ),
  ),
      );
      

    case LayerType.box:
      return Container(
        color: Colors.blue,
      );
  }
}
  @override
Widget build(BuildContext context) {
  return Positioned(
    left: obj.x,
    top: obj.y,
    child: GestureDetector(
  onTap: () {

  if (magicEraseMode) {
    return;
  }

  onSelect();
},
  onDoubleTap: onDoubleTap,

  // 🔥 SCALE START (store initial values)
  onScaleStart: (details) {
    if (onScaleStart != null) {
      onScaleStart!(
        obj.scale,
        obj.rotation,
      );
    }
  },

  // 🔥 SINGLE GESTURE ENGINE (MOVE + SCALE + ROTATE)
  onScaleUpdate: (details) {

  if (obj.locked) return;

  if (onScaleGesture != null) {
    onScaleGesture!(details);
  }
},

  child: Transform.rotate(

  angle: obj.rotation,

  child: Transform.scale(

    scale: obj.scale,

    child: Stack(

      clipBehavior: Clip.none,

      children: [

        Container(

          width: obj.width,
          height: obj.height,

          decoration: selected
              ? BoxDecoration(
                  border: Border.all(
                    color: Colors.cyanAccent,
                    width: 2,
                  ),
                  borderRadius:
                      obj.type == LayerType.image
                          ? BorderRadius.circular(8)
                          : BorderRadius.zero,
                )
              : null,

          child: Stack(

            children: [

              _build(),

              // CROP OVERLAY
              if (obj.cropMode &&
                  obj.cropRect != null)

                Positioned(

                  left: obj.cropRect!.left,
                  top: obj.cropRect!.top,

                  child: GestureDetector(

                    onPanUpdate: (details) {

                      if (onCropMove != null) {

                        onCropMove!(
                          details.delta.dx,
                          details.delta.dy,
                        );
                      }
                    },

                    child: Stack(

                      clipBehavior: Clip.none,

                      children: [

                        Container(

                          width:
                              obj.cropRect!.width,

                          height:
                              obj.cropRect!.height,

                          decoration: BoxDecoration(

                            border: Border.all(
                              color: Colors.yellow,
                              width: 2,
                            ),

                            color: Colors.yellow
                                .withValues(alpha: 0.1),
                          ),
                        ),

                        Positioned(
  right: -8,
  bottom: -8,

  child: GestureDetector(

    onPanUpdate: (details) {

      if (onCropResize != null) {

        onCropResize!(
          details.delta.dx,
          details.delta.dy,
        );
      }
    },

    child: Container(

      width: 16,
      height: 16,

      decoration:
          const BoxDecoration(
        color: Colors.yellow,
        shape: BoxShape.circle,
      ),
    ),
  ),
),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (selected) ...[

          _buildHandle("tl", obj.id),
          _buildHandle("tr", obj.id),

          _buildHandle("bl", obj.id),
          _buildHandle("br", obj.id),

          _buildHandle("top", obj.id),
          _buildHandle("bottom", obj.id),

          _buildHandle("left", obj.id),
          _buildHandle("right", obj.id),
        ],
      ],
    ),
  ),
),
),
  );
}
Widget _buildHandle(String dir, String id) {

  if (obj.locked) {
  return const SizedBox();
}

  double? left;
  double? right;
  double? top;
  double? bottom;

  switch(dir){

    case "tl":
      left = -7;
      top = -7;
      break;

    case "tr":
      right = -7;
      top = -7;
      break;

    case "bl":
      left = -7;
      bottom = -7;
      break;

    case "br":
      right = -7;
      bottom = -7;
      break;

    case "top":
      left = obj.width / 2 - 7;
      top = -7;
      break;

    case "bottom":
      left = obj.width / 2 - 7;
      bottom = -7;
      break;

    case "left":
      left = -7;
      top = obj.height / 2 - 7;
      break;

    case "right":
      right = -7;
      top = obj.height / 2 - 7;
      break;
  }

  return Positioned(
  left: left,
  right: right,
  top: top,
  bottom: bottom,
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,

    onPanStart: (details) {
      if (onResizeStart != null) {
        onResizeStart!(id, dir, details);
      }
    },

    onPanUpdate: (details) {
      if (onResizeUpdate != null) {
        onResizeUpdate!(details);
      }
    },

    onPanEnd: (_) {
      if (onResizeEnd != null) {
        onResizeEnd!();
      }
    },

    child: SizedBox(
      width: 24,
      height: 24,

      child: Center(
        child: RepaintBoundary(
          child: Container(
            width: 12,
            height: 12,

            decoration: BoxDecoration(
              color: Colors.cyanAccent,

              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),

              shape: BoxShape.circle,

              boxShadow: const [
                BoxShadow(
                  color: Colors.cyanAccent,
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
}
}