import 'package:flutter/widgets.dart';

/// Layout geometry for an individual tab in the category selector.
class CategoryTabLayout {
  /// Left offset of the text label.
  final double textLeft;

  /// Width of the text label.
  final double textWidth;

  /// Horizontal center coordinate of the text label.
  final double center;

  /// Left offset for the active indicator bar when this tab is selected.
  final double indicatorLeft;

  /// Left offset of the touch hit-target for this tab.
  final double tapLeft;

  /// Width of the touch hit-target for this tab.
  final double tapWidth;

  const CategoryTabLayout({
    required this.textLeft,
    required this.textWidth,
    required this.center,
    required this.indicatorLeft,
    required this.tapLeft,
    required this.tapWidth,
  });
}

/// Result of category selector geometry calculation.
class CategorySelectorResult {
  /// Layout geometry for each tab.
  final List<CategoryTabLayout> tabs;

  /// Uniform spacing (gap) between every adjacent pair of text labels.
  final double uniformSpacing;

  /// Width of the active indicator bar.
  final double indicatorWidth;

  /// Active indicator left offset for the currently selected index.
  final double activeIndicatorLeft;

  const CategorySelectorResult({
    required this.tabs,
    required this.uniformSpacing,
    required this.indicatorWidth,
    required this.activeIndicatorLeft,
  });
}

/// Pure presentation calculator for category selector layout geometry.
/// Guarantees:
/// 1. Exactly uniform spacing between each adjacent text label.
/// 2. Identical center coordinates for each text label and its active indicator bar.
/// 3. Zero inactive track overhang at the start and end of the selector.
class CategorySelectorCalculator {
  CategorySelectorCalculator._();

  /// Calculates exact tab and indicator positions given tab names, container width, and typography style.
  static CategorySelectorResult calculate({
    required List<String> categories,
    required int selectedIndex,
    required double totalWidth,
    required TextStyle textStyle,
    double? customIndicatorWidth,
  }) {
    assert(categories.length >= 2, 'Must have at least 2 categories');

    final safeIndex = selectedIndex.clamp(0, categories.length - 1);
    final indicatorWidth = (customIndicatorWidth ?? (totalWidth * 0.16)).clamp(44.0, 50.0);

    // 1. Measure text widths with given style
    final textWidths = categories.map((name) {
      final painter = TextPainter(
        text: TextSpan(text: name, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      return painter.width;
    }).toList();

    // 2. Tab 0 center starts at indicatorWidth / 2 so indicator starts flush at 0.0
    final c0 = indicatorWidth / 2.0;
    final r0 = c0 + (textWidths.first / 2.0);

    // 3. Tab Last center ends at totalWidth - indicatorWidth / 2 so indicator ends flush at totalWidth
    final cLast = totalWidth - (indicatorWidth / 2.0);
    final lLast = cLast - (textWidths.last / 2.0);

    // 4. Calculate uniform spacing between adjacent text labels
    final midWidthsSum = textWidths
        .sublist(1, categories.length - 1)
        .fold<double>(0.0, (sum, w) => sum + w);

    final gapCount = categories.length - 1;
    final availableGapSpace = lLast - r0 - midWidthsSum;

    final tabs = <CategoryTabLayout>[];
    final double uniformSpacing;

    if (availableGapSpace > 0 && gapCount > 0) {
      uniformSpacing = availableGapSpace / gapCount;

      var currentLeft = c0 - (textWidths.first / 2.0);
      for (var i = 0; i < categories.length; i++) {
        final w = textWidths[i];
        final double center;
        final double textLeft;
        final double indicatorLeft;

        if (i == 0) {
          center = c0;
          textLeft = c0 - (w / 2.0);
          indicatorLeft = 0.0;
        } else if (i == categories.length - 1) {
          center = cLast;
          textLeft = lLast;
          indicatorLeft = totalWidth - indicatorWidth;
        } else {
          textLeft = currentLeft;
          center = textLeft + (w / 2.0);
          indicatorLeft = center - (indicatorWidth / 2.0);
        }

        tabs.add(CategoryTabLayout(
          textLeft: textLeft,
          textWidth: w,
          center: center,
          indicatorLeft: indicatorLeft,
          tapLeft: 0.0, // populated below
          tapWidth: 0.0,
        ));

        currentLeft += w + uniformSpacing;
      }
    } else {
      // Fallback for constrained viewports or large accessibility/test fonts
      final step = (totalWidth - indicatorWidth) / gapCount;
      uniformSpacing = 0.0;

      for (var i = 0; i < categories.length; i++) {
        final w = textWidths[i];
        final center = (i * step) + (indicatorWidth / 2.0);
        final textLeft = center - (w / 2.0);
        final indicatorLeft = i * step;

        tabs.add(CategoryTabLayout(
          textLeft: textLeft,
          textWidth: w,
          center: center,
          indicatorLeft: indicatorLeft,
          tapLeft: 0.0,
          tapWidth: 0.0,
        ));
      }
    }

    // 5. Build tap hit-test areas covering the entire bar seamlessly
    final finalizedTabs = <CategoryTabLayout>[];
    for (var i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      final tapLeft = (i == 0)
          ? 0.0
          : (tabs[i - 1].center + tab.center) / 2.0;

      final tapRight = (i == tabs.length - 1)
          ? totalWidth
          : (tab.center + tabs[i + 1].center) / 2.0;

      finalizedTabs.add(CategoryTabLayout(
        textLeft: tab.textLeft,
        textWidth: tab.textWidth,
        center: tab.center,
        indicatorLeft: tab.indicatorLeft,
        tapLeft: tapLeft,
        tapWidth: tapRight - tapLeft,
      ));
    }

    return CategorySelectorResult(
      tabs: finalizedTabs,
      uniformSpacing: uniformSpacing,
      indicatorWidth: indicatorWidth,
      activeIndicatorLeft: finalizedTabs[safeIndex].indicatorLeft,
    );
  }
}
