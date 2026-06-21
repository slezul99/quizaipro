// Guards the streak-journey fix: the server sends snake_case keys, and
// StreakJourney.fromJson must parse them (a missing snake mapping made the
// screen throw "Failed to load progression journey").

import 'package:flutter_test/flutter_test.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/streak_journey.dart';

void main() {
  test('StreakJourney.fromJson parses the snake_case server payload', () {
    final json = <String, dynamic>{
      'calendar': {
        'active_dates': ['2026-06-21', '2026-06-16'],
        'end_date': '2026-06-21',
        'start_date': '2026-05-23',
      },
      'milestones': [
        {
          'days': 3,
          'desc': '3 дня подряд',
          'key': 'streak_3',
          'name': 'На разогреве',
          'unlocked': false,
          'unlocked_at': null,
          'xp': 30,
        },
      ],
      'rewards_history': <dynamic>[],
      'streak': {
        'current_stage': {'key': 'seed', 'next_stage_days': 3, 'start_days': 0},
        'current_streak': 1,
        'days_remaining': 2,
        'last_activity_date': '2026-06-21',
        'max_streak': 1,
        'next_stage': {'key': 'sprout', 'start_days': 3},
        'progress_ratio': 0.333,
        'today_completed': true,
      },
    };

    final j = StreakJourney.fromJson(json);
    expect(j.streak.currentStreak, 1);
    expect(j.streak.currentStage?.key, 'seed');
    expect(j.streak.nextStage?.startDays, 3);
    expect(j.milestones.single.days, 3);
    expect(j.calendar.activeDates.length, 2);
  });

  test('handles a maxed streak (next_stage null) and empty rewards', () {
    final json = <String, dynamic>{
      'calendar': {'active_dates': <dynamic>[], 'end_date': '', 'start_date': ''},
      'milestones': <dynamic>[],
      'rewards_history': <dynamic>[],
      'streak': {
        'current_stage': {'key': 'legend', 'next_stage_days': null, 'start_days': 365},
        'current_streak': 400,
        'days_remaining': 0,
        'last_activity_date': null,
        'max_streak': 400,
        'next_stage': null,
        'progress_ratio': 1.0,
        'today_completed': false,
      },
    };

    final j = StreakJourney.fromJson(json);
    expect(j.streak.nextStage, isNull);
    expect(j.streak.lastActivityDate, isNull);
  });
}
