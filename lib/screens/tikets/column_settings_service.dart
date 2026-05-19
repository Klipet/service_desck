import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../const/const_app.dart';
import '../../models/model_data_table_tiket/column_config.dart';



class ColumnSettingsService{


  Future<void> saveColumnSettings(List<ColumnConfig> configs) async {
    final prefs = await SharedPreferences.getInstance();
    final data = configs
        .map((c) => {'columnName': c.columnName, 'visible': c.visible})
        .toList();
    await prefs.setString(prefKey, jsonEncode(data));
  }

  Future<void> saveColumnWidths(Map<String, double> widths) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefWidth, jsonEncode(widths));
  }

  // ✅ Возвращаем данные наружу, не храним внутри
  Future<Map<String, double>> loadColumnWidths() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(prefWidth);
    if (jsonString == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    return decoded
        .map((key, value) => MapEntry(key, value.toDouble()))
      ..removeWhere((key, value) => value <= 0);
  }

  Future<List<ColumnConfig>> loadColumnSettings(List<ColumnConfig> defaults) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(prefKey);
    if (raw == null) return defaults; // ✅ возвращаем дефолт если нет сохранения

    try {
      final List saved = jsonDecode(raw);
      final savedMap = {
        for (final item in saved) item['columnName'] as String: item,
      };

      final reordered = <ColumnConfig>[];

      for (final item in saved) {
        final name = item['columnName'] as String;
        final config = defaults.firstWhere(
              (c) => c.columnName == name,
          orElse: () => ColumnConfig(columnName: '', label: '', width: 0),
        );
        if (config.columnName.isEmpty) continue;
        config.visible = item['visible'] as bool;
        reordered.add(config);
      }

      for (final c in defaults) {
        if (!savedMap.containsKey(c.columnName)) {
          reordered.add(c);
        }
      }

      return reordered; // ✅ возвращаем, не сохраняем внутри
    } catch (_) {
      return defaults;
    }
  }

}