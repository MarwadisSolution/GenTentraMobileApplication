
import 'package:flutter/material.dart';

import '../Reusable Functions/reusable_functions.dart';
import 'Country_model.dart';

/// PLACES TO VISIT TAB PAGE
/// Displays tourist attractions, landmarks,
/// and places to visit for the country.
class CountryPlacesToVisitPage extends StatelessWidget {
  final CountryModel country;
  final bool isActive;

  const CountryPlacesToVisitPage({
    super.key,
    required this.country,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    final List<PlaceView> places =
        country.placesToVisit?.places ?? [];

    final String introText =
        (country.placesToVisit?.description?.trim().isNotEmpty ==
                true)
            ? country.placesToVisit!.description!.trim()
            : 'Here are a few iconic places you simply must experience.';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.045,
        vertical: h * 0.022,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intro text
          Text(
            introText,
            style: TextStyle(
              fontSize: (w * (15.0 / 375.0)).clamp(14.0, 16.0),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E1E1E),
              height: 1.5,
            ),
          ),

          SizedBox(height: h * 0.022),

          // Empty state
          if (places.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: h * 0.04,
              ),
              child: Center(
                child: Text(
                  'No places to visit available.',
                  style: TextStyle(
                    fontSize: (w * (14.0 / 375.0)).clamp(13.0, 15.0),
                    color: const Color(0xFF888888),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...places.map(
              (place) => _buildPlaceListCard(
                context,
                place,
                w,
                h,
              ),
            ),

          SizedBox(height: h * 0.02),
        ],
      ),
    );
  }

  /// Builds an individual destination card
  /// with vertical scrolling parallax.
  Widget _buildPlaceListCard(
    BuildContext context,
    PlaceView place,
    double w,
    double h,
  ) {
    // Image height remains at the increased size.
    final double imageHeight = h * 0.27;
    final double borderRadius = w * 0.04;

    // Resolve full image URL.
    final String rawUrl = place.imageUrl?.trim() ?? '';

    final String imageUrl = rawUrl.isEmpty
        ? ''
        : (rawUrl.startsWith('http://') ||
                rawUrl.startsWith('https://'))
            ? rawUrl
            : (rawUrl.startsWith('/')
                ? '$api$rawUrl'
                : '$api/$rawUrl');

    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.024),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination image.
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: SizedBox(
              width: double.infinity,
              height: imageHeight,
              child: imageUrl.isEmpty
                  ? _buildImagePlaceholder(w)
                  : Builder(
                      builder: (imageContext) {
                        final scrollable =
                            Scrollable.maybeOf(imageContext);

                        // Fallback if no Scrollable is available.
                        if (scrollable == null) {
                          return buildImageWidget(
                            imageUrl,
                            fit: BoxFit.cover,
                          );
                        }

                        // Vertical scrolling parallax.
                        return Flow(
                          delegate: _ParallaxFlowDelegate(
                            scrollable: scrollable,
                            listItemContext: imageContext,
                          ),
                          children: [
                            buildImageWidget(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),

          SizedBox(height: h * 0.014),

          // Place name.
          Text(
            (place.name.trim().isNotEmpty
                    ? place.name.trim()
                    : 'DESTINATION')
                .toUpperCase(),
            style: TextStyle(
              fontSize: (w * (16.0 / 375.0)).clamp(15.0, 18.0),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1E1E),
              letterSpacing: 0.3,
            ),
          ),

          // Description.
          if (place.description?.trim().isNotEmpty == true) ...[
            SizedBox(height: h * 0.006),
            Text(
              place.description!.trim(),
              style: TextStyle(
                fontSize: (w * (15.0 / 375.0)).clamp(14.0, 16.0),
                fontWeight: FontWeight.w400,
                color: const Color(0xFF555555),
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Placeholder for missing destination images.
  Widget _buildImagePlaceholder(double w) {
    return Container(
      color: const Color(0xFFF0F0F0),
      child: Center(
        child: Icon(
          Icons.landscape_rounded,
          size: w * 0.12,
          color: const Color(0xFFBDBDBD),
        ),
      ),
    );
  }
}

/// PARALLAX FLOW DELEGATE
///
/// Preserves the vertical scrolling parallax effect.
/// Images move vertically as the user scrolls the page.
class _ParallaxFlowDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext listItemContext;

  // Controls vertical parallax intensity.
  static const double _imageHeightMultiplier = 1.6;

  _ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
  }) : super(
          repaint: scrollable.position,
        );

  @override
  BoxConstraints getConstraintsForChild(
    int i,
    BoxConstraints constraints,
  ) {
    return BoxConstraints.tight(
      Size(
        constraints.maxWidth,
        constraints.maxHeight * _imageHeightMultiplier,
      ),
    );
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(
      constraints.maxWidth,
      constraints.maxHeight,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    if (context.childCount == 0) return;

    // Get render objects safely.
    final RenderObject? scrollableRO =
        scrollable.context.findRenderObject();

    final RenderObject? listItemRO =
        listItemContext.findRenderObject();

    if (scrollableRO is! RenderBox ||
        listItemRO is! RenderBox ||
        !scrollableRO.attached ||
        !listItemRO.attached ||
        !scrollableRO.hasSize ||
        !listItemRO.hasSize) {
      context.paintChild(0);
      return;
    }

    try {
      // Get image card position relative to viewport.
      final Offset itemOffset = listItemRO.localToGlobal(
        Offset.zero,
        ancestor: scrollableRO,
      );

      final double viewportHeight =
          scrollable.position.hasViewportDimension
              ? scrollable.position.viewportDimension
              : scrollableRO.size.height;

      if (viewportHeight <= 0) {
        context.paintChild(0);
        return;
      }

      // Calculate card position within viewport.
      final double scrollFraction =
          (itemOffset.dy / viewportHeight).clamp(0.0, 1.0);

      // Calculate vertical image alignment.
      final Alignment alignment = Alignment(
        0.0,
        scrollFraction * 2.0 - 1.0,
      );

      final Size? childSize = context.getChildSize(0);

      if (childSize == null) {
        context.paintChild(0);
        return;
      }

      // Calculate independent vertical movement.
      final Offset childOffset = alignment.alongSize(
        Size(
          context.size.width - childSize.width,
          context.size.height - childSize.height,
        ),
      );

      // Apply vertical parallax transformation.
      context.paintChild(
        0,
        transform: Matrix4.translationValues(
          childOffset.dx,
          childOffset.dy,
          0.0,
        ),
      );
    } catch (e) {
      // Fallback to normal image rendering.
      context.paintChild(0);
    }
  }

  @override
  bool shouldRepaint(
    covariant _ParallaxFlowDelegate oldDelegate,
  ) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext;
  }
}

// Aliases for compatibility.
typedef CountryPlacesToVisitTab = CountryPlacesToVisitPage;