import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class TutorShimmer extends StatefulWidget {
  const TutorShimmer({super.key});

  @override
  State<TutorShimmer> createState() => _TutorShimmerState();
}

class _TutorShimmerState extends State<TutorShimmer>
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
      builder: (context, _) => ListView.separated(
        padding: EdgeInsets.all(aurora.space20),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(height: aurora.space12),
        itemBuilder: (context, i) => _shimmerTile(context, i),
      ),
    );
  }

  Widget _shimmerTile(BuildContext context, int index) {
    final aurora = context.aurora;
    return Container(
      height: 72,
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

class ChatShimmer extends StatefulWidget {
  const ChatShimmer({super.key});

  @override
  State<ChatShimmer> createState() => _ChatShimmerState();
}

class _ChatShimmerState extends State<ChatShimmer>
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
      builder: (_, __) => Column(
        children: [
          ..._buildBubbles(context, aurora),
        ],
      ),
    );
  }

  List<Widget> _buildBubbles(BuildContext context, AuroraTokens aurora) {
    final sizes = [0.6, 0.8, 0.5, 0.7];
    final isRight = [true, false, true, false];
    return List.generate(sizes.length, (i) {
      final width = MediaQuery.sizeOf(context).width * sizes[i];
      return Align(
        alignment: isRight[i] ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: width,
          height: 44,
          margin: EdgeInsets.only(
            left: isRight[i] ? aurora.space48 : 0,
            right: isRight[i] ? 0 : aurora.space48,
            bottom: aurora.space8,
          ),
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
        ),
      );
    });
  }
}
