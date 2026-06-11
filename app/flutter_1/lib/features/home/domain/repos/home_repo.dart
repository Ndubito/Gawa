import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';

abstract class HomeRepo {
  /// Fetches the upcoming and overdue obligations for the current user's dashboard.
  Future<List<ObligationModel>> getDashboardObligations(int userId);
}
