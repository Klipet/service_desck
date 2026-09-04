import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';
import 'package:service_desk/screens/widgets/bordered_form_field.dart';

/// Показывает диалог редактирования названия записи, возвращает новое имя
/// или null если отменили / не изменили.
Future<String?> showRenameDialog(
  BuildContext context, {
  required String title,
  required String initialName,
}) {
  final controller = TextEditingController(text: initialName);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      content: BorderedFormField(
        controller: controller,
        hint: 'Название',
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        TextButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isEmpty) return;
            Navigator.pop(ctx, value);
          },
          child: const Text('Сохранить'),
        ),
      ],
    ),
  );
}

/// Список уже созданных записей справочника с кнопкой редактирования.
/// Ничего не знает про bloc/service — только рендер + колбэки.
class SimpleEditableList extends StatelessWidget {
  final List<SimpleDictionaryModel> items;
  final bool loading;
  final VoidCallback onRefresh;
  final void Function(SimpleDictionaryModel item) onEdit;

  const SimpleEditableList({
    super.key,
    required this.items,
    required this.loading,
    required this.onRefresh,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
                'Существующие записи',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: AppColors.textColorOne,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: loading ? null : onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) return const Center(child: Text('Список пуст'));

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderCardColor),
      itemBuilder: (_, i) {
        final item = items[i];
        return ListTile(
          dense: true,
          title: Text(item.name, style: GoogleFonts.poppins(fontSize: 13.sp)),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () => onEdit(item),
          ),
        );
      },
    );
  }
}
