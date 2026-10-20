import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class KnifeProjectile extends PositionComponent {
  KnifeProjectile({required Vector2 position, required this.velocity, required this.isPlayerKnife})
      : super(position: position, size: Vector2(18, 5), anchor: Anchor.center) {
    angle = velocity.screenAngle();
  }

  final Vector2 velocity;
  final bool isPlayerKnife;
  double life = 2.2;
  final double damage = 18;

  void advance(double dt) {
    position += velocity * dt;
    life -= dt;
    angle = velocity.screenAngle();
  }

  @override
  void render(Canvas canvas) {
    final color = isPlayerKnife ? const Color(0xFFBDFBF2) : const Color(0xFFFFB6C2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 18, height: 4), const Radius.circular(2)),
      Paint()..color = color,
    );
    canvas.drawPath(
      Path()..moveTo(7, -3)..lineTo(12, 0)..lineTo(7, 3)..close(),
      Paint()..color = Colors.white,
    );
  }
}
