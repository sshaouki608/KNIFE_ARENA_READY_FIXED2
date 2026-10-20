import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../components/fighter.dart';
import '../components/knife_projectile.dart';

class ArenaAI {
  double thinkTimer = 0;
  double throwTimer = 0;
  double strafeSign = 1;

  void update(Fighter enemy, Fighter player, List<KnifeProjectile> knives, double dt,
      Rect bounds, void Function(Vector2 direction) throwKnife) {
    thinkTimer -= dt;
    throwTimer -= dt;
    if (thinkTimer <= 0) {
      thinkTimer = .22;
      if (math.Random().nextDouble() < .35) strafeSign *= -1;
    }
    final toPlayer = player.position - enemy.position;
    final distance = toPlayer.length;
    Vector2 move = Vector2.zero();
    if (distance > 205) {
      move = toPlayer.normalized();
    } else if (distance < 125) {
      move = -toPlayer.normalized();
    } else {
      move = Vector2(-toPlayer.y, toPlayer.x).normalized() * strafeSign;
    }

    // React to nearby projectiles: sidestep when a knife is approaching.
    for (final knife in knives) {
      if (knife.isPlayerKnife && (knife.position - enemy.position).length < 95) {
        move += Vector2(-(knife.position.y - enemy.position.y), knife.position.x - enemy.position.x).normalized() * 1.3;
      }
    }
    if (move.length > 1) move = move.normalized();
    enemy.move(move, dt, bounds);

    if (enemy.ammo <= 0) {
      enemy.ammo = 6; // AI reloads automatically when its magazine is empty.
    }
    if (throwTimer <= 0 && distance < 440 && enemy.ammo > 0) {
      throwTimer = 1.15 + math.Random().nextDouble() * .65;
      // Small inaccuracy keeps hits dependent on actual projectile collisions.
      final spread = (math.Random().nextDouble() - .5) * .20;
      final c = math.cos(spread), s = math.sin(spread);
      final aim = Vector2(toPlayer.x * c - toPlayer.y * s, toPlayer.x * s + toPlayer.y * c);
      throwKnife(aim);
    }
  }
}
