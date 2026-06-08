import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _repository;

  LoginUsecase(this._repository);

  /// Ejecuta el login y persiste token + timeout en almacén encriptado.
  /// [timeoutSeconds] está fijo en [kInactivitySeconds] — no lo elige el usuario.
  Future<User> call({
    required String email,
    required String password,
    int timeoutSeconds = 20,
  }) async {
    final user = await _repository.login(email, password);
    await _repository.saveSession(
      token: user.token,
      timeoutSeconds: timeoutSeconds,
    );
    return user;
  }
}