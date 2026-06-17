import '../../models/dictionary_item_model.dart';
import '../../services/dictionary_service.dart';

class DictionariesRepository {
  static final DictionariesRepository _instance = DictionariesRepository._internal();
  factory DictionariesRepository() => _instance;
  DictionariesRepository._internal();

  List<DictionaryItem> _tiketType = [];
  List<DictionaryItem> _tiketState = [];
  List<DictionaryItem> _tiketPreority = [];
  List<DictionaryItem> _tiketMode = [];
  List<DictionaryItem> _tiketCategory = [];
  List<DictionaryItem> _tiketWorkSpace = [];

  bool _isLoaded = false;
  Future<void>? _loadingFuture;

  Future<void> loadAll({required String apiKey}) async {
    if (_isLoaded) return;
    if (_loadingFuture != null) return _loadingFuture;
    _loadingFuture = _doLoad(apiKey);
    await _loadingFuture;
  }

  Future<void> _doLoad(String apiKey) async {
    final service = DictionaryService();
    final result = await service.getAllDictionaries(apiKey: apiKey);

    _tiketType = result.tiketType;
    _tiketState = result.tiketState;
    _tiketPreority = result.tiketPreority;
    _tiketMode = result.tiketMode;
    _tiketCategory = result.tiketCategory;
    _tiketWorkSpace = result.tiketWorkSpace;

    _isLoaded = true;
  }

  List<DictionaryItem> get tiketType => _tiketType;
  List<DictionaryItem> get tiketState => _tiketState;
  List<DictionaryItem> get tiketPreority => _tiketPreority;
  List<DictionaryItem> get tiketMode => _tiketMode;
  List<DictionaryItem> get tiketCategory => _tiketCategory;
  List<DictionaryItem> get tiketWorkSpace => _tiketWorkSpace;

  Future<void> refresh({required String apiKey}) async {
    _isLoaded = false;
    _loadingFuture = null;
    await loadAll(apiKey: apiKey);
  }
}