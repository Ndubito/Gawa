import 'package:flutter_1/features/obligations/domain/repos/obligations_repo.dart';
import 'package:flutter_1/features/obligations/presentation/cubits/obligations_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App-wide: both the Home summary and the Bills tab read the same bills.
class ObligationsCubit extends Cubit<ObligationsState> {
  final ObligationsRepo obligationsRepo;

  ObligationsCubit({required this.obligationsRepo})
    : super(ObligationsInitial());

  Future<void> loadBills() async {
    try {
      // Keep showing the current list while refreshing
      if (state is! ObligationsLoaded) emit(ObligationsLoading());
      final bills = await obligationsRepo.getMyBills();
      emit(ObligationsLoaded(bills));
    } catch (e) {
      emit(ObligationsError(e.toString()));
    }
  }
}
