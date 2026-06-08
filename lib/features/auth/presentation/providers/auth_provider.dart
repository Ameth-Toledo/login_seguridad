import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../../../core/network/http.dart';

// ─── Constante de inactividad ─────────────────────────────────────────────────

/// Segundos de inactividad para cerrar sesión automáticamente.
/// El timer NO arranca al hacer login — arranca con la primera
/// interacción del usuario dentro de la app.
const kInactivitySeconds = 20;

// ─── Estado ──────────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  /// Segundos restantes. -1 = timer aún no ha arrancado (usuario no ha interactuado).
  final int remainingSeconds;

  /// True cuando el usuario ya interactuó al menos una vez y el timer está activo.
  final bool timerActive;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.remainingSeconds = -1,
    this.timerActive = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    int? remainingSeconds,
    bool? timerActive,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        errorMessage: errorMessage ?? this.errorMessage,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        timerActive: timerActive ?? this.timerActive,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;
  final AuthRepository _repository;

  Timer? _inactivityTimer;
  Timer? _countdownTimer;

  AuthNotifier(this._loginUsecase, this._repository) : super(const AuthState());

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _loginUsecase(
        email: email,
        password: password,
        timeoutSeconds: kInactivitySeconds,
      );
      // Timer NO arranca aquí. remainingSeconds = -1 (inactivo).
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        remainingSeconds: -1,
        timerActive: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ── Registro ───────────────────────────────────────────────────────────────

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.register(nombre: nombre, email: email, password: password);
      await login(email: email, password: password);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _cancelTimers();
    await _repository.clearSession();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  // ── Timer de inactividad ───────────────────────────────────────────────────

  /// Llamado por el GestureDetector global en cada interacción del usuario.
  /// - Si el timer aún no ha arrancado (primera interacción), lo inicia.
  /// - Si ya estaba activo, lo reinicia desde 20s.
  void onUserInteraction() {
    if (state.status != AuthStatus.authenticated) return;
    _startTimers();
  }

  void _startTimers() {
    _cancelTimers();

    state = state.copyWith(
      remainingSeconds: kInactivitySeconds,
      timerActive: true,
    );

    // Countdown visual — tick cada segundo
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.remainingSeconds - 1;
      state = state.copyWith(remainingSeconds: next < 0 ? 0 : next);
    });

    // Timer principal — cierra sesión al agotarse
    _inactivityTimer = Timer(
      const Duration(seconds: kInactivitySeconds),
          () {
        _cancelTimers();
        logout();
      },
    );
  }

  void _cancelTimers() {
    _inactivityTimer?.cancel();
    _countdownTimer?.cancel();
    _inactivityTimer = null;
    _countdownTimer = null;
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final _secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final _httpClientProvider = Provider<HttpClient>((ref) => HttpClient());

final _remoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(ref.read(_httpClientProvider));
});

final _authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(_remoteDatasourceProvider),
    ref.read(_secureStorageProvider),
  );
});

final _loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.read(_authRepositoryProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(_loginUsecaseProvider),
    ref.read(_authRepositoryProvider),
  );
});