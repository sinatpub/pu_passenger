// For `String.characters` — Flutter re-exports the `characters` package, so
// initials split on grapheme clusters rather than UTF-16 units and a Khmer
// name does not lose its combining marks. Imported through Flutter to avoid
// declaring a dependency the framework already provides.
import 'package:flutter/widgets.dart';

/// Avatar initials for `TaAvatar`/`TaDriverCard` (component spec §12/§15).
///
/// Extracted rather than inlined in the booking sheet because C6's fee card
/// and S1's history card render the same driver avatar — the same way
/// `vehicle_cell_data.dart` keeps Home and Map from drifting (C3).
///
/// Takes the first letter of the first two words, uppercased. Returns an
/// empty string for a missing or blank name so the avatar draws its plain
/// circle rather than a literal "null" — the backend leaves `driver.name`
/// nullable and a booking can be rendered before the driver is attached.
String initialsFromName(String? name) {
  final words = (name ?? '').trim().split(RegExp(r'\s+'))
    ..removeWhere((word) => word.isEmpty);
  if (words.isEmpty) return '';
  return words
      .take(2)
      .map((word) => word.characters.first.toUpperCase())
      .join();
}
