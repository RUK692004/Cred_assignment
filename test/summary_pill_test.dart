import 'package:cred/app/theme.dart';
import 'package:cred/screens/home/widgets/summary_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal host that owns the selected index, exactly like HomeScreen does.
class _PillHost extends StatefulWidget {
  const _PillHost();

  @override
  State<_PillHost> createState() => _PillHostState();
}

class _PillHostState extends State<_PillHost> {
  int _selected = kTotalDueTab;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SummaryPill(
            selectedIndex: _selected,
            onSelected: (int index) => setState(() => _selected = index),
          ),
        ),
      ),
    );
  }
}

void main() {
  /// Where the indicator is configured to sit.
  AlignmentGeometry? configuredAlignment(WidgetTester tester) =>
      tester.widget<AnimatedAlign>(find.byType(AnimatedAlign)).alignment;

  /// Where the indicator is actually painted right now - this is what makes
  /// the test able to observe the animation mid-flight.
  double indicatorCenterX(WidgetTester tester) => tester
      .getCenter(
        find
            .descendant(
              of: find.byType(AnimatedAlign),
              matching: find.byType(Container),
            )
            .first,
      )
      .dx;

  /// Colour actually painted for [label], resolved through the text style.
  Color? labelColor(WidgetTester tester, String label) =>
      tester.renderObject<RenderParagraph>(find.text(label)).text.style?.color;

  testWidgets('offers both options and starts on Total Due', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _PillHost());

    expect(find.text('TOTAL DUE'), findsOneWidget);
    expect(find.text('RECENT SPENDS'), findsOneWidget);
    expect(configuredAlignment(tester), Alignment.centerLeft);
    expect(labelColor(tester, 'TOTAL DUE'), AppColors.textPrimary);
    expect(labelColor(tester, 'RECENT SPENDS'), AppColors.pillLabelUnselected);
  });

  testWidgets('slides the indicator and the selection to the tapped option', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _PillHost());

    await tester.tap(find.text('RECENT SPENDS'));
    await tester.pumpAndSettle();

    expect(configuredAlignment(tester), Alignment.centerRight);
    expect(labelColor(tester, 'RECENT SPENDS'), AppColors.textPrimary);
    expect(labelColor(tester, 'TOTAL DUE'), AppColors.pillLabelUnselected);

    await tester.tap(find.text('TOTAL DUE'));
    await tester.pumpAndSettle();

    expect(configuredAlignment(tester), Alignment.centerLeft);
    expect(labelColor(tester, 'TOTAL DUE'), AppColors.textPrimary);
  });

  testWidgets('animates the indicator instead of jumping', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _PillHost());

    final double startX = indicatorCenterX(tester);

    await tester.tap(find.text('RECENT SPENDS'));
    // First pump rebuilds the pill with the new target alignment, the second
    // one advances the clock half-way through the 240 ms slide.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final double midX = indicatorCenterX(tester);

    await tester.pumpAndSettle();
    final double endX = indicatorCenterX(tester);

    expect(midX, greaterThan(startX));
    expect(midX, lessThan(endX));
  });
}
