// Web implementation using package:web
import 'package:web/web.dart' as web;

String? getItem(String key) {
  return web.window.localStorage.getItem(key);
}

void setItem(String key, String value) {
  web.window.localStorage.setItem(key, value);
}

List<String> getAllKeys() {
  final keys = <String>[];
  final localStorage = web.window.localStorage;
  for (var i = 0; i < localStorage.length; i++) {
    final key = localStorage.key(i);
    if (key != null) {
      keys.add(key);
    }
  }
  return keys;
}
