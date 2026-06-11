import 'package:flutter_1/features/home/domain/repos/home_repo.dart';
import 'package:flutter_1/features/home/presentation/cubits/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo homeRepo;

  HomeCubit({required this.homeRepo}) : super(HomeInitial());

  Future<void> loadDashboard(int userId) async {
    try {
      emit(HomeLoading());
      final obligations = await homeRepo.getDashboardObligations(userId);
      emit(HomeLoaded(obligations));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
