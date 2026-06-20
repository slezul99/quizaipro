import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_session_notifier.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_setup_notifier.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class TestSetupScreen extends ConsumerWidget {
  const TestSetupScreen({
    super.key,
    required this.deckId,
    required this.deckTitle,
  });

  final String deckId;
  final String deckTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      testSetupNotifierProvider(deckId: deckId, deckTitle: deckTitle),
    );
    final notifier = ref.read(
      testSetupNotifierProvider(deckId: deckId, deckTitle: deckTitle).notifier,
    );

    final aurora = context.aurora;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: aurora.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: aurora.backgroundCanvas,
        elevation: 0,
        title: Text(
          l10n.testsSetupTitle,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: aurora.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: aurora.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(aurora.space20),
        children: [
          Text(
            deckTitle,
            style: theme.textTheme.headlineSmall
                ?.copyWith(color: aurora.textPrimary),
          ),
          SizedBox(height: aurora.space8),
          Text(
            l10n.testsSetupSubtitle,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: aurora.textSecondary),
          ),
          SizedBox(height: aurora.space32),
          _SectionLabel(label: l10n.testsQuestionCount),
          SizedBox(height: aurora.space12),
          _QuestionCountSelector(
            selected: state.questionCount,
            onChanged: notifier.setQuestionCount,
          ),
          SizedBox(height: aurora.space24),
          _SettingTile(
            icon: Icons.shuffle_rounded,
            label: l10n.testsShuffle,
            value: state.shuffle,
            onChanged: (v) => notifier.setShuffle(value: v),
          ),
          SizedBox(height: aurora.space12),
          _SettingTile(
            icon: Icons.timer_outlined,
            label: l10n.testsTimedMode,
            value: state.timedMode,
            onChanged: (v) => notifier.setTimedMode(value: v),
          ),
          if (state.timedMode) ...[
            SizedBox(height: aurora.space16),
            _SectionLabel(label: l10n.testsSecondsPerQuestion),
            SizedBox(height: aurora.space12),
            _SecondsSelector(
              selected: state.secondsPerQuestion,
              onChanged: notifier.setSecondsPerQuestion,
            ),
          ],
          SizedBox(height: aurora.space40),
          _StartButton(
            isLoading: state.isStarting,
            onTap: () => _startTest(context, ref, state.deckId, state.deckTitle, notifier),
          ),
        ],
      ),
    );
  }

  Future<void> _startTest(
    BuildContext context,
    WidgetRef ref,
    String deckId,
    String deckTitle,
    TestSetupNotifier notifier,
  ) async {
    final state = ref.read(
      testSetupNotifierProvider(deckId: deckId, deckTitle: deckTitle),
    );
    final l10n = AppLocalizations.of(context)!;
    notifier.setStarting(value: true);
    await ref.read(testSessionNotifierProvider.notifier).startTest(
          deckId: deckId,
          deckTitle: deckTitle,
          config: state.config,
          emptyMessage: l10n.testsNoQuestions,
        );
    notifier.setStarting(value: false);
    if (context.mounted) {
      context.pushNamed(AppRoutes.testSessionName);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: aurora.textSecondary,
          ),
    );
  }
}

class _QuestionCountSelector extends StatelessWidget {
  const _QuestionCountSelector({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  static const _options = [5, 10, 15, 20, 0];

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: aurora.space8,
      children: _options.map((count) {
        final label = count == 0 ? l10n.testsCountAll : '$count';
        final isSelected = selected == count;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onChanged(count),
          selectedColor: aurora.brandGradientStart,
          backgroundColor: aurora.backgroundSurface,
          labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : aurora.textPrimary,
              ),
          side: BorderSide(
            color: isSelected ? aurora.brandGradientStart : aurora.borderDefault,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(aurora.radiusSm),
          ),
        );
      }).toList(),
    );
  }
}

class _SecondsSelector extends StatelessWidget {
  const _SecondsSelector({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  static const _options = [15, 20, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: aurora.space8,
      children: _options.map((s) {
        final isSelected = selected == s;
        return ChoiceChip(
          label: Text(l10n.testsSecondsShort(s)),
          selected: isSelected,
          onSelected: (_) => onChanged(s),
          selectedColor: aurora.brandGradientStart,
          backgroundColor: aurora.backgroundSurface,
          labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : aurora.textPrimary,
              ),
          side: BorderSide(
            color: isSelected ? aurora.brandGradientStart : aurora.borderDefault,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(aurora.radiusSm),
          ),
        );
      }).toList(),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: aurora.space16,
        vertical: aurora.space12,
      ),
      decoration: BoxDecoration(
        color: aurora.backgroundSurface,
        borderRadius: BorderRadius.circular(aurora.radiusMd),
        border: Border.all(color: aurora.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: aurora.textSecondary, size: 20),
          SizedBox(width: aurora.space12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: aurora.textPrimary),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: aurora.brandGradientStart,
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [aurora.brandGradientStart, aurora.brandGradientEnd],
          ),
          borderRadius: BorderRadius.circular(aurora.radiusMd),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                AppLocalizations.of(context)!.testsStart,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
      ),
    );
  }
}
