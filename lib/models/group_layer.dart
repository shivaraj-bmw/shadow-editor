import 'layer_object.dart';

class GroupLayer {
  String id;
  List<LayerObject> children;

  GroupLayer({
    required this.id,
    required this.children,
  });
}