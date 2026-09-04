import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/data_base/user_repository.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';
import 'package:service_desk/models/email_template_models/email_template_create_model.dart';
import 'package:service_desk/models/email_template_models/email_template_list_model.dart';
import 'package:service_desk/screens/widgets/bordered_form_field.dart';
import 'package:service_desk/screens/widgets/custom_dictionary_dropdown_widget.dart';

import '../../../blocs/email_template_blocs/email_template_bloc.dart';
import '../../../blocs/ticket_state_blocs/ticket_state_bloc.dart';
import 'widgets/email_body_editor.dart';
import 'widgets/email_delta_to_html.dart';

class EmailTemplateCreateTab extends StatelessWidget {
  const EmailTemplateCreateTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TicketStateBloc()),
        BlocProvider(create: (_) => EmailTemplateBloc()),
      ],
      child: const _EmailTemplateCreateTabBody(),
    );
  }
}

class _EmailTemplateCreateTabBody extends StatefulWidget {
  const _EmailTemplateCreateTabBody();

  @override
  State<_EmailTemplateCreateTabBody> createState() =>
      _EmailTemplateCreateTabBodyState();
}

/// Переменные, доступные в шаблонах писем (см. TicketTemplateVariables.cs
/// на бэке — ключи и формат `{Ключ}` должны совпадать 1-в-1).
const _kEmailTemplateVariables = <String, String>{
  'TicketNumber': 'Номер заявки',
  'ClientName': 'Имя клиента',
  'UserName': 'Имя исполнителя',
  'Status': 'Статус',
  'Priority': 'Приоритет',
  'Deadline': 'Срок',
  'MessageText': 'Текст сообщения',
  'CompanyName': 'Компания',
};

