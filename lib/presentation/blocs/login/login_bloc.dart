import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/repositories/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({AuthRepository? repository})
      : _authRepository = repository ?? AuthRepository(),
        super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: Status.loading, message: null));
    try {
      final message = await _authRepository.signIn(email: event.email, password: event.password);
      emit(state.copyWith(status: Status.success, message: message));
    } on LoginFailure catch (e) {
      emit(state.copyWith(status: Status.fail, message: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.fail, message: 'Login failed: $e'));
    }
  }
}

