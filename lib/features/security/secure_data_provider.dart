import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/secure_storage_service.dart';

/// Provider que expone el contenido actual del almacén seguro
/// (`SecureStorageService.readAll()`) como un `FutureProvider`.
///
/// `HomePage` lo observa con `ref.watch(secureDataProvider)` para
/// mostrar los campos sensibles (Auth Token, Password Hash,
/// Credit Card, Session ID, User ID) y reaccionar a sus estados
/// `loading` / `data` / `error`.
///
/// Cuando ocurre un remote wipe (ver `wipe_events.dart`), se debe
/// invalidar este provider para que vuelva a leer el storage y la
/// UI refleje que los datos ya no existen. Para eso se usa
/// `refreshSecureData(ref)`.
final secureDataProvider = FutureProvider<Map<String, String?>>((ref) async {
  return SecureStorageService.readAll();
});

/// Fuerza una relectura del almacén seguro, invalidando el provider.
///
/// Se llama típicamente desde el listener de `wipeEventStream`:
///
/// ```dart
/// _wipeSub = wipeEventStream.stream.listen((_) {
///   if (mounted) refreshSecureData(ref);
/// });
/// ```
///
/// `ref.invalidate` marca el provider como obsoleto; en la siguiente
/// lectura (`ref.watch`/`ref.read`) Riverpod vuelve a ejecutar el
/// `FutureProvider` y obtiene el estado actualizado del storage
/// (que tras un wipe exitoso devolverá valores `null` en los campos
/// sensibles eliminados).
void refreshSecureData(WidgetRef ref) {
  ref.invalidate(secureDataProvider);
}