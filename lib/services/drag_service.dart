import '../models/layer_object.dart';

class DragService {
  static void update(
    LayerObject obj,
    double dx,
    double dy,
  ) {
    obj.x += dx;
    obj.y += dy;
  }
}