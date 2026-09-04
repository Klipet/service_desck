import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:service_desk/data_base/user_repository.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';

import '../../../blocs/tiket_type_blocs/tiket_type_bloc.dart';
import 'widgets/simple_create_form.dart';
import 'widgets/simple_editable_list.dart';

class TiketTypeCreateTab extends StatelessWidget {
  const TiketTypeCreateTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TiketTypeBloc(),
      child: const _TiketTypeCreateTabBody(),
    );
  }
}

class _TiketTypeCreateTabBody extends StatefulWidget {
  const _TiketTypeCreateTabBody();

  @override
  State<_TiketTypeCreateTabBody> createState() => _TiketTypeCreateTabBodyState();
}

class _TiketTypeCreateTabBodyState extends State<_TiketTypeCreateTabBody> {
  final _userRepo = UserRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _apiKey = '';
  bool _saving = false;
  bool _loadingList = true;
  List<SimpleDictionaryModel> _items = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final apiKey = await _userRepo.getUserApikey();
    if (!mounted) return;
    setState(() => _apiKey = apiKey ?? '');
    _load();
  }

  void _load() {
    setState(() => _loadingList = true);
    context.read<TiketTypeBloc>().add(LoadAllTiketTypesEvent(_apiKey));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    context.read<TiketTypeBloc>().add(
      CreateTiketTypeEvent(apiKey: _apiKey, name: _nameController.text.trim()),
    );
  }

  Future<void> _editItem(SimpleDictionaryModel item) async {
    final newName = await showRenameDialog(
      context,
      title: 'Редактирование типа заявки',
      initialName: item.name,
    );
    if (newName == null || !mounted) return;
    context.read<TiketTypeBloc>().add(
      UpdateTiketTypeEvent(
        apiKey: _apiKey,
        tiketType: SimpleDictionaryModel(
          oid: item.oid,
          name: newName,
          active: item.active,
          dateCreated: item.dateCreated,
          dateModifire: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TiketTypeBloc, TiketTypeState>(
      listener: (context, state) {
        if (state is TiketTypeCreated) {
          setState(() => _saving = false);
          _nameController.clear();
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Тип заявки создан')));
          _load();
        } else if (state is TiketTypeUpdated) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Изменения сохранены')));
          _load();
        } else if (state is TiketTypesLoaded) {
          setState(() {
            _items = state.tiketTypes;
            _loadingList = false;
          });
        } else if (state is TiketTypeError) {
          setState(() {
            _saving = false;
            _loadingList = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка: ${state.message}')));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SimpleCreateForm(
            title: 'Новый тип заявки',
            fieldLabel: 'Название',
            formKey: _formKey,
            controller: _nameController,
            saving: _saving,
            onSubmit: _submit,
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: SimpleEditableList(
              items: _items,
              loading: _loadingList,
              onRefresh: _load,
              onEdit: _editItem,
            ),
          ),
        ],
      ),
    );
  }
}
