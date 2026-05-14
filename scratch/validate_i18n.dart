import 'dart:io';

void main() {
  final file = File('lib/core/localization/app_strings.dart');
  final content = file.readAsStringSync();
  
  final esMatch = RegExp(r"'es': \{([^}]+)\}", multiLine: true).firstMatch(content);
  final caMatch = RegExp(r"'ca': \{([^}]+)\}", multiLine: true).firstMatch(content);
  final enMatch = RegExp(r"'en': \{([^}]+)\}", multiLine: true).firstMatch(content);
  
  if (esMatch == null || caMatch == null || enMatch == null) {
    print('Could not find language maps');
    return;
  }
  
  Set<String> getKeys(String mapContent) {
    return RegExp(r"'([^']+)':")
        .allMatches(mapContent)
        .map((m) => m.group(1)!)
        .toSet();
  }
  
  final esKeys = getKeys(esMatch.group(1)!);
  final caKeys = getKeys(caMatch.group(1)!);
  final enKeys = getKeys(enMatch.group(1)!);
  
  print('ES keys: ${esKeys.length}');
  print('CA keys: ${caKeys.length}');
  print('EN keys: ${enKeys.length}');
  
  final allKeys = esKeys.union(caKeys).union(enKeys);
  
  for (final key in allKeys) {
    if (!esKeys.contains(key)) print('Missing ES key: $key');
    if (!caKeys.contains(key)) print('Missing CA key: $key');
    if (!enKeys.contains(key)) print('Missing EN key: $key');
  }
}
