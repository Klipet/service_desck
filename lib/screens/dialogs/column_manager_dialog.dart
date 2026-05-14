import 'package:flutter/material.dart';

import '../../models/model_data_table_tiket/column_config.dart';

class ColumnManagerDialog extends StatefulWidget {
  final List<ColumnConfig> configs;
  final VoidCallback onChanged;

  const ColumnManagerDialog({
    required this.configs,
    required this.onChanged,
  });

  @override
  State<ColumnManagerDialog> createState() => ColumnManagerDialogState();
}

class ColumnManagerDialogState extends State<ColumnManagerDialog> {
  @override
  Widget build(BuildContext context) {
    final visibleCount = widget.configs.where((c) => c.visible).length;

    return AlertDialog(
      title: const Text('Управление колонками'),
      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (final c in widget.configs) {
                          if (c.columnName == 'id') continue; // <- защита
                          c.visible = true;
                        }
                      });
                      widget.onChanged();
                    },
                    child: const Text('Все'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        // Оставляем хотя бы одну
                        for (int i = 1; i < widget.configs.length; i++) {
                          widget.configs[i].visible = false;
                        }
                      });
                      widget.onChanged();
                    },
                    child: const Text('Снять все'),
                  ),
                  const Spacer(),
                  Text(
                    '$visibleCount / ${widget.configs.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.configs.length,
                itemBuilder: (_, i) {
                  final config = widget.configs[i];
                  return CheckboxListTile(
                    dense: true,
                    title: Text(config.label, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      config.columnName,
                      style: const TextStyle(fontSize: 11),
                    ),
                    value: config.visible,
                    onChanged: config.columnName == 'id'
                        ? null
                        : (val) {
                      if (val == false && visibleCount <= 1) return;
                      setState(() => config.visible = val ?? true);
                      widget.onChanged();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}