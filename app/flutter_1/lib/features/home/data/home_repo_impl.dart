import 'package:flutter_1/features/home/domain/repos/home_repo.dart';
import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';

class HomeRepoImpl extends HomeRepo {
  // TODO: inject ApiClient

  @override
  Future<List<ObligationModel>> getDashboardObligations(int userId) => throw UnimplementedError();
}
