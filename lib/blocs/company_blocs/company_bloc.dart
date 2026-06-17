import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/company_model.dart';

import '../../data_base/user_repository.dart';
import '../../services/client_service.dart';

part 'company_event.dart';
part 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final userRepository = UserRepository();
  final companyService = ClientService();
  CompanyBloc() : super(CompanyInitial()) {
    on<FeatCompanyEvent>(_loadCompany);
  }

  Future<void>_loadCompany(FeatCompanyEvent event, Emitter<CompanyState> emit)async{
    emit(CompanyLoading());
    try{
      final savedUser = await userRepository.getUser();
      final apiKey = savedUser?.apiKey ?? '';
      final companyList = await companyService.getCompany(apiKey: apiKey);
      emit(CompanyLoaded(companyList));
    }catch(e){
      emit(CompanyError(e.toString()));
    }
  }
}
