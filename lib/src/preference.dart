// import 'package:shared_preferences/shared_preferences.dart';

// class SharedPref {
//   setPref(String key, String value) async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString(key, value);
//   }

//   getPref(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(key);
//   }

//   dropPref(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.remove(key);
//   }
// }

import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  Future<void> setPref(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('Saved $key: $value'); // Debug print
  }

  Future<String?> getPref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key);
    print('Retrieved $key: $value'); // Debug print
    return value;
  }

  Future<void> dropPref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    print('Removed $key'); // Debug print
  }
}



