/// Converts backend JSON response keys into the app's canonical camelCase
/// shape before repositories and models consume them.
Map<String, dynamic> normalizeKeys(Map<String, dynamic> json) {
  return json.map(
    (key, value) => MapEntry(_snakeToCamel(key), normalizeJsonValue(value)),
  );
}

List<dynamic> normalizeJsonList(List<dynamic> values) {
  return values.map(normalizeJsonValue).toList(growable: false);
}

dynamic normalizeJsonValue(dynamic value) {
  if (value is Map<String, dynamic>) {
    return normalizeKeys(value);
  }
  if (value is Map) {
    return normalizeKeys(
      value.map((key, nested) => MapEntry(key.toString(), nested)),
    );
  }
  if (value is List) {
    return normalizeJsonList(value);
  }
  return value;
}

String _snakeToCamel(String key) {
  if (!key.contains('_')) return key;

  final buffer = StringBuffer();
  var uppercaseNext = false;
  for (final codeUnit in key.codeUnits) {
    final char = String.fromCharCode(codeUnit);
    if (char == '_') {
      uppercaseNext = buffer.isNotEmpty;
      continue;
    }
    if (uppercaseNext) {
      buffer.write(char.toUpperCase());
      uppercaseNext = false;
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}
