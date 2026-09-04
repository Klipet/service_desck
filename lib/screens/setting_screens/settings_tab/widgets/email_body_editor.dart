import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:service_desk/const/const_colors.dart';

/// Компактный rich-text редактор тела email-шаблона (без вложений файлов —
/// они тут не нужны). HTML для отправки на бэк получается через
/// deltaToHtml(controller.document.toDelta()) в момент сабмита формы.
class EmailBodyEditor extends StatefulWidget {
  final quill.QuillController controller;

  const EmailBodyEditor({super.key, required this.controller});

  @override
  State<EmailBodyEditor> createState() => _EmailBodyEditorState();
}

class _EmailBodyEditorState extends State<EmailBodyEditor> {
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderCardColor, width: 1.w),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          quill.QuillSimpleToolbar(
            controller: widget.controller,
            config: const quill.QuillSimpleToolbarConfig(
              multiRowsDisplay: true,
              showFontFamily: false,
              showFontSize: false,
              showSmallButton: false,
              showLineHeightButton: false,
              showAlignmentButtons: false,
              showDirection: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
              showClipboardCut: false,
              showClipboardCopy: false,
              showClipboardPaste: false,
              showIndent: false,
              showBackgroundColorButton: false,
              showListCheck: false,
              showQuote: false,
              showCodeBlock: false,
              embedButtons: [],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 270.h,
            child: quill.QuillEditor.basic(
              controller: widget.controller,
              focusNode: _focusNode,
              scrollController: _scrollController,
              config: const quill.QuillEditorConfig(padding: EdgeInsets.all(12)),
            ),
          ),
        ],
      ),
    );
  }
}