class _EmailTemplateCreateTabBodyState
    extends State<_EmailTemplateCreateTabBody> {
  final _userRepo = UserRepository();
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _htmlSourceController = TextEditingController();
  late final quill.QuillController _bodyController;

  String _apiKey = '';
  bool _saving = false;
  bool _isActive = true;
  bool _rawHtmlMode = false;
  bool _loadingTemplates = true;
  List<SimpleDictionaryModel> _states = [];
  List<EmailTemplateListModel> _templates = [];
  int? _selectedStateOid;

  @override
  void initState() {
    super.initState();
    _bodyController = quill.QuillController.basic();
    _init();
  }

  Future<void> _init() async {
    final apiKey = await _userRepo.getUserApikey();
    if (!mounted) return;
    setState(() => _apiKey = apiKey ?? '');
    context.read<TicketStateBloc>().add(LoadAllTicketStatesEvent(_apiKey));
    _loadTemplates();
  }

  void _loadTemplates() {
    setState(() => _loadingTemplates = true);
    context.read<EmailTemplateBloc>().add(LoadAllEmailTemplatesEvent(_apiKey));
  }

  void _deleteTemplate(EmailTemplateListModel template) {
    context.read<EmailTemplateBloc>().add(
      DeleteEmailTemplateEvent(apiKey: _apiKey, oid: template.oid),
    );
  }

  Future<void> _editTemplate(EmailTemplateListModel template) async {
    final subjectController = TextEditingController(
      text: template.subjectTemplate,
    );
    final bodyController = TextEditingController(
      text: template.bodyHtmlTemplate,
    );
    var selectedStateOid = template.stateOid;
    var isActive = template.isActive;
    final dialogFormKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          title: Text(
            'Редактирование шаблона',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 480.w,
            child: Form(
              key: dialogFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BorderedFieldLabel('Тема письма'),
                    BorderedFormField(
                      controller: subjectController,
                      hint: 'Тема письма',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Введите тему'
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    BorderedFieldLabel('Статус заявки'),
                    CustomDictionaryDropdown(
                      hintText: 'Статус заявки',
                      icon: Icons.flag_outlined,
                      items: _states.map((s) => s.toDictionaryItem()).toList(),
                      initialValue: _states
                          .where((s) => s.oid == selectedStateOid)
                          .map((s) => s.toDictionaryItem())
                          .firstOrNull,
                      onSelected: (item) =>
                          setDialogState(() => selectedStateOid = item.oid),
                    ),
                    SizedBox(height: 4.h),
                    Material(
                      type: MaterialType.transparency,
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Активен'),
                        value: isActive,
                        onChanged: (v) =>
                            setDialogState(() => isActive = v ?? true),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Текст письма (HTML)',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: AppColors.hintTextColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _buildVariableChips(
                      onSelected: (key) {
                        final placeholder = '{$key}';
                        final text = bodyController.text;
                        final selection = bodyController.selection;
                        final start = selection.start >= 0
                            ? selection.start
                            : text.length;
                        final end = selection.end >= 0
                            ? selection.end
                            : text.length;
                        bodyController.text = text.replaceRange(
                          start,
                          end,
                          placeholder,
                        );
                        bodyController.selection = TextSelection.collapsed(
                          offset: start + placeholder.length,
                        );
                      },
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      constraints: BoxConstraints(minHeight: 200.h),
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCardColor,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppColors.textTitleFl,
                          width: 1.w,
                        ),
                      ),
                      child: TextFormField(
                        controller: bodyController,
                        maxLines: null,
                        minLines: 10,
                        style: GoogleFonts.robotoMono(
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Введите текст письма'
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (!dialogFormKey.currentState!.validate()) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !mounted) return;

    final selectedState = _states.firstWhereOrNull(
      (s) => s.oid == selectedStateOid,
    );
    context.read<EmailTemplateBloc>().add(
      UpdateEmailTemplateEvent(
        apiKey: _apiKey,
        template: EmailTemplateCreateModel(
          oid: template.oid,
          subjectTemplate: subjectController.text.trim(),
          bodyHtmlTemplate: bodyController.text.trim(),
          isActive: isActive,
          stateOid: selectedStateOid,
          stateName: selectedState?.name,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _htmlSourceController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _insertBodyVariable(String key) {
    final placeholder = '{$key}';
    if (_rawHtmlMode) {
      final text = _htmlSourceController.text;
      final selection = _htmlSourceController.selection;
      final start = selection.start >= 0 ? selection.start : text.length;
      final end = selection.end >= 0 ? selection.end : text.length;
      _htmlSourceController.text = text.replaceRange(start, end, placeholder);
      _htmlSourceController.selection = TextSelection.collapsed(
        offset: start + placeholder.length,
      );
      return;
    }
    final selection = _bodyController.selection;
    final index = selection.start >= 0
        ? selection.start
        : _bodyController.document.length - 1;
    final length = selection.start >= 0 ? selection.end - selection.start : 0;
    _bodyController.replaceText(
      index,
      length,
      placeholder,
      TextSelection.collapsed(offset: index + placeholder.length),
    );
  }

  Widget _buildVariableChips({void Function(String key)? onSelected}) {
    final handler = onSelected ?? _insertBodyVariable;
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _kEmailTemplateVariables.entries
          .map(
            (e) => ActionChip(
              backgroundColor: AppColors.backgroundCardColor,
              side: BorderSide(color: AppColors.textTitleFl, width: 0.5.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              label: Text(
                '{${e.key}} — ${e.value}',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: AppColors.textColorBlack,
                ),
              ),
              onPressed: () => handler(e.key),
            ),
          )
          .toList(),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStateOid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите статус заявки')));
      return;
    }
    final html = _rawHtmlMode
        ? _htmlSourceController.text.trim()
        : deltaToHtml(_bodyController.document.toDelta());
    if (html.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите текст письма')));
      return;
    }

    setState(() => _saving = true);
    final selectedState = _states.firstWhere((s) => s.oid == _selectedStateOid);
    context.read<EmailTemplateBloc>().add(
      CreateEmailTemplateEvent(
        apiKey: _apiKey,
        template: EmailTemplateCreateModel(
          subjectTemplate: _subjectController.text.trim(),
          bodyHtmlTemplate: html,
          isActive: _isActive,
          stateOid: _selectedStateOid!,
          stateName: selectedState.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TicketStateBloc, TicketStateState>(
          listener: (context, state) {
            if (state is TicketStatesLoaded) {
              setState(() {
                _states = state.states;
                _selectedStateOid ??= state.states.isNotEmpty
                    ? state.states.first.oid
                    : null;
              });
            }
          },
        ),
        BlocListener<EmailTemplateBloc, EmailTemplateState>(
          listener: (context, state) {
            if (state is EmailTemplateCreated) {
              setState(() => _saving = false);
              _subjectController.clear();
              _bodyController.clear();
              _htmlSourceController.clear();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Шаблон создан')));
              _loadTemplates();
            } else if (state is EmailTemplateUpdated) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Шаблон обновлён')));
              _loadTemplates();
            } else if (state is EmailTemplatesLoaded) {
              setState(() {
                _templates = state.templates;
                _loadingTemplates = false;
              });
            } else if (state is EmailTemplateDeleted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Шаблон удалён')));
              _loadTemplates();
            } else if (state is EmailTemplateError) {
              setState(() {
                _saving = false;
                _loadingTemplates = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка: ${state.message}')),
              );
            }
          },
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Новый email-шаблон',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                    color: AppColors.textColorOne,
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.borderCardColor,
                        width: 1.w,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BorderedFieldLabel('Тема письма'),
                                      BorderedFormField(
                                        controller: _subjectController,
                                        hint: 'Тема письма',
                                        validator: (v) =>
                                            (v == null || v.trim().isEmpty)
                                            ? 'Введите тему'
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BorderedFieldLabel('Статус заявки'),
                                      CustomDictionaryDropdown(
                                        hintText: 'Статус заявки',
                                        icon: Icons.flag_outlined,
                                        items: _states
                                            .map((s) => s.toDictionaryItem())
                                            .toList(),
                                        initialValue: _states
                                            .where(
                                              (s) => s.oid == _selectedStateOid,
                                            )
                                            .map((s) => s.toDictionaryItem())
                                            .firstOrNull,
                                        onSelected: (item) => setState(
                                          () => _selectedStateOid = item.oid,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Material(
                              type: MaterialType.transparency,
                              child: CheckboxListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(
                                  'Активен',
                                  style: GoogleFonts.poppins(fontSize: 12.sp),
                                ),
                                value: _isActive,
                                onChanged: (v) =>
                                    setState(() => _isActive = v ?? true),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Текст письма',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: AppColors.hintTextColor,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'HTML-код',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.sp,
                                        color: AppColors.hintTextColor,
                                      ),
                                    ),
                                    Switch(
                                      value: _rawHtmlMode,
                                      onChanged: (v) =>
                                          setState(() => _rawHtmlMode = v),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            _buildVariableChips(),
                            SizedBox(height: 6.h),
                            if (_rawHtmlMode)
                              Container(
                                constraints: BoxConstraints(minHeight: 160.h),
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundCardColor,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: AppColors.textTitleFl,
                                    width: 1.w,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _htmlSourceController,
                                  maxLines: null,
                                  minLines: 8,
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 12.sp,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Вставьте готовый HTML письма...',
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: AppColors.textColorOne,
                                    ),
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                  ),
                                ),
                              )
                            else
                              EmailBodyEditor(controller: _bodyController),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.add, size: 18),
                    label: const Text('Создать'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textTitleFl,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(flex: 2, child: _buildTemplateList()),
        ],
      ),
    );
  }

  Widget _buildTemplateList() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderCardColor, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Существующие шаблоны',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: AppColors.textColorOne,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadingTemplates ? null : _loadTemplates,
                icon: const Icon(Icons.refresh, size: 18),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Expanded(
            child: _loadingTemplates
                ? const Center(child: CircularProgressIndicator())
                : _templates.isEmpty
                ? const Center(child: Text('Список пуст'))
                : ListView.separated(
                    itemCount: _templates.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: AppColors.borderCardColor),
                    itemBuilder: (_, i) {
                      final t = _templates[i];
                      return ListTile(
                        dense: true,
                        title: Text(
                          t.subjectTemplate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 13.sp),
                        ),
                        subtitle: Text(
                          t.stateName ?? '—',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: AppColors.hintTextColor,
                          ),
                        ),
                        leading: Icon(
                          Icons.circle,
                          size: 10,
                          color: t.isActive ? Colors.green : Colors.grey,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => _editTemplate(t),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () => _deleteTemplate(t),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
