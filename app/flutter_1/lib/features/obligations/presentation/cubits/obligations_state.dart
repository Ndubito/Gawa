import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';

abstract class ObligationsState {}

class ObligationsInitial extends ObligationsState {}

class ObligationsLoading extends ObligationsState {}

class ObligationsLoaded extends ObligationsState {
  final List<ObligationModel> obligations;
  ObligationsLoaded(this.obligations);
}

class ObligationsError extends ObligationsState {
  final String message;
  ObligationsError(this.message);
}
