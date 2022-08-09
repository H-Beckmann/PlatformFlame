import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_plataform/game/hud/hud.dart';
import 'package:flame_plataform/game/level/level.dart';
import 'package:flame_plataform/game/model/player_model.dart';

class PlatformGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  Level? _currentLevel;

  late Image spriteSheet;
  final playerData = PlayerData();
  @override
  Future<void> onLoad() async {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();

    spriteSheet = await images.load('Spritesheet.png');

    camera.viewport = FixedResolutionViewport(Vector2(700, 360));

    loadLevel('Level2.tmx');
    add(Hud(priority: 1));

    return super.onLoad();
  }

  void loadLevel(String levelName) {
    _currentLevel?.removeFromParent();
    _currentLevel = Level(levelName);
    add(_currentLevel!);
  }
}
