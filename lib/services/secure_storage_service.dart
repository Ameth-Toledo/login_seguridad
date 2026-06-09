import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Claves de los campos sensibles
  static const keyToken      = 'auth_token';
  static const keyPassword   = 'user_password_hash';
  static const keyCreditCard = 'credit_card_number';
  static const keySessionId  = 'session_id';
  static const keyUserId     = 'active_user_id';
  static const keyFcmToken   = 'fcm_token';

  /// Guarda los 5 campos sensibles de una sola vez tras el login.
  static Future<void> saveAllSensitiveData({
    required String userId,
    required String token,
    required String passwordHash,
    required String creditCard,
    required String sessionId,
  }) async {
    await Future.wait([
      _storage.write(key: keyUserId,     value: userId),
      _storage.write(key: keyToken,      value: token),
      _storage.write(key: keyPassword,   value: passwordHash),
      _storage.write(key: keyCreditCard, value: creditCard),
      _storage.write(key: keySessionId,  value: sessionId),
    ]);
  }

  static Future<void> saveFcmToken(String token) =>
      _storage.write(key: keyFcmToken, value: token);

  static Future<String?> read(String key) => _storage.read(key: key);

  /// Lee los 4 campos sensibles visibles + userId para mostrar en la UI.
  static Future<Map<String, String?>> readAll() async {
    final results = await Future.wait([
      _storage.read(key: keyToken),
      _storage.read(key: keyPassword),
      _storage.read(key: keyCreditCard),
      _storage.read(key: keySessionId),
      _storage.read(key: keyUserId),
    ]);
    return {
      'Auth Token':    results[0],
      'Password Hash': results[1],
      'Credit Card':   results[2],
      'Session ID':    results[3],
      'User ID':       results[4],
    };
  }

  /// Elimina todos los datos sin verificación (logout, etc.).
  static Future<void> wipeAllSensitiveData() => _storage.deleteAll();

  /// Elimina datos SOLO si el target_user_id coincide con el userId almacenado.
  /// Retorna true si se realizó el wipe, false si no coincidió.
  static Future<bool> wipeIfTargetMatches(String targetUserId) async {
    final storedId = await _storage.read(key: keyUserId);
    if (storedId == null || storedId != targetUserId) return false;
    await _storage.deleteAll();
    return true;
  }
}
