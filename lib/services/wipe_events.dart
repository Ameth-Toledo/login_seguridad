import 'dart:async';

/// Stream global que emite un evento cada vez que se ejecuta un remote wipe.
/// Usado para que la UI reaccione en foreground sin pasar por Riverpod.
final wipeEventStream = StreamController<void>.broadcast();
