import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/models/singUp.dart';
import 'package:marine_analytics_platform/data/repositories/user_profile_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserProfileRepository _userProfileRepository;
  RegisterBloc({UserProfileRepository? userProfileRepository})
      : _userProfileRepository = userProfileRepository ?? UserProfileRepository(),
        super(const RegisterState()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(status: Status.loading, message: null));
    try {
      final message = await _userProfileRepository.signUp(singUp: event.singUp);
      emit(state.copyWith(status: Status.success, message: message));
    } on RegisterException catch (e) {
      emit(state.copyWith(status: Status.fail, message: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.fail, message: 'Registration failed: $e'));
    }
  }
}
