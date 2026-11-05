import 'dart:convert';

import '../db/database.dart';

/// What a home costs to live in each month besides the rent or mortgage:
/// council tax and bills, as the user typed them (from the council's band
/// charge and the advert or the current tenant). Kept in the property's
/// JSON extras, so no schema change.
({int? councilTax, int? bills}) runningCosts(Property p) {
  final m = _meta(p.meta);
  int? at(String k) => switch (m[k]) {
    num v => v.round(),
    _ => null,
  };
  return (councilTax: at('councilTax'), bills: at('bills'));
}

/// Rent plus council tax plus bills, for a home to rent; null without a rent.
int? allInMonthly(Property p) {
  if (p.price == null) return null;
  final c = runningCosts(p);
  return p.price! + (c.councilTax ?? 0) + (c.bills ?? 0);
}

/// [meta] with the running costs set (null removes one); other keys kept.
String withRunningCosts(String meta, {int? councilTax, int? bills}) {
  final m = _meta(meta);
  for (final (k, v) in [('councilTax', councilTax), ('bills', bills)]) {
    if (v == null) {
      m.remove(k);
    } else {
      m[k] = v;
    }
  }
  return jsonEncode(m);
}

Map<String, Object?> _meta(String meta) {
  try {
    final j = jsonDecode(meta);
    return j is Map ? j.cast<String, Object?>() : <String, Object?>{};
  } on FormatException {
    return <String, Object?>{};
  }
}
