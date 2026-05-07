import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/model_data_table_tiket/column_config.dart';

final String url = 'http://localhost:5000';

const prefKey = 'ticket_grid_columns';
const prefWidth = 'width';

List<ColumnConfig> defaultColumns(BuildContext context) => [
  ColumnConfig(columnName: 'id', label: 'ID', width: 20.w),
  ColumnConfig(columnName: 'title', label: 'Заголовок', width: 315.w),
  ColumnConfig(columnName: 'phone', label: 'Телефон', width: 150.w),
  ColumnConfig(columnName: 'bugNumber', label: 'Номер бага', width: 150.w),
  ColumnConfig(columnName: 'dataCreted', label: 'Дата создания', width: 134.w),
  ColumnConfig(
    columnName: 'dataModefire',
    label: 'Дата изменения',
    width: 122.w,
  ),
  ColumnConfig(columnName: 'userName', label: 'Пользователь', width: 150.w),
  ColumnConfig(columnName: 'workSpaceName', label: 'Воркспейс', width: 150.w),
  ColumnConfig(columnName: 'stateName', label: 'Статус', width: 106.w),
  ColumnConfig(columnName: 'typeTiketName', label: 'Тип тикета', width: 110.w),
  ColumnConfig(columnName: 'preorityName', label: 'Приоритет', width: 120.w),
  ColumnConfig(columnName: 'modeName', label: 'Режим', width: 110.w),
  ColumnConfig(
    columnName: 'subCategoryName',
    label: 'Подкатегория',
    width: 140.w,
  ),
  ColumnConfig(columnName: 'categoryName', label: 'Категория', width: 130.w),
  ColumnConfig(columnName: 'authorName', label: 'Автор', width: 114.w),
  ColumnConfig(columnName: 'platformName', label: 'Платформа', width: 120.w),
  ColumnConfig(columnName: 'companyName', label: 'Компания', width: 130.w),
  ColumnConfig(columnName: 'dueDate', label: 'Дедлайн', width: 130.w),
];
