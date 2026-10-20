import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'components/fighter.dart';
import 'components/knife_projectile.dart';
import 'systems/ability_system.dart';
import 'systems/arena_ai.dart';

class ArenaHud {
  final double playerHealth;
  final double enemyHealth;
  final int secondsLeft;
  final int ammo;
  final String ability;
  final bool abilityReady;
  const ArenaHud({required this.playerHealth, required this.enemyHealth, required this.secondsLeft, required this.ammo, required this.ability, required this.abilityReady});
}

class KnifeArenaGame extends FlameGame {
  KnifeArenaGame({required this.onWin, required this.onGameOver});
  final Future<void> Function() onWin;
  final VoidCallback onGameOver;
  final ValueNotifier<ArenaHud> hud = ValueNotifier(const ArenaHud(playerHealth: 100, enemyHealth: 100, secondsLeft: 90, ammo: 6, ability: 'النصل الخاطف', abilityReady: false));

  late Fighter player;
  late Fighter enemy;
  final List<KnifeProjectile> knives = [];
  final AbilitySystem abilities = AbilitySystem();
  final ArenaAI ai = ArenaAI();
  double moveX = 0, moveY = 0;
  double elapsed = 0;
  double roundTime = 90;
  double abilityClock = 0;
  double hudClock = 0;
  int ammo = 6;
  bool ended = false;
  bool playerWon = false;
  bool _winRecorded = false;
  String resultText = 'انتهت الجولة';

  @override
  Color backgroundColor() => const Color(0xFF0A1020);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final size = canvasSize;
    add(RectangleComponent(
      position: Vector2.zero(), size: size,
      paint: Paint()..color = const Color(0xFF101D32),
    ));
    // Arena lanes and luminous perimeter.
    add(RectangleComponent(position: Vector2(size.x * .08, size.y * .10), size: Vector2(size.x * .84, size.y * .80),
      paint: Paint()..color = const Color(0xFF142640)));
    add(RectangleComponent(position: Vector2(size.x * .08, size.y * .10), size: Vector2(size.x * .84, 3),
      paint: Paint()..color = const Color(0xFF37E6D0)));
    add(RectangleComponent(position: Vector2(size.x * .08, size.y * .90), size: Vector2(size.x * .84, 3),
      paint: Paint()..color = const Color(0xFF37E6D0)));
    player = Fighter(isPlayer: true, position: Vector2(size.x * .25, size.y * .53));
    enemy = Fighter(isPlayer: false, position: Vector2(size.x * .75, size.y * .47));
    add(player);
    add(enemy);
    _publishHud();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (paused || ended || !isLoaded) return;
    elapsed += dt;
    roundTime -= dt;
    abilityClock += dt;
    hudClock += dt;
    if (abilityClock >= 10) {
      abilityClock %= 10;
      abilities.grantNext();
    }
    player.move(Vector2(moveX, moveY), dt, bounds);
    ai.update(enemy, player, knives, dt, bounds, (direction) => _throwFrom(enemy, direction, isPlayer: false));
    for (final knife in knives.toList()) {
      knife.advance(dt);
      if (knife.life <= 0 || _outside(knife.position)) {
        knives.remove(knife);
        knife.removeFromParent();
        continue;
      }
      final target = knife.isPlayerKnife ? enemy : player;
      if (!target.invulnerable && (knife.position - target.position).length < target.radius + 7) {
        if (target.shieldCharges > 0) {
          target.shieldCharges--;
        } else {
          target.health = math.max(0, target.health - knife.damage).toDouble();
        }
        knives.remove(knife);
        knife.removeFromParent();
        if (target.health <= 0) _finish(knife.isPlayerKnife);
      }
    }
    if (roundTime <= 0) {
      if (player.health == enemy.health) _finish(null);
      else _finish(player.health > enemy.health);
    }
    if (hudClock >= .12) {
      hudClock = 0;
      _publishHud();
    }
  }

  Rect get bounds => Rect.fromLTWH(size.x * .08, size.y * .10, size.x * .84, size.y * .80);

  bool _outside(Vector2 p) => !bounds.contains(Offset(p.x, p.y));

  void _throwFrom(Fighter source, Vector2 direction, {required bool isPlayer}) {
    if (ended || source.ammo <= 0 || direction.length < .1) return;
    source.ammo--;
    final knife = KnifeProjectile(
      position: source.position.clone() + direction.normalized() * (source.radius + 8),
      velocity: direction.normalized() * (source.boostedKnife ? 480 : 350),
      isPlayerKnife: isPlayer,
    );
    source.boostedKnife = false;
    knives.add(knife);
    add(knife);
  }

  void throwKnife() {
    if (ended) return;
    if (ammo <= 0 || player.ammo <= 0) {
      // Optional auto-reload: reload consumes the tap; the next tap throws.
      ammo = 6;
      player.ammo = 6;
      _publishHud();
      return;
    }
    final direction = enemy.position - player.position;
    _throwFrom(player, direction, isPlayer: true);
    ammo = player.ammo;
    _publishHud();
  }

  void dodge() {
    if (ended) return;
    final dir = Vector2(moveX, moveY);
    if (dir.length < .2) {
      final toward = player.position - enemy.position;
      dir.setFrom(Vector2(-toward.y, toward.x));
    }
    player.position.add(dir.normalized() * 72);
    _clamp(player);
    player.invulnerable = true;
    player.invulnerabilityTimer = .32;
  }

  void jump() {
    if (ended) return;
    player.jumpTimer = .35;
    player.position.y -= 16;
    _clamp(player);
  }

  void activateAbility() {
    if (!abilities.ready || ended) return;
    final ability = abilities.consume();
    switch (ability) {
      case ArenaAbility.swiftBlade:
        player.boostedKnife = true;
        break;
      case ArenaAbility.energyShield:
        player.shieldCharges = 1;
        break;
      case ArenaAbility.blink:
        final dir = Vector2(moveX, moveY);
        if (dir.length < .2) dir.setFrom(enemy.position - player.position);
        player.position.add(dir.normalized() * 100);
        _clamp(player);
        break;
      case ArenaAbility.tripleKnives:
        final dir = enemy.position - player.position;
        for (final angle in [-.16, 0.0, .16]) {
          final rotated = Vector2(
            dir.x * math.cos(angle) - dir.y * math.sin(angle),
            dir.x * math.sin(angle) + dir.y * math.cos(angle),
          );
          _throwFrom(player, rotated, isPlayer: true);
        }
        ammo = player.ammo;
        break;
      case ArenaAbility.hunterEye:
        // Short tracking highlight; intentionally informational, not auto-aim.
        enemy.markedTimer = 3;
        break;
      case ArenaAbility.lightningSpeed:
        player.speedBoostTimer = 3;
        break;
    }
    _publishHud();
  }

  void _clamp(Fighter fighter) {
    fighter.position.x = fighter.position.x.clamp(bounds.left + fighter.radius, bounds.right - fighter.radius).toDouble();
    fighter.position.y = fighter.position.y.clamp(bounds.top + fighter.radius, bounds.bottom - fighter.radius).toDouble();
  }

  Future<void> _finish(bool? playerWins) async {
    if (ended) return;
    ended = true;
    playerWon = playerWins == true;
    resultText = playerWins == null ? 'تعادل!' : (playerWins ? 'فزت بالمباراة!' : 'خسرت الجولة');
    if (playerWon && !_winRecorded) {
      _winRecorded = true;
      await onWin();
    }
    _publishHud();
    onGameOver();
  }

  void _publishHud() {
    hud.value = ArenaHud(
      playerHealth: player.health,
      enemyHealth: enemy.health,
      secondsLeft: math.max(0, roundTime.ceil()),
      ammo: ammo,
      ability: abilities.current.label,
      abilityReady: abilities.ready,
    );
  }
}
