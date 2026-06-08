class User {
  final int id;
  final String nombre;
  final String token;

  const User({
    required this.id,
    required this.nombre,
    required this.token,
  });

  @override
  String toString() => 'User(id: $id, nombre: $nombre)';
}