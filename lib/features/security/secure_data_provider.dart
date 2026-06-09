import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/secure_storage_service.dart';

// Contador que fuerza re-lectura del storage cuando se incrementa.
final _secureDataGenProvider = StateProvider<int>((ref) => 0);

/// Expone los campos sensibles del almacén encriptado.
/// Se refresca llamando a [refreshSecureData].
final secureDataProvider = FutureProvider<Map<String, String?>>((ref) {
  ref.watch(_secureDataGenProvider);
  return SecureStorageService.readAll();
});

/// Llama esto desde cualquier widget para forzar re-lectura del storage.
void refreshSecureData(WidgetRef ref) =>
    ref.read(_secureDataGenProvider.notifier).update((s) => s + 1);
