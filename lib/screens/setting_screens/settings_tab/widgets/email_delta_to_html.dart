import 'package:flutter_quill/quill_delta.dart';

/// Минимальный конвертер Quill Delta -> HTML для тела email-шаблона.
/// Поддерживает: жирный, курсив, подчёркнутый, заголовки h1-h3,
/// маркированные/нумерованные списки, обычные абзацы, ссылки.
/// Embed-вставки (картинки и т.п.) игнорируются — тулбар редактора их не даёт вставить.
String deltaToHtml(Delta delta) {
  final buffer = StringBuffer();
  final lineRuns = <_Run>[];
  String? openListType;

  void closeListIfNeeded() {
    if (openListType != null) {
      buffer.writeln(openListType == 'bullet' ? '</ul>' : '</ol>');
      openListType = null;
    }
  }

  void flushLine(Map<String, dynamic> lineAttrs) {
    final inner = lineRuns.map((r) => r.toHtml()).join();
    lineRuns.clear();

    final list = lineAttrs['list'];
    if (list == 'bullet' || list == 'ordered') {
      if (openListType != list) {
        closeListIfNeeded();
        buffer.writeln(list == 'bullet' ? '<ul>' : '<ol>');
        openListType = list as String;
      }
      buffer.writeln('<li>$inner</li>');
      return;
    }
    closeListIfNeeded();

    final header = lineAttrs['header'];
    if (header is int && header >= 1 && header <= 3) {
      buffer.writeln('<h$header>$inner</h$header>');
    } else if (inner.isNotEmpty) {
      buffer.writeln('<p>$inner</p>');
    }
  }

  for (final op in delta.toList()) {
    final data = op.data;
    if (data is! String) continue; // embed — пропускаем
    final attrs = op.attributes ?? const {};
    final segments = data.split('\n');

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      if (segment.isNotEmpty) {
        lineRuns.add(_Run(segment, attrs));
      }
      final isLastSegment = i == segments.length - 1;
      if (!isLastSegment) {
        flushLine(attrs);
      }
    }
  }
  if (lineRuns.isNotEmpty) flushLine(const {});
  closeListIfNeeded();

  return buffer.toString().trim();
}

class _Run {
  final String text;
  final Map<String, dynamic> attributes;

  _Run(this.text, this.attributes);

  String toHtml() {
    var escaped = text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');

    if (attributes['bold'] == true) escaped = '<strong>$escaped</strong>';
    if (attributes['italic'] == true) escaped = '<em>$escaped</em>';
    if (attributes['underline'] == true) escaped = '<u>$escaped</u>';
    final link = attributes['link'];
    if (link is String && link.isNotEmpty) {
      escaped = '<a href="$link">$escaped</a>';
    }
    return escaped;
  }
}
