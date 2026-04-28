class ColumnConfig {
  final String columnName;
  final String label;
  final double width;
  bool visible;

  ColumnConfig({
    required this.columnName,
    required this.label,
    required this.width,
    this.visible = true,
  });
}