import 'package:flutter_1/features/payment_methods/domain/repos/payments_repo.dart';
import 'package:flutter_1/features/payment_methods/presentation/cubits/payments_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  final PaymentsRepo paymentsRepo;

  PaymentsCubit({required this.paymentsRepo}) : super(PaymentsInitial());

  Future<void> loadObligationPayments(int obligationId) async {
    try {
      emit(PaymentsLoading());
      final payments = await paymentsRepo.getObligationPayments(obligationId);
      emit(PaymentsLoaded(payments));
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }
}
