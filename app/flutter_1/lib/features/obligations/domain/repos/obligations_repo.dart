import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';

/// Bills are created by the backend (subscription cycles and expenses) and
/// are read-only here until the pay flow exists.
abstract class ObligationsRepo {
  /// Every open bill the signed-in user owes or is owed, plus ones settled
  /// in the last 90 days.
  Future<List<ObligationModel>> getMyBills();
}
