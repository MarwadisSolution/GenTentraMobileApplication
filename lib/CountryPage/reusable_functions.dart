// Country Profile Reusable Functions & UI Components
import 'dart:ui';
import 'package:flutter/material.dart';

/// Formats date string from yyyy-MM-dd to a human-readable string (e.g. 15 August 1947)
String formatCountryDate(String? rawDate) {
  if (rawDate == null || rawDate.trim().isEmpty) return '-';
  try {
    final parsed = DateTime.tryParse(rawDate.trim());
    if (parsed == null) return rawDate;
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  } catch (_) {
    return rawDate;
  }
}

/// Full-width prominent section divider matching the separator above the Info tab (#EBEBEB)
Widget buildSectionDivider(
  BuildContext context, {
  double? topMargin,
  double? bottomMargin,
}) {
  final double screenWidth = MediaQuery.of(context).size.width;
  final double screenHeight = MediaQuery.of(context).size.height;
  return Container(
    width: double.infinity,
    height: screenWidth * (6.0 / 375.0),
    margin: EdgeInsets.only(
      top: topMargin ?? screenHeight * 0.016,
      bottom: bottomMargin ?? screenHeight * 0.016,
    ),
    color: const Color(0xFFEBEBEB),
  );
}

/// Custom compact TabBar indicator decoration matching Party & Country reference
class SmallTabIndicator extends Decoration {
  final double width;
  final double height;
  final Color color;
  final BorderRadiusGeometry borderRadius;

  const SmallTabIndicator({
    required this.width,
    required this.height,
    this.color = Colors.red,
    this.borderRadius = const BorderRadius.all(Radius.circular(2)),
  });

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is SmallTabIndicator) {
      return SmallTabIndicator(
        width: lerpDouble(a.width, width, t) ?? width,
        height: lerpDouble(a.height, height, t) ?? height,
        color: Color.lerp(a.color, color, t) ?? color,
        borderRadius: BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t) ?? borderRadius,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is SmallTabIndicator) {
      return SmallTabIndicator(
        width: lerpDouble(width, b.width, t) ?? width,
        height: lerpDouble(height, b.height, t) ?? height,
        color: Color.lerp(color, b.color, t) ?? b.color,
        borderRadius: BorderRadiusGeometry.lerp(borderRadius, b.borderRadius, t) ?? b.borderRadius,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _SmallTabIndicatorPainter(this, onChanged);
  }
}

class _SmallTabIndicatorPainter extends BoxPainter {
  final SmallTabIndicator decoration;

  _SmallTabIndicatorPainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & (configuration.size ?? Size.zero);
    final double indicatorWidth = decoration.width;
    final double indicatorHeight = decoration.height;
    // Left-align indicator to start at left edge of tab text
    final double left = rect.left;
    final double top = rect.bottom - indicatorHeight;
    final Rect indicatorRect = Rect.fromLTWH(
      left,
      top,
      indicatorWidth,
      indicatorHeight,
    );
    final Paint paint = Paint()..color = decoration.color;
    canvas.drawRRect(
      decoration.borderRadius
          .resolve(configuration.textDirection)
          .toRRect(indicatorRect),
      paint,
    );
  }
}

/// Sliver TabBar Delegate
class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;
  final double dividerHeight;

  SliverTabBarDelegate(
    this.tabBar, {
    this.dividerHeight = 0.0,
  }) : backgroundColor = Colors.white;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height + dividerHeight;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.dividerHeight != dividerHeight;
  }
}
