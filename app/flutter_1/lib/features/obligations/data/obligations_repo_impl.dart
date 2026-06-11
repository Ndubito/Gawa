import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';
import 'package:flutter_1/features/obligations/domain/repos/obligations_repo.dart';

class ObligationsRepoImpl extends ObligationsRepo {
  // TODO: inject ApiClient

  @override
  Future<ObligationModel> createObligation(ObligationModel obligation) => throw UnimplementedError();

  @override
  Future<ObligationModel> getObligation(int obligationId) => throw UnimplementedError();

  @override
  Future<List<ObligationModel>> getUserObligations(int userId) => throw UnimplementedError();

  @override
  Future<List<ObligationModel>> getUserReceivables(int userId) => throw UnimplementedError();

  @override
  Future<ObligationModel> updateObligation(int obligationId, ObligationModel obligation) => throw UnimplementedError();
}
