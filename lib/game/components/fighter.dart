import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Fighter extends CircleComponent {
  Fighter({required this.isPlayer, required Vector2 position})
      : super(position: position, radius: 17, anchor: Anchor.center,
          paint: Paint()..color = isPlayer ? const Color(0xFF37E6D0) : const Color(0xFFFF5470));

  final bool isPlayer;
  double health = 100;
  double speed = 175;
  int ammo = 6;
  int shieldCharges = 0;
  bool invulnerable = false;
  double invulnerabilityTimer = 0;
  double jumpTimer = 0;
  double markedTimer = 0;
  double speedBoostTimer = 0;
  bool boostedKnife = false;

  void move(Vector2 direction, double dt, Rect bounds) {
    if (invulnerabilityTimer > 0) {
      invulnerabilityTimer -= dt;
      if (invulnerabilityTimer <= 0) invulnerable = false;
    }
    if (jumpTimer > 0) jumpTimer -= dt;
    if (markedTimer > 0) markedTimer -= dt;
    if (speedBoostTimer > 0) speedBoostTimer -= dt;
    final multiplier = speedBoostTimer > 0 ? 1.65 : 1.0;
    if (direction.length > 1) direction = direction.normalized();
    position += direction * speed * multiplier * dt;
    position.x = position.x.clamp(bounds.left + radius, bounds.right - radius).toDouble();
    position.y = position.y.clamp(bounds.top + radius, bounds.bottom - radius).toDouble();
  }

  @override
  void render(Canvas canvas) {
    final glow = Paint()..color = paint.color.withValues(alpha: .18);
    canvas.drawCircle(Offset.zero, radius + 8, glow);
    super.render(canvas);
    final visor = Paint()..color = const Color(0xFF07101C);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: radius * 1.15, height: radius * .48), visor);
    if (shieldCharges > 0) {
      canvas.drawCircle(Offset.zero, radius + 5, Paint()..color = const Color(0xFF78B7FF)..style = PaintingStyle.stroke..strokeWidth = 3);
    }
    if (markedTimer > 0) {
      canvas.drawCircle(Offset.zero, radius + 11, Paint()..color = const Color(0xFFFFD166)..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    if (invulnerable) {
      canvas.drawCircle(Offset.zero, radius + 3, Paint()..color = Colors.white.withValues(alpha: .75)..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }
}
