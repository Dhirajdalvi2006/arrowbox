import '../bold/bold_arrow_skin.dart';
import '../classic/classic_arrow_skin.dart';
import '../fantasy/fantasy_arrow_skin.dart';
import '../glass/glass_arrow_skin.dart';
import '../minimal/minimal_arrow_skin.dart';
import '../models/arrow_skin.dart';
import '../models/arrow_skin_id.dart';
import '../neon/neon_arrow_skin.dart';
import '../pastel/pastel_arrow_skin.dart';
import '../tech/tech_arrow_skin.dart';
import '../cyber/cyber_arrow_skin.dart';
import '../void_style/void_arrow_skin.dart';
import '../aurora/aurora_arrow_skin.dart';

class ArrowSkinRegistry {
  const ArrowSkinRegistry._();

  static const List<ArrowSkin> all = [
    ClassicArrowSkin(),
    NeonArrowSkin(),
    GlassArrowSkin(),
    MinimalArrowSkin(),
    BoldArrowSkin(),
    PastelArrowSkin(),
    TechArrowSkin(),
    FantasyArrowSkin(),
    CyberArrowSkin(),
    VoidArrowSkin(),
    AuroraArrowSkin(),
  ];

  static ArrowSkin byId(ArrowSkinId id) =>
      all.firstWhere((skin) => skin.id == id);
}
