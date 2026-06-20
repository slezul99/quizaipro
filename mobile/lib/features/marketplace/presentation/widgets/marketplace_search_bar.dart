import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class MarketplaceSearchBar extends StatelessWidget {
  const MarketplaceSearchBar({
    super.key,
    required this.tokens,
    required this.hintText,
    required this.onTap,
    this.readOnly = true,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.hasActiveFilter = false,
    this.autofocus = false,
  });

  final AuroraTokens tokens;
  final String hintText;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilter;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: readOnly ? onTap : null,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: tokens.backgroundSurface,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(color: tokens.borderDefault),
              ),
              child: readOnly
                  ? Row(
                      children: [
                        SizedBox(width: tokens.space16),
                        Icon(
                          Icons.search_rounded,
                          color: tokens.textTertiary,
                          size: 20,
                        ),
                        SizedBox(width: tokens.space12),
                        Text(
                          hintText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: tokens.textTertiary,
                              ),
                        ),
                      ],
                    )
                  : TextField(
                      controller: controller,
                      autofocus: autofocus,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: hintText,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: tokens.textTertiary,
                          size: 20,
                        ),
                        filled: false,
                      ),
                      textInputAction: TextInputAction.search,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                    ),
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          SizedBox(width: tokens.space8),
          _FilterButton(
            onTap: onFilterTap!,
            hasActive: hasActiveFilter,
            tokens: tokens,
          ),
        ],
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.onTap,
    required this.hasActive,
    required this.tokens,
  });

  final VoidCallback onTap;
  final bool hasActive;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasActive
                  ? tokens.brandGradientStart.withOpacity(0.12)
                  : tokens.backgroundSurface,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(
                color: hasActive
                    ? tokens.brandGradientStart
                    : tokens.borderDefault,
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: hasActive
                  ? tokens.brandGradientStart
                  : tokens.textSecondary,
              size: 22,
            ),
          ),
          if (hasActive)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: tokens.brandGradientStart,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
