import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_plataform/game/actors/coin.dart';
import 'package:flame_plataform/game/actors/door.dart';
import 'package:flame_plataform/game/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:tiled/tiled.dart';

import '../actors/enemy.dart';
import '../actors/platform.dart';
import '../actors/player.dart';

class Level extends Component with HasGameRef<PlatformGame> {
  final String levelName;
  late Player _player;
  late Rect _levelBounds;
  Level(this.levelName) : super();

  @override
  Future<void> onLoad() async {
    final level = await TiledComponent.load(levelName, Vector2.all(32));
    add(level);

    _levelBounds = Rect.fromLTWH(
      0,
      0,
      (level.tileMap.map.width * level.tileMap.map.tileWidth).toDouble(),
      (level.tileMap.map.height * level.tileMap.map.tileHeight).toDouble(),
    );

    _spawnActors(level.tileMap);
    _setupCamera();

    return super.onLoad();
  }

  void _spawnActors(RenderableTiledMap tileMap) {
    final spawnPointsLayer = tileMap.getLayer<ObjectGroup>('SpawnPoints');
    for (final spawnPoint in spawnPointsLayer!.objects) {
      final position = Vector2(spawnPoint.x, spawnPoint.y - spawnPoint.height);
      final size = Vector2(spawnPoint.width, spawnPoint.height);
      switch (spawnPoint.class_) {
        case 'Player':
          _player = Player(
            gameRef.spriteSheet,
            levelBounds: _levelBounds,
            anchor: Anchor.center,
            position: position,
            size: size,
          );
          add(_player);
          break;
        case 'Enemy':
          final targetObjectId = int.parse(spawnPoint.properties.first.value);
          final target = spawnPointsLayer.objects
              .firstWhere((object) => object.id == targetObjectId);
          final enemy = Enemy(
            gameRef.spriteSheet,
            targetPosition: Vector2(target.x, target.y),
            position: position,
            size: size,
          );
          add(enemy);
          break;
        case 'Door':
          final door = Door(gameRef.spriteSheet, position: position, size: size,
              onPlayerEnter: () {
            if (gameRef.playerData.health.value < 3) {
              gameRef.playerData.health.value++;
            }
            gameRef.loadLevel(spawnPoint.properties.first.value);
          });
          add(door);
          break;
        case 'Coin':
          final coin = Coin(
            gameRef.spriteSheet,
            position: position,
            size: size,
          );
          add(coin);
          break;
      }
    }

    final platformsLayer = tileMap.getLayer<ObjectGroup>('Platforms');
    for (final platformObject in platformsLayer!.objects) {
      final platform = Platform(
        position: Vector2(platformObject.x, platformObject.y),
        size: Vector2(platformObject.width, platformObject.height),
      );
      add(platform);
    }
  }

  void _setupCamera() {
    gameRef.camera.followComponent(_player);
    gameRef.camera.worldBounds = _levelBounds;
  }
}
