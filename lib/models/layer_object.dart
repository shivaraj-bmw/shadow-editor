import 'package:flutter/material.dart';
enum LayerType {
  image,
  text,
  box,
  shape,
}

class LayerObject {
  String id;
  LayerType type;

  double x;
  double y;
  double width;
  double height;
  double fontSize;
  String fontFamily;
  double rotation;
  double scale;

  bool cropMode;
  Rect? cropRect;

  Color textColor;

  final bool glow;
  final double glowStrength;
  final Color glowColor;

  bool bold;
  bool italic;
  bool underline;

  List<Offset> erasePoints;

  bool eraserMode;
  double brushSize;

  double shadowBlur;
  Color shadowColor;

  double strokeWidth;
  Color strokeColor;

  bool gradientEnabled;
  Color gradientColor1;
  Color gradientColor2;

  double letterSpacing;
  String shapeType;
  Color shapeColor;

  bool textBackground;
  Color textBackgroundColor;
  double padding;
  TextAlign textAlign;
  double backgroundRadius;

  double opacity;
  bool flipped;

  double brightness;
  double contrast;
  double saturation;
  double blur;

  bool locked;
  bool visible;

  String? imagePath;
  String? text;
  String label;

  LayerObject({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.fontSize = 24,
    this.fontFamily = "Roboto",
    this.textColor = Colors.white,

    this.glow = false,
    this.glowStrength = 5,
    this.glowColor = Colors.cyan,

    this.bold = false,
    this.italic = false,
    this.underline = false,

    this.erasePoints = const [],

    this.eraserMode = false,
    this.brushSize = 30,
    bool compareMode = false,

    this.shadowBlur = 0,
    this.shadowColor = Colors.black,

    this.strokeWidth = 0,
    this.strokeColor = Colors.black,

    this.gradientEnabled = false,
    this.gradientColor1 = Colors.purple,
    this.gradientColor2 = Colors.blue,

    this.letterSpacing = 0,
    this.shapeType = "square",
    this.shapeColor = Colors.purple,

    this.textBackground = false,
    this.textBackgroundColor = Colors.black,
    this.padding = 10,
    this.textAlign = TextAlign.center,
    this.backgroundRadius = 8,

    this.opacity = 1.0,
    this.flipped = false,

    this.brightness = 0,
    this.contrast = 1,
    this.saturation = 1,
    this.blur = 0,

    this.locked = false,
    this.visible = true,
    this.width = 150,
    this.height = 150,
    this.rotation = 0,
    this.scale = 1.0,
    this.cropMode = false,
    this.cropRect,
    this.imagePath,
    this.text,
    this.label = "",
  });

  LayerObject copyWith({
    String? id,
    LayerType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? scale,
    bool? cropMode,
    Rect? cropRect,
    double? fontSize,
    String? fontFamily,
    Color? textColor,

    bool? glow,
    double? glowStrength,
    Color? glowColor,

    bool? bold,
    bool? italic,
    bool? underline,

    List<Offset>? erasePoints,

    bool? eraserMode,
    double? brushSize,

    double? shadowBlur,
    Color? shadowColor,

    double? strokeWidth,
    Color? strokeColor,

    bool? gradientEnabled,
    Color? gradientColor1,
    Color? gradientColor2,

    double? letterSpacing,
    String? shapeType,
    Color? shapeColor,

    bool? textBackground,
    Color? textBackgroundColor,
    double? padding,
    TextAlign? textAlign,
    double? backgroundRadius,

    double? opacity,
    bool? flipped,

    double? brightness,
    double? contrast,
    double? saturation,
    double? blur,  

    bool? locked,
    bool? visible,
    String? imagePath,
    String? text,
    String? label,
  }) {
    return LayerObject(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,

      cropMode: cropMode ?? this.cropMode,
      cropRect: cropRect ?? this.cropRect,
  
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      textColor: textColor ?? this.textColor,

      glow: glow ?? this.glow,
      glowStrength: glowStrength ?? this.glowStrength,
      glowColor: glowColor ?? this.glowColor,

      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,

      erasePoints:
    erasePoints ??
    this.erasePoints,

      eraserMode:
    eraserMode ?? this.eraserMode,

brushSize:
    brushSize ?? this.brushSize,

      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowColor: shadowColor ?? this.shadowColor,

      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeColor: strokeColor ?? this.strokeColor,

      gradientEnabled:
        gradientEnabled ?? this.gradientEnabled,

      gradientColor1:
        gradientColor1 ?? this.gradientColor1,

      gradientColor2:
        gradientColor2 ?? this.gradientColor2,

      letterSpacing: letterSpacing ?? this.letterSpacing,  
      shapeType: shapeType ?? this.shapeType,
      shapeColor: shapeColor ?? this.shapeColor,

      textBackground:
        textBackground ?? this.textBackground,

      textBackgroundColor:
        textBackgroundColor ??
        this.textBackgroundColor,

      padding:
        padding ??
        this.padding,

      textAlign: textAlign ?? this.textAlign,
      backgroundRadius:
    backgroundRadius ??
    this.backgroundRadius,

      opacity: opacity ?? this.opacity,
      flipped: flipped ?? this.flipped,

      brightness:
        brightness ?? this.brightness,

      contrast:
        contrast ?? this.contrast,

      saturation:
        saturation ?? this.saturation,

      blur:
        blur ?? this.blur,

      locked: locked ?? this.locked,
      visible: visible ?? this.visible,
      imagePath: imagePath ?? this.imagePath,
      text: text ?? this.text,
      label: label ?? this.label,
    );
  }
}