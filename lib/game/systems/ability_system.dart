enum ArenaAbility { swiftBlade, energyShield, blink, tripleKnives, hunterEye, lightningSpeed }

extension ArenaAbilityLabel on ArenaAbility {
  String get label => switch (this) {
    ArenaAbility.swiftBlade => 'النصل الخاطف',
    ArenaAbility.energyShield => 'الدرع الطاقي',
    ArenaAbility.blink => 'الانتقال الخاطف',
    ArenaAbility.tripleKnives => 'النصال الثلاثة',
    ArenaAbility.hunterEye => 'عين الصياد',
    ArenaAbility.lightningSpeed => 'سرعة البرق',
  };
}

class AbilitySystem {
  int _index = 0;
  bool ready = false;
  ArenaAbility get current => ArenaAbility.values[_index];

  void grantNext() {
    ready = true;
  }

  ArenaAbility consume() {
    final chosen = current;
    ready = false;
    _index = (_index + 1) % ArenaAbility.values.length;
    return chosen;
  }
}
