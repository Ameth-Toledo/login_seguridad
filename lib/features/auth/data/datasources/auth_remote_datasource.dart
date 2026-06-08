import '../../../../core/network/http.dart';
import '../../domain/entities/user.dart';

class AuthRemoteDatasource {
  final HttpClient _http;

  AuthRemoteDatasource(this._http);

  /// POST /api/auth/login
  Future<User> login(String email, String password) async {
    final data = await _http.post(
      '/api/auth/login',
      {'email': email, 'password': password},
    );
    return User(
      id: data['usuario_id'] as int,
      nombre: data['nombre'] as String,
      token: data['token'] as String,
    );
  }

  /// POST /api/auth/register
  Future<void> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    await _http.post(
      '/api/auth/register',
      {'nombre': nombre, 'email': email, 'password': password},
    );
  }
}