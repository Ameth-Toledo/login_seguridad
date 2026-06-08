import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Claves usadas en el almacén encriptado.
class _Keys {
  static const token = 'auth_token';
  static const timeoutSeconds = 'auth_timeout_seconds';
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<User> login(String email, String password) =>
      _remote.login(email, password);

  @override
  Future<void> register({
    required String nombre,
    required String email,
    required String password,
  }) =>
      _remote.register(nombre: nombre, email: email, password: password);

  @override
  Future<void> saveSession({
    required String token,
    required int timeoutSeconds,
  }) async {
    // flutter_secure_storage usa AES-256 en Android (Keystore) e iOS (Keychain).
    await _storage.write(key: _Keys.token, value: token);
    await _storage.write(
        key: _Keys.timeoutSeconds, value: timeoutSeconds.toString());
  }

  @override
  Future<String?> getToken() => _storage.read(key: _Keys.token);

  @override
  Future<int?> getTimeout() async {
    final raw = await _storage.read(key: _Keys.timeoutSeconds);
    return raw != null ? int.tryParse(raw) : null;
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _Keys.token);
    await _storage.delete(key: _Keys.timeoutSeconds);
  }
}