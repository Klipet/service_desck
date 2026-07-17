import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';

/// Отдельный виджет редактора описания.
/// Заменяет собой прежний _BorderedTextField.
///
/// Поддерживает:
/// - форматирование текста (жирный, курсив, списки, заголовки и т.д.)
/// - вставку фото прямо в текст
/// - прикрепление произвольных файлов (список чипов под редактором)
class RichDescriptionEditor extends StatefulWidget {
  /// Начальное содержимое в формате Quill Delta (JSON-строка).
  /// Можно передать null для пустого документа.
  final String? initialDeltaJson;

  /// Вызывается при каждом изменении текста.
  /// Возвращает Delta в виде JSON-строки — храните её в БД как есть.
  final ValueChanged<String>? onDeltaChanged;

  /// Вызывается при каждом изменении текста, отдаёт обычный текст без разметки
  final ValueChanged<String>? onPlainTextChanged;

  /// Вызывается при изменении списка прикреплённых файлов
  final ValueChanged<List<PlatformFile>>? onFilesChanged;

  /// Начальный список уже прикреплённых файлов (например, при редактировании)
  final List<PlatformFile>? initialFiles;

  /// Высота области редактирования текста
  //  final double editorHeight;

  const RichDescriptionEditor({
    super.key,
    this.initialDeltaJson,
    this.onDeltaChanged,
    this.onPlainTextChanged,
    this.onFilesChanged,
    this.initialFiles,
    //    this.editorHeight = 300,
  });

  @override
  State<RichDescriptionEditor> createState() => _RichDescriptionEditorState();
}

class _RichDescriptionEditorState extends State<RichDescriptionEditor> {
  late final quill.QuillController _controller;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  bool _isDragging = false;
  late List<PlatformFile> _attachedFiles;

  @override
  void initState() {
    super.initState();

    _attachedFiles = List<PlatformFile>.from(widget.initialFiles ?? []);
    _controller = quill.QuillController(
      document: _buildInitialDocument(),
      selection: const TextSelection.collapsed(offset: 0),
    );

    _controller.document.changes.listen((_) {
      final deltaJson = jsonEncode(_controller.document.toDelta().toJson());
      widget.onDeltaChanged?.call(deltaJson);
      widget.onPlainTextChanged?.call(_controller.document.toPlainText());
    });
  }

