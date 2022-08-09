import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_plataform/game/actors/player.dart';
import 'package:flame_plataform/game/game.dart';

class Enemy extends SpriteComponent
    with CollisionCallbacks, HasGameRef<PlatformGame> {
  static final _up = Vector2(0, -1);
  Enemy(
    Image image, {
    Paint? paint,
    Vector2? targetPosition,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super.fromImage(
          image,
          srcPosition: Vector2(1 * 32, 0),
          srcSize: Vector2.all(32),
          paint: paint,
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    if (targetPosition != null && position != null) {
      final effect = SequenceEffect(
        [
          MoveToEffect(
            targetPosition,
            EffectController(speed: 100),
            onComplete: () => flipHorizontallyAroundCenter(),
          ),
          MoveToEffect(
            position + Vector2(32, 0),
            EffectController(speed: 100),
            onComplete: () => flipHorizontallyAroundCenter(),
          ),
        ],
        infinite: true,
      );
      add(effect);
    }
  }

  @override
  Future<void>? onLoad() {
    add(CircleHitbox()..collisionType = CollisionType.passive);
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      final playerDir = (other.absoluteCenter - absoluteCenter).normalized();
      if (playerDir.dot(_up) > 0.85) {
        add(
          OpacityEffect.fadeOut(
            EffectController(
              alternate: true,
              duration: 0.1,
              repeatCount: 3,
            ),
            onComplete: () {
              gameRef.playerData.score.value++;
              removeFromParent();
            } 
          ),
        );
        other.jump();
      } else {
        other.hit();
        if (gameRef.playerData.health.value > 0 &&
            !gameRef.playerData.invicible.value) {
          gameRef.playerData.health.value--;
        }
        gameRef.playerData.invicible.value = true;
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
