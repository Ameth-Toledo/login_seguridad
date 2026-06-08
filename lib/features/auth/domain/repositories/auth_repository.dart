import '../entities/user.dart';

abstract class AuthRepository {
  /// Autentica al usuario contra el backend y devuelve la entidad [User].
  Future<User> login(String email, String password);

  /// Registra un nuevo usuario en el backend.
  Future<void> register({
    required String nombre,
    required String email,
    required String password,
  });

  /// Persiste el token y el timeout (en segundos) en almacén encriptado.
  Future<void> saveSession({
    required String token,
    required int timeoutSeconds,
  });

  /// Recupera el token del almacén encriptado. Null si no hay sesión.
  Future<String?> getToken();

  /// Recupera el timeout guardado (en segundos). Null si no hay sesión.
  Future<int?> getTimeout();

  /// Elimina token y timeout del almacén encriptado (cierre de sesión).
  Future<void> clearSession();
}