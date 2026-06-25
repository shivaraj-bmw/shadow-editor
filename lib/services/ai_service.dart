// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_background_remover/image_background_remover.dart';
import 'dart:ui' as ui;

class AIService {

  // REMOVE BG
static Future<Uint8List?> removeBackground(
  String imagePath,
) async {

  try {

    final imageBytes =
        await File(imagePath)
            .readAsBytes();

    final resultImage =
        await BackgroundRemover.instance
            .removeBg(imageBytes);

    final byteData =
        await resultImage.toByteData(
      format:
          ui.ImageByteFormat.png
    );

    if (byteData == null) {
      return null;
    }

    return byteData.buffer
        .asUint8List();

  } catch (e) {

    print(e);

    return null;
  }
}

  // AI IMAGE GENERATOR
  static Future<String?> generateImage(
  String prompt,
) async {

  final url =
      "https://image.pollinations.ai/prompt/${Uri.encodeComponent(prompt)}";

  final response =
      await http.get(Uri.parse(url));

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

static Future<String?> generateSticker(
  String prompt,
) async {

  return await generateImage(
    prompt,
  );
}

static Future<String?> upscaleImage(
  String imagePath,
) async {

  final bytes =
      await File(imagePath).readAsBytes();

  final response = await http.post(

    Uri.parse(
      "https://api-inference.huggingface.co/models/caidas/swin2SR-classical-sr-x2-64",
    ),

    headers: {
      

      "Content-Type":
          "application/octet-stream",
    },

    body: bytes,
  );

  if (response.statusCode == 200) {

    final file = File(

      "${Directory.systemTemp.path}/upscaled_${DateTime.now().millisecondsSinceEpoch}.png",
    );

    await file.writeAsBytes(
      response.bodyBytes,
    );
    return file.path;
  }
  return null;
}
}