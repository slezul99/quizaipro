import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class DashboardShimmer extends StatefulWidget {
  const DashboardShimmer({super.key, required this.tokens});

  final AuroraTokens tokens;

  @override
  State<DashboardShimmer> createState() => _DashboardShimmerState();
}

class _DashboardShimmerState extends State<DashboardShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.8).animate(
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
    final tokens = widget.tokens;
    return FadeTransition(
      opacity: _opacity,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting skeleton
            _SkeletonBox(width: 200, height: 28, tokens: tokens),
            SizedBox(height: tokens.space8),
            _SkeletonBox(width: 140, height: 18, tokens: tokens),
            SizedBox(height: tokens.space24),
            // XP card skeleton
            _SkeletonCard(height: 120, tokens: tokens),
            SizedBox(height: tokens.space16),
            // Streak + Daily row
            Row(children: [
              Expanded(child: _SkeletonCard(height: 100, tokens: tokens)),
              SizedBox(width: tokens.space12),
              Expanded(child: _SkeletonCard(height: 100, tokens: tokens)),
            ]),
            SizedBox(height: tokens.space16),
            // Due reviews skeleton
            _SkeletonCard(height: 140, tokens: tokens),
            SizedBox(height: tokens.space16),
            // Quick actions skeleton
            Row(children: [
              Expanded(child: _SkeletonCard(height: 80, tokens: tokens)),
              SizedBox(width: tokens.space12),
              Expanded(child: _SkeletonCard(height: 80, tokens: tokens)),
              SizedBox(width: tokens.space12),
              Expanded(child: _SkeletonCard(height: 80, tokens: tokens)),
            ]),
            SizedBox(height: tokens.space24),
            // Activity header
            _SkeletonBox(width: 160, height: 22, tokens: tokens),
            SizedBox(height: tokens.space16),
            // Shimmering timeline items matching final layout
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                final isFirst = index == 0;
                final isLast = index == 2;
                return Stack(
                  children: [
                    // Timeline vertical line shimmer
                    if (!(isFirst && isLast))
                      Positioned(
                        top: isFirst ? 28 : 0,
                        bottom: isLast ? null : 0,
                        height: isLast ? 28 : null,
                        left: 20,
                        child: Container(
                          width: 2,
                          color: tokens.surfaceSubtle,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(bottom: tokens.space16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Timeline Node Dot Shimmer
                          SizedBox(
                            width: 42,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: tokens.surfaceSubtle,
                                  border: Border.all(
                                    color: tokens.surfaceSubtle,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: tokens.space12),
                          // Right Shimmer Card
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(tokens.space16),
                              decoration: BoxDecoration(
                                color: tokens.surfaceSubtle.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(tokens.radiusL),
                                border: Border.all(
                                  color: tokens.borderDefault.withOpacity(0.3),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Title shimmer
                                      Container(
                                        width: 120,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: tokens.surfaceSubtle,
                                          borderRadius: BorderRadius.circular(tokens.radiusXs),
                                        ),
                                      ),
                                      // XP Badge shimmer
                                      Container(
                                        width: 50,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: tokens.surfaceSubtle,
                                          borderRadius: BorderRadius.circular(tokens.radiusXs),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: tokens.space8),
                                  // Subtitle shimmer
                                  Container(
                                    width: 180,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: tokens.surfaceSubtle,
                                      borderRadius: BorderRadius.circular(tokens.radiusXs),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.tokens,
    this.borderRadius,
  });

  final double width;
  final double height;
  final AuroraTokens tokens;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tokens.surfaceSubtle,
        borderRadius: BorderRadius.circular(borderRadius ?? tokens.radiusS),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height, required this.tokens});

  final double height;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: tokens.surfaceSubtle,
        borderRadius: BorderRadius.circular(tokens.radiusL),
      ),
    );
  }
}
