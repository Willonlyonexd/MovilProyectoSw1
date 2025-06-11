class Cliente {
  final int clienteId;
  final String nombre;
  final String username;

  Cliente({
    required this.clienteId,
    required this.nombre,
    required this.username,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      clienteId: int.parse(json['clienteId'].toString()),
      nombre: json['nombre'],
      username: json['username'],
    );
  }
}
