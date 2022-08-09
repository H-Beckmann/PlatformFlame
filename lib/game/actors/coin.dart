import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_plataform/game/actors/player.dart';
import 'package:flame_plataform/game/game.dart';
import 'package:flutter/animation.dart';

class Coin extends SpriteComponent
    with CollisionCallbacks, HasGameRef<PlatformGame> {
      static bool _hit = false;
  Coin(
    Image image, {
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super.fromImage(
          image,
          srcPosition: Vector2(3 * 32, 0),
          srcSize: Vector2.all(32),
          paint: paint,
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  @override
  Future<void>? onLoad() {
    add(CircleHitbox()..collisionType = CollisionType.passive);
    add(
      MoveEffect.by(
        Vector2(0, -4),
        EffectController(
          alternate: true,
          infinite: true,
          duration: 1,
          curve: Curves.ease,
        ),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !_hit) {
      _hit=true;
      add(MoveEffect.by(
        Vector2(0, -50),
        EffectController(
          duration: 0.3,
        ),
      )..onComplete = () {
          add(OpacityEffect.fadeOut(
            LinearEffectController(0.3),
          )..onComplete = () {
              add(RemoveEffect());
              _hit=false;
            });
        });
      gameRef.playerData.score.value += 5;
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
