import 'package:flutter_1/features/activity/domain/repos/activity_repo.dart';
import 'package:flutter_1/features/activity/presentation/cubits/activity_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final ActivityRepo activityRepo;

  ActivityCubit({required this.activityRepo}) : super(ActivityInitial());

  Future<void> loadPaymentTransactions(int paymentId) async {
    try {
      emit(ActivityLoading());
      final transactions = await activityRepo.getPaymentTransactions(paymentId);
      emit(ActivityLoaded(transactions));
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }
}
