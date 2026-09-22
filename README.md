# cred

Bill payment home screen — **Phase 1** (visual foundation + basic interaction).

## What Phase 1 contains

```
HomeScreen
├── UpperSection  (static header, never scrolls)
│   ├── SummaryPill      Total Due | Recent Spends  (AnimatedAlign indicator)
│   └── SummaryContent   AnimatedSwitcher between the two tab states
│       ├── StatementDue  + PayBillButton   (primary state)
│       └── RecentSpendsPlaceholder         (simple placeholder state)
└── LowerSection  (Expanded)
    └── BillCard          one static card built from the Bill model
```

* `Total Due` is the primary implemented state: statement label, hero amount and
  a `Pay Bill` button.
* `Recent Spends` is a working placeholder state, proving the pill switches and
  the content transitions (`AnimatedSwitcher`, fade + slight slide).
* `Pay Bill` is **visual only** — `onPressed` is a placeholder callback. No
  gateway, API, database, navigation or payment logic exists in Phase 1.
* The lower area holds **exactly one** card: no stacking, scrolling, swiping,
  long press, dragging, dismissal or expansion. Those belong to Phase 2.

## Structure

```
lib/
├── main.dart                     app entry point (status bar styling + runApp)
├── app/
│   ├── app.dart                  CredApp (MaterialApp, theme, text-scale clamp)
│   └── theme.dart                design tokens: colours, radii, spacing,
│                                 durations, text styles, gradients, appScale()
├── core/
│   └── formatters.dart           formatRupees() - Indian digit grouping
├── models/
│   └── bill.dart                 Bill model (title, provider, amount, dueText)
└── screens/home/
    ├── home_screen.dart          state: `int _selectedTab` only
    └── widgets/
        ├── upper_section.dart    static header, composes the pill + content
        ├── summary_pill.dart     SummaryPill (reusable sliding pill)
        ├── summary_content.dart  SummaryContent / StatementDue /
        │                         RecentSpendsPlaceholder
        ├── pay_bill_button.dart  PayBillButton
        ├── lower_section.dart    LowerSection (card area, Phase 2 hook)
        └── bill_card.dart        BillCard (reusable, driven by the model)
```

State management is intentionally plain: a single `StatefulWidget` with one
`int` field. No Riverpod/Bloc/Provider/GetX, no third-party packages, no custom
`AnimationController`. Only `AnimatedAlign`, `AnimatedDefaultTextStyle` and
`AnimatedSwitcher` plus standard Material ripples are used.

## Layout & responsiveness

* `UpperSection` sizes itself from its content; the card area takes the rest via
  `Expanded`, so the two never interfere.
* `LowerSection` uses `LayoutBuilder` to size the card from the available width
  and height (no hardcoded screen sizes) and centres it.
* `appScale(context)` multiplies spacing and the hero amount by a factor derived
  from the viewport height (clamped to 0.82–1.18) for short and tall phones.
* Content is capped at 480 logical pixels wide so tablets/desktop keep phone-like
  proportions; the hero amount uses `FittedBox` so large values never overflow.
* Safe areas are respected and the text scale factor is clamped to 1.3 so the
  tight card layout survives large system font sizes.

## Phase 2 hooks

* `LowerSection` is the only widget that needs to change: swap its body for an
  animated card stack; `BillCard` already takes a model, so a `List<Bill>` can
  drive several instances unchanged.
* `SummaryPill` distributes its indicator evenly across `labels.length`, so more
  tabs can be added without touching the animation maths.
* Placeholder data lives in `_HomeScreenState` (one `Bill` plus the two summary
  amounts) and is passed down as parameters — a real data source can replace it
  without changing the widget APIs.

## Run & verify

```bash
flutter pub get
flutter run                 # device or emulator
flutter analyze             # no issues
flutter test                # 15 tests: pill animation, tab states, card, format
```


## Learn more about Flutter

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
