import 'package:flutter_1/features/obligations/domain/repos/obligations_repo.dart';
import 'package:flutter_1/features/obligations/presentation/cubits/obligations_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ObligationsCubit extends Cubit<ObligationsState> {
  final ObligationsRepo obligationsRepo;

  ObligationsCubit({required this.obligationsRepo}) : super(ObligationsInitial());

  Future<void> loadUserObligations(int userId) async {
    try {
      emit(ObligationsLoading());
      final obligations = await obligationsRepo.getUserObligations(userId);
      emit(ObligationsLoaded(obligations));
    } catch (e) {
      emit(ObligationsError(e.toString()));
    }
  }
}
