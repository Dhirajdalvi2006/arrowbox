import 'dart:convert';
import 'dart:io';

class CatalogCheckpoint {
  CatalogCheckpoint({
    required this.configuration,
    required this.start,
    required this.end,
    required this.results,
  });

  static const schemaVersion = 1;
  final String configuration;
  final int start;
  final int end;
  final Map<int, Map<String, Object?>> results;

  factory CatalogCheckpoint.empty({
    required String configuration,
    required int start,
    required int end,
  }) => CatalogCheckpoint(
    configuration: configuration,
    start: start,
    end: end,
    results: {},
  );

  factory CatalogCheckpoint.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != schemaVersion ||
        json['configuration'] is! String ||
        json['start'] is! int ||
        json['end'] is! int ||
        json['results'] is! Map) {
      throw const FormatException('Incompatible catalog checkpoint');
    }
    final rawResults = json['results'] as Map;
    final results = <int, Map<String, Object?>>{};
    for (final entry in rawResults.entries) {
      final level = int.tryParse(entry.key.toString());
      if (level == null || entry.value is! Map) {
        throw const FormatException('Invalid catalog checkpoint result');
      }
      results[level] = Map<String, Object?>.from(entry.value as Map);
    }
    return CatalogCheckpoint(
      configuration: json['configuration'] as String,
      start: json['start'] as int,
      end: json['end'] as int,
      results: results,
    );
  }

  static CatalogCheckpoint read(File file) => CatalogCheckpoint.fromJson(
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
      );

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'configuration': configuration,
    'start': start,
    'end': end,
    'results': {
      for (final entry in results.entries) entry.key.toString(): entry.value,
    },
  };

  void save(File file) {
    final temporary = File('${file.path}.tmp');
    final backup = File('${file.path}.bak');
    temporary.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(toJson()),
    );
    CatalogCheckpoint.read(temporary);

    if (backup.existsSync()) backup.deleteSync();
    if (file.existsSync()) file.renameSync(backup.path);
    try {
      temporary.renameSync(file.path);
      if (backup.existsSync()) backup.deleteSync();
    } catch (_) {
      if (file.existsSync()) file.deleteSync();
      if (backup.existsSync()) backup.renameSync(file.path);
      rethrow;
    } finally {
      if (temporary.existsSync()) temporary.deleteSync();
    }
  }

  static void recover(File file) {
    final backup = File('${file.path}.bak');
    final temporary = File('${file.path}.tmp');
    if (!file.existsSync() && backup.existsSync()) {
      backup.renameSync(file.path);
    }
    if (temporary.existsSync()) {
      try {
        read(temporary);
        if (!file.existsSync()) {
          temporary.renameSync(file.path);
        } else {
          temporary.deleteSync();
        }
      } on FormatException {
        temporary.deleteSync();
      }
    }
  }
}
