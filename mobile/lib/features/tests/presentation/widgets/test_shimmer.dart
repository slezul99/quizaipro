import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class TestShimmer extends StatefulWidget {
  const TestShimmer({super.key});

  @override
  State<TestShimmer> createState() => _TestShimmerState();
}

class _TestShimmerState extends State<TestShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.all(aurora.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(context, height: 20, width: 120),
              SizedBox(height: aurora.space16),
              _shimmerBox(context, height: 120),
              SizedBox(height: aurora.space24),
              ...List.generate(
                4,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: aurora.space12),
                  child: _shimmerBox(context, height: 52),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(
    BuildContext context, {
    required double height,
    double? width,
  }) {
    final aurora = context.aurora;
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(aurora.radiusMd),
        gradient: LinearGradient(
          begin: Alignment(_animation.value - 1, 0),
          end: Alignment(_animation.value, 0),
          colors: [
            aurora.borderSubtle,
            aurora.backgroundSurfaceElevated,
            aurora.borderSubtle,
          ],
        ),
      ),
    );
  }
}
