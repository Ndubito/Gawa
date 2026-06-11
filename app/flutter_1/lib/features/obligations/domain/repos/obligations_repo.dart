import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';

abstract class ObligationsRepo {
  Future<ObligationModel> createObligation(ObligationModel obligation);
  Future<ObligationModel> getObligation(int obligationId);
  Future<List<ObligationModel>> getUserObligations(int userId);
  Future<List<ObligationModel>> getUserReceivables(int userId);
  Future<ObligationModel> updateObligation(int obligationId, ObligationModel obligation);
}
