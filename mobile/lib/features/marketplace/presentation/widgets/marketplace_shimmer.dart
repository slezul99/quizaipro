import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class MarketplaceShimmer extends StatefulWidget {
  const MarketplaceShimmer({super.key, required this.tokens});

  final AuroraTokens tokens;

  @override
  State<MarketplaceShimmer> createState() => _MarketplaceShimmerState();
}

class _MarketplaceShimmerState extends State<MarketplaceShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    return FadeTransition(
      opacity: _opacity,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(t.space20),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar skeleton
            _Skeleton(height: 48, radius: t.radiusMd, tokens: t),
            SizedBox(height: t.space16),
            // Subject chips
            Row(children: [
              _Skeleton(width: 90, height: 36, radius: t.radiusFull, tokens: t),
              SizedBox(width: t.space8),
              _Skeleton(width: 80, height: 36, radius: t.radiusFull, tokens: t),
              SizedBox(width: t.space8),
              _Skeleton(width: 100, height: 36, radius: t.radiusFull, tokens: t),
            ]),
            SizedBox(height: t.space24),
            // Deck grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => _Skeleton(
                height: double.infinity,
                radius: t.radiusLg,
                tokens: t,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectionsShimmer extends StatefulWidget {
  const CollectionsShimmer({super.key, required this.tokens});

  final AuroraTokens tokens;

  @override
  State<CollectionsShimmer> createState() => _CollectionsShimmerState();
}

class _CollectionsShimmerState extends State<CollectionsShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    return FadeTransition(
      opacity: _opacity,
      child: ListView.separated(
        padding: EdgeInsets.all(t.space20),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        separatorBuilder: (_, __) => SizedBox(height: t.space12),
        itemBuilder: (_, __) => _Skeleton(height: 88, radius: t.radiusLg, tokens: t),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({
    required this.height,
    required this.radius,
    required this.tokens,
    this.width,
  });

  final double height;
  final double radius;
  final AuroraTokens tokens;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tokens.backgroundSurfaceElevated,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
