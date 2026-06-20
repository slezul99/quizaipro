import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class LibraryShimmer extends StatefulWidget {
  const LibraryShimmer({
    super.key,
    required this.tokens,
    this.isGrid = true,
  });

  final AuroraTokens tokens;
  final bool isGrid;

  @override
  State<LibraryShimmer> createState() => _LibraryShimmerState();
}

class _LibraryShimmerState extends State<LibraryShimmer>
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
      child: widget.isGrid ? _GridShimmer(tokens: t) : _ListShimmer(tokens: t),
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer({required this.tokens});

  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(tokens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bone(height: 48, radius: tokens.radiusMd, tokens: tokens),
          SizedBox(height: tokens.space16),
          _Bone(width: 120, height: 20, radius: tokens.radiusSm, tokens: tokens),
          SizedBox(height: tokens.space12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => _Bone(
              height: double.infinity,
              radius: tokens.radiusLg,
              tokens: tokens,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListShimmer extends StatelessWidget {
  const _ListShimmer({required this.tokens});

  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(tokens.space20),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      separatorBuilder: (_, __) => SizedBox(height: tokens.space12),
      itemBuilder: (_, __) => _Bone(height: 72, radius: tokens.radiusLg, tokens: tokens),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
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
