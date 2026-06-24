import '../models/layer_object.dart';

class ResizeService {
  static void resize(
    LayerObject obj,
    double dx,
    double dy,
  ) {
    obj.width += dx;
    obj.height += dy;

    if (obj.width < 50) obj.width = 50;
    if (obj.height < 50) obj.height = 50;
  }
}