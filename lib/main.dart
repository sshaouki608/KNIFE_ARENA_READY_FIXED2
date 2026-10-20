import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game/knife_arena_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KnifeArenaApp());
}

class KnifeArenaApp extends StatelessWidget {
  const KnifeArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KNIFE ARENA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080D18),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF37E6D0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ArenaHome(),
    );
  }
}

class ArenaHome extends StatefulWidget {
  const ArenaHome({super.key});

  @override
  State<ArenaHome> createState() => _ArenaHomeState();
}

class _ArenaHomeState extends State<ArenaHome> {
  KnifeArenaGame? game;
  bool started = false;
  bool paused = false;
  String page = 'menu';
  int wins = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => wins = prefs.getInt('wins') ?? 0);
  }

  Future<void> _recordWin() async {
    final prefs = await SharedPreferences.getInstance();
    wins = (prefs.getInt('wins') ?? 0) + 1;
    await prefs.setInt('wins', wins);
    if (mounted) setState(() {});
  }

  void _startGame() {
    final newGame = KnifeArenaGame(
      onWin: _recordWin,
      onGameOver: () {
        if (mounted) setState(() => page = 'result');
      },
    );
    setState(() {
      game = newGame;
      started = true;
      paused = false;
      page = 'game';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (page == 'game' && game != null) {
      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: GameWidget(game: game!)),
              Positioned(
                top: 12, right: 12,
                child: _smallButton(
                  paused ? '▶' : 'Ⅱ',
                  () {
                    setState(() => paused = !paused);
                    game!.paused = paused;
                  },
                ),
              ),
              Positioned(
                left: 12, top: 12,
                child: ValueListenableBuilder<ArenaHud>(
                  valueListenable: game!.hud,
                  builder: (context, hud, _) => _hud(hud),
                ),
              ),
              Positioned(
                left: 16, bottom: 18,
                child: _Joystick(
                  onMove: (x, y) {
                    game!.moveX = x;
                    game!.moveY = y;
                  },
                ),
              ),
              Positioned(
                right: 18, bottom: 22,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionButton('رمي', const Color(0xFFFF5470), game!.throwKnife),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _actionButton('مراوغة', const Color(0xFF8A72FF), game!.dodge),
                        const SizedBox(width: 8),
                        _actionButton('قفز', const Color(0xFF3C9EFF), game!.jump),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _actionButton(
                      hudAbilityLabel(game!.hud.value.ability),
                      const Color(0xFF1DCDBA),
                      game!.activateAbility,
                    ),
                  ],
                ),
              ),
              if (paused)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.72),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('إيقاف مؤقت', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: () {
                            setState(() => paused = false);
                            game!.paused = false;
                          }, child: const Text('متابعة')),
                          TextButton(onPressed: () => setState(() { page = 'menu'; game = null; }), child: const Text('القائمة الرئيسية')),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (page == 'result') {
      final result = game?.resultText ?? 'انتهت الجولة';
      return _menuScaffold(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 72, color: Color(0xFFFFD166)),
            const SizedBox(height: 12),
            const Text('نتيجة الجولة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text(result, style: const TextStyle(fontSize: 20, color: Color(0xFF37E6D0))),
            const SizedBox(height: 8),
            Text('انتصاراتك المحفوظة: $wins', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 26),
            _primaryButton('إعادة المباراة', _startGame),
            const SizedBox(height: 10),
            _secondaryButton('القائمة الرئيسية', () => setState(() { page = 'menu'; game = null; })),
          ],
        ),
      );
    }

    return _menuScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flash_on_rounded, size: 54, color: Color(0xFF37E6D0)),
          const SizedBox(height: 8),
          const Text('KNIFE ARENA', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text('اقرأ حركة خصمك. صوب. ارمِ. انتصر.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 32),
          _primaryButton('بدء اللعب', _startGame),
          const SizedBox(height: 12),
          _secondaryButton('التدريب', _startGame),
          const SizedBox(height: 24),
          Text('أفضل تجربة: الوضع الأفقي • دون إنترنت', style: TextStyle(color: Colors.white.withValues(alpha: 0.55))),
        ],
      ),
    );
  }

  Widget _menuScaffold({required Widget child}) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF101D32), Color(0xFF080D18), Color(0xFF17152D)]),
      ),
      child: Center(child: Padding(padding: const EdgeInsets.all(28), child: child)),
    ),
  );

  Widget _primaryButton(String text, VoidCallback onTap) => SizedBox(
    width: 240, height: 52,
    child: FilledButton(onPressed: onTap, child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold))),
  );

  Widget _secondaryButton(String text, VoidCallback onTap) => SizedBox(
    width: 240, height: 48,
    child: OutlinedButton(onPressed: onTap, child: Text(text)),
  );

  Widget _smallButton(String text, VoidCallback onTap) => Material(
    color: const Color(0xDD101D32), borderRadius: BorderRadius.circular(14),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Text(text, style: const TextStyle(fontSize: 20)))),
  );

  Widget _actionButton(String text, Color color, VoidCallback onTap) => SizedBox(
    height: 46,
    child: FilledButton(
      style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 14)),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
    ),
  );

  Widget _hud(ArenaHud hud) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: const Color(0xCC080D18), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x5537E6D0))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('YOU  ${hud.playerHealth.round()}  ♥', style: const TextStyle(color: Color(0xFF37E6D0), fontWeight: FontWeight.bold)),
      Text('RIVAL  ${hud.enemyHealth.round()}  ♥', style: const TextStyle(color: Color(0xFFFF5470), fontWeight: FontWeight.bold)),
      Text('${hud.secondsLeft}s  •  ذخيرة ${hud.ammo}', style: const TextStyle(color: Colors.white)),
      Text('قدرة: ${hud.ability} ${hud.abilityReady ? '✓' : '…'}', style: const TextStyle(color: Color(0xFFFFD166), fontSize: 12)),
    ]),
  );

  String hudAbilityLabel(String ability) => ability.length > 12 ? 'قدرة خارقة' : ability;
}

class _Joystick extends StatefulWidget {
  final void Function(double x, double y) onMove;
  const _Joystick({required this.onMove});

  @override
  State<_Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<_Joystick> {
  Offset knob = Offset.zero;
  static const double radius = 48;

  void _update(Offset local) {
    final delta = local - const Offset(radius, radius);
    final limited = delta.distance > 30 ? delta / delta.distance * 30 : delta;
    setState(() => knob = limited);
    widget.onMove(limited.dx / 30, limited.dy / 30);
  }

  void _reset() {
    setState(() => knob = Offset.zero);
    widget.onMove(0, 0);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onPanStart: (d) => _update(d.localPosition),
    onPanUpdate: (d) => _update(d.localPosition),
    onPanEnd: (_) => _reset(),
    child: Container(
      width: radius * 2, height: radius * 2,
      decoration: BoxDecoration(color: const Color(0x7737E6D0), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF37E6D0), width: 2)),
      child: Transform.translate(offset: knob, child: Center(child: Container(
        width: 30, height: 30,
        decoration: const BoxDecoration(color: Color(0xFFDBFFF9), shape: BoxShape.circle),
      ))),
    ),
  );
}