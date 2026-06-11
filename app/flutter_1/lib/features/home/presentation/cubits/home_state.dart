import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ObligationModel> obligations;
  HomeLoaded(this.obligations);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
