// Web implementation using dart:html
import 'dart:html' as html;

String? getItem(String key) {
  return html.window.localStorage[key];
}

void setItem(String key, String value) {
  html.window.localStorage[key] = value;
}

List<String> getAllKeys() {
  final keys = <String>[];
  for (var i = 0; i < html.window.localStorage.length; i++) {
    final key = html.window.localStorage.keys.elementAt(i);
    keys.add(key);
  }
  return keys;
}
