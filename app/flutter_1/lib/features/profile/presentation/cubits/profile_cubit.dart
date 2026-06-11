import 'package:flutter_1/features/profile/domain/repos/profile_repo.dart';
import 'package:flutter_1/features/profile/presentation/cubits/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(ProfileInitial());

  Future<void> loadProfile(int userId) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.getProfile(userId);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
