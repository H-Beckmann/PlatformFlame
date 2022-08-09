import 'package:flutter/foundation.dart';

class PlayerData {
  final score = ValueNotifier<int>(0);
  final health = ValueNotifier<int>(5);
  final invicible = ValueNotifier<bool>(false);
}
