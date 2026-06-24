import '../models/layer_object.dart';

class SnapService {
  static void snapToCenter(LayerObject obj, double canvasWidth) {
    final centerX = canvasWidth / 2;
    if ((obj.x - centerX).abs() < 5) {
      obj.x = centerX;
    }
  }
}