  quill.Document _buildInitialDocument() {
    final raw = widget.initialDeltaJson;
    if (raw == null || raw.isEmpty) {
      return quill.Document();
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return quill.Document.fromJson(decoded);
    } catch (_) {
      // Если строка не является валидным Delta JSON (например, старый
      // документ хранился как обычный текст) — заворачиваем как plain text.
      return quill.Document()..insert(0, raw);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    setState(() {
      _attachedFiles.addAll(result.files);
    });
    widget.onFilesChanged?.call(_attachedFiles);
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
    widget.onFilesChanged?.call(_attachedFiles);
  }

  /// Конвертирует файлы, полученные от desktop_drop (XFile),
  /// в PlatformFile — чтобы использовать единый список/колбэк с file_picker.
  Future<void> _handleDroppedFiles(DropDoneDetails details) async {
    final List<PlatformFile> newFiles = [];

    for (final xFile in details.files) {
      final file = File(xFile.path);
      final bytes = await file.exists() ? null : null; // читаем лениво ниже
      final length = await file.exists() ? await file.length() : 0;

      newFiles.add(
        PlatformFile(
          name: xFile.name,
          path: xFile.path,
          size: length,
          bytes: bytes,
        ),
      );
    }

    if (newFiles.isEmpty) return;

    setState(() {
      _attachedFiles.addAll(newFiles);
      _isDragging = false;
    });
    widget.onFilesChanged?.call(_attachedFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropTarget(
          onDragDone: _handleDroppedFiles,
          onDragEntered: (_) => setState(() => _isDragging = true),
          onDragExited: (_) => setState(() => _isDragging = false),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textTitleFl, width: 1.w),
              borderRadius: BorderRadius.circular(10.r),
              color: _isDragging
                  ? AppColors.backgroundColor
                  : AppColors.backgroundCardColor,
            ),
            child: Column(
              children: [
                quill.QuillSimpleToolbar(
                  controller: _controller,
                  config: quill.QuillSimpleToolbarConfig(
                    color: AppColors.backgroundColor,
                    headerStyleType: quill.HeaderStyleType.buttons,
                    toolbarIconAlignment: WrapAlignment.start,
                    multiRowsDisplay: true,
                    showBackgroundColorButton: false,
                    showListCheck: false,
                    // ===== БЛОКИ ТЕКСТА =====
                    showQuote: false,
                    // Цитата
                    showCodeBlock: false,
                    // Блок кода
                    showLink: false,
                    // Вставить ссылку
                    showFontFamily: false,
                    // Семейство шрифтов (убрал)
                    showFontSize: false,
                    // Размер шрифта (убрал)
                    showSmallButton: false,
                    // Маленький текст
                    showLineHeightButton: false,
                    // Высота строки
                    showClearFormat: true,
                    // Очистить форматирование
                    showAlignmentButtons: false,
                    // Выравнивание (убрал всё)
                    showLeftAlignment: false,
                    showCenterAlignment: false,
                    showRightAlignment: false,
                    showJustifyAlignment: false,
                    showDirection: false,
                    // Направление текста
                    showSearchButton: false,
                    // Поиск (убрал)
                    showSubscript: false,
                    // Подстрочный индекс (убрал)
                    showSuperscript: false,
                    // Надстрочный индекс (убрал)
                    showClipboardCut: false,
                    // Вырезать (убрал)
                    showClipboardCopy: false,
                    // Копировать (убрал)
                    showClipboardPaste: false,
                    showHeaderStyle: false,
                    // Вставить (убрал)
                    showListBullets: false,
                    // Маркированный список
                    showListNumbers: false,
                    // Нумерованный список
                    showIndent: false,
                    // Отступ
                    embedButtons: [],
                    toolbarSize: 10,
                    // Расстояние между элементами
                    buttonOptions: quill.QuillSimpleToolbarButtonOptions(
                      base: quill.QuillToolbarBaseButtonOptions(
                        iconTheme: quill.QuillIconTheme(
                          iconButtonSelectedData: quill.IconButtonData(
                            iconSize: 20.r,
                            color: AppColors.btColor,
                            focusColor: AppColors.hintTextColor,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Colors.transparent;
                                }
                                if (states.contains(WidgetState.hovered)) {
                                  return Colors.transparent;
                                }
                                return Colors.transparent;
                              }),
                            ),
                          ),
                          iconButtonUnselectedData: quill.IconButtonData(
                            iconSize: 20.r,
                            color: AppColors.dataGreadColorTitle,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: quill.QuillEditor(
                    controller: _controller,
                    focusNode: _editorFocusNode,
                    scrollController: _editorScrollController,
                    config: quill.QuillEditorConfig(
                      disableClipboard: true,

                      padding: const EdgeInsets.all(12),
                      expands: false,
                      embedBuilders: FlutterQuillEmbeds.editorBuilders(
                        imageEmbedConfig: QuillEditorImageEmbedConfig(
                          imageProviderBuilder: (context, imageUrl) {
                            if (imageUrl.startsWith('http')) {
                              return NetworkImage(imageUrl);
                            }
                            return FileImage(File(imageUrl));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _pickFiles,
              icon: Icon(Icons.attach_file, color: AppColors.textTitleFl),
              label: Text(
                'Прикрепить файл',
                style: GoogleFonts.poppins(
                  color: AppColors.textColorBlack,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return AppColors.backgroundCardColor;
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return AppColors.backgroundCardColor;
                  }

                  if (states.contains(WidgetState.disabled)) {
                    return AppColors.backgroundCardColor;
                  }
                  if(_attachedFiles.isEmpty){
                    return AppColors.backgroundCardColor;
                  }else{
                    return AppColors.dataGreadColorTitle;
                  }
                }),
                side: WidgetStateProperty.all(
                  BorderSide(color: AppColors.textTitleFl, width: 1.w),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_attachedFiles.isNotEmpty)
              Text(
                '${_attachedFiles.length} файл(ов)',
                style: GoogleFonts.poppins(
                  color: AppColors.textColorBlack,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        if (_attachedFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_attachedFiles.length, (i) {
              final file = _attachedFiles[i];
              return Chip(
                backgroundColor: AppColors.backgroundCardColor,
                side: BorderSide(color: AppColors.textTitleFl, width: 0.5.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                ),
                avatar: Icon(
                  Icons.insert_drive_file,
                  size: 18,
                  color: AppColors.textTitleFl,
                ),
                label: Text(
                  file.name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: AppColors.textColorBlack),
                ),
                onDeleted: () => _removeFile(i),
              );
            }),
          ),
        ],
      ],
    );
  }
}
