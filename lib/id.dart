import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? localId;

const idKey = 'local_id';

Future<void> generateId() async {
  if (localId != null) {
    return;
  }

  var prefs = await SharedPreferences.getInstance();
  var prefsId = prefs.getString(idKey);

  if (prefsId != null) {
    localId = prefsId;
  } else {
    localId = UniqueKey().toString();

    await prefs.setString(idKey, localId!);
  }
}
