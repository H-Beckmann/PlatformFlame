import 'dart:ui';
import 'package:flame/effects.dart';
import 'package:flame_plataform/game/game.dart';
import 'package:flutter/services.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'platform.dart';

class Player extends SpriteComponent with CollisionCallbacks, KeyboardHandler, HasGameRef<PlatformGame> {
  final double _gravity = 10;
  final double _jumpSpeed = 350;
  final Vector2 _playerVelocity = Vector2.zero();
  final double _moveSpeed = 200;
  final Vector2 _up = Vector2(0, -1);
  bool _jumpInput = false;
  bool _isOnGround = false;
  late Vector2 _minClamp;
  late Vector2 _maxClamp;
  int _hAxisInput = 0;
  Player(
    Image image, {
    required Rect levelBounds,
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super.fromImage(
          image,
          srcPosition: Vector2.zero(),
          srcSize: Vector2.all(32),
          paint: paint,
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    final halfSize = (size! / 2);
    _minClamp = levelBounds.topLeft.toVector2() + halfSize;
    _maxClamp = levelBounds.bottomRight.toVector2() - halfSize;
  }

  @override
  Future<void>? onLoad() {
    add(CircleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _playerVelocity.x = _hAxisInput * _moveSpeed;

    _playerVelocity.y += _gravity;
    _playerVelocity.y = _playerVelocity.y.clamp(-_jumpSpeed, 150);

    if (_jumpInput) {
      if (_isOnGround) {
        _playerVelocity.y = -_jumpSpeed;
        _isOnGround = false;
      }
      _jumpInput = false;
    }

    position += _playerVelocity * dt;

    if (_hAxisInput < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (_hAxisInput > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    position.clamp(_minClamp, _maxClamp);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;
    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.keyA) ? -1 : 0;
    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.keyD) ? 1 : 0;
    _jumpInput = keysPressed.contains(LogicalKeyboardKey.space) ? true : false;
    return true;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Platform) {
      if (intersectionPoints.length == 2) {
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - collisionNormal.length;

        collisionNormal.normalize();

        if (_up.dot(collisionNormal) > 0.9) {
          _isOnGround = true;
        }

        position += collisionNormal.scaled(separationDistance);
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  void hit() {
    add(
      OpacityEffect.fadeOut(
        EffectController(
          alternate: true,
          duration: 0.1,
          repeatCount: 5,
        ),
      )..onComplete = (){
        gameRef.playerData.invicible.value = false;
      }
    );
  }

  void jump() {
    _isOnGround = true;
    _jumpInput = true;
  }
}
