import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:service_desk/data_base/user_repository.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';

import '../../../blocs/ticket_state_blocs/ticket_state_bloc.dart';
import 'widgets/simple_create_form.dart';
import 'widgets/simple_editable_list.dart';

class TicketStateCreateTab extends StatelessWidget {
  const TicketStateCreateTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TicketStateBloc(),
      child: const _TicketStateCreateTabBody(),
    );
  }
}

class _TicketStateCreateTabBody extends StatefulWidget {
  const _TicketStateCreateTabBody();

  @override
  State<_TicketStateCreateTabBody> createState() => _TicketStateCreateTabBodyState();
}

class _TicketStateCreateTabBodyState extends State<_TicketStateCreateTabBody> {
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
    context.read<TicketStateBloc>().add(LoadAllTicketStatesEvent(_apiKey));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    context.read<TicketStateBloc>().add(
      CreateTicketStateEvent(apiKey: _apiKey, name: _nameController.text.trim()),
    );
  }

  Future<void> _editItem(SimpleDictionaryModel item) async {
    final newName = await showRenameDialog(
      context,
      title: 'Редактирование статуса заявки',
      initialName: item.name,
    );
    if (newName == null || !mounted) return;
    context.read<TicketStateBloc>().add(
      UpdateTicketStateEvent(
        apiKey: _apiKey,
        state: SimpleDictionaryModel(
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
    return BlocListener<TicketStateBloc, TicketStateState>(
      listener: (context, state) {
        if (state is TicketStateCreated) {
          setState(() => _saving = false);
          _nameController.clear();
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Статус создан')));
          _load();
        } else if (state is TicketStateUpdated) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Изменения сохранены')));
          _load();
        } else if (state is TicketStatesLoaded) {
          setState(() {
            _items = state.states;
            _loadingList = false;
          });
        } else if (state is TicketStateError) {
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
            title: 'Новый статус заявки',
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
