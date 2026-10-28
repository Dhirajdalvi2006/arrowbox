# Arrow design library

The ArrowBox design library provides eight reusable visual skins without coupling them to gameplay state. Every skin uses the existing `ArrowDirection` enum and preserves the game's direction semantics.

## Structure

- `models/`: skin identifiers, contract, and visual configuration.
- `core/`: direction mapping, colors, icon geometry, painter accents, and frames.
- One folder per style: Classic, Neon, Glass, Minimal, Bold, Pastel, Tech, and Fantasy.
- `registry/`: ordered catalog lookup.
- `preview/`: deterministic comparison board.

## Usage

```dart
import 'package:locate/features/arrow_designs/arrow_designs.dart';

final skin = ArrowSkinRegistry.byId(ArrowSkinId.neon);
final arrow = skin.buildArrow(
  direction: ArrowDirection.up,
  size: 64,
  highlighted: true,
);
```

Render all styles with `ArrowSkinRegistry.all`, or compare one style with `ArrowSkinPreviewBoard(skin: skin)`. To add a ninth skin, implement `ArrowSkin`, add its folder/file, export it from `arrow_designs.dart`, and add one instance to `ArrowSkinRegistry.all`.

The registry and renderer are presentation-only. Arrow movement, solvability, scoring, and saved game state remain in `features/arrowbox`.
