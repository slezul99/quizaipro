class LevelJourney {
  final int level;
  final int totalXp;
  final int xpInCurrentLevel;
  final int xpForNextLevel;
  final double progressRatio;
  final LevelJourneyTier tier;
  final List<LevelJourneyMilestone> milestones;
  final List<LevelJourneyXpEvent> recentXpEvents;

  const LevelJourney({
    required this.level,
    required this.totalXp,
    required this.xpInCurrentLevel,
    required this.xpForNextLevel,
    required this.progressRatio,
    required this.tier,
    required this.milestones,
    required this.recentXpEvents,
  });

  factory LevelJourney.fromJson(Map<String, dynamic> json) {
    return LevelJourney(
      level: json['level'] as int? ?? 1,
      totalXp: json['total_xp'] as int? ?? 0,
      xpInCurrentLevel: json['xp_in_current_level'] as int? ?? 0,
      xpForNextLevel: json['xp_for_next_level'] as int? ?? 100,
      progressRatio: (json['progress_ratio'] as num?)?.toDouble() ?? 0.0,
      tier: LevelJourneyTier.fromJson(json['tier'] as Map<String, dynamic>? ?? {}),
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((e) => LevelJourneyMilestone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentXpEvents: (json['recent_xp_events'] as List<dynamic>?)
              ?.map((e) => LevelJourneyXpEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LevelJourneyTier {
  final String key;
  final String name;
  final int minLevel;
  final int maxLevel;

  const LevelJourneyTier({
    required this.key,
    required this.name,
    required this.minLevel,
    required this.maxLevel,
  });

  factory LevelJourneyTier.fromJson(Map<String, dynamic> json) {
    return LevelJourneyTier(
      key: json['key'] as String? ?? 'novice',
      name: json['name'] as String? ?? 'Novice',
      minLevel: json['min_level'] as int? ?? 1,
      maxLevel: json['max_level'] as int? ?? 5,
    );
  }
}

class LevelJourneyMilestone {
  final int level;
  final String rewardDesc;
  final bool unlocked;

  const LevelJourneyMilestone({
    required this.level,
    required this.rewardDesc,
    required this.unlocked,
  });

  factory LevelJourneyMilestone.fromJson(Map<String, dynamic> json) {
    return LevelJourneyMilestone(
      level: json['level'] as int? ?? 0,
      rewardDesc: json['reward_desc'] as String? ?? '',
      unlocked: json['unlocked'] as bool? ?? false,
    );
  }
}

class LevelJourneyXpEvent {
  final String eventType;
  final String description;
  final int xpGained;
  final String timestamp;

  const LevelJourneyXpEvent({
    required this.eventType,
    required this.description,
    required this.xpGained,
    required this.timestamp,
  });

  factory LevelJourneyXpEvent.fromJson(Map<String, dynamic> json) {
    return LevelJourneyXpEvent(
      eventType: json['event_type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      xpGained: json['xp_gained'] as int? ?? 0,
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}
