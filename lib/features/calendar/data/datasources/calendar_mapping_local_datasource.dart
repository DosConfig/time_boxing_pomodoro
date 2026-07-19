import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../dtos/calendar_export_dto.dart';

class CalendarMappingLocalDataSource {
  static const _mappingKeyPrefix = 'calendar';

  Future<void> saveMappings(
    String provider,
    String dateKey,
    List<CalendarEventMappingDto> mappings,
  ) async {
    if (mappings.isEmpty) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    final merged = {
      for (final mapping in await loadMappings(provider, dateKey))
        mapping.timeBoxId: mapping,
      for (final mapping in mappings) mapping.timeBoxId: mapping,
    };
    final encoded = jsonEncode(
      merged.values.map((mapping) => mapping.toJson()).toList(),
    );
    await preferences.setString(_storageKey(provider, dateKey), encoded);
  }

  Future<List<CalendarEventMappingDto>> loadMappings(
    String provider,
    String dateKey,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey(provider, dateKey));
    if (encoded == null || encoded.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map>()
          .map(
            (item) => CalendarEventMappingDto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  String _storageKey(String provider, String dateKey) {
    return '$_mappingKeyPrefix.$provider.mappings.$dateKey';
  }
}
