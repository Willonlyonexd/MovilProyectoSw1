class Usuario {
  final String usuarioId;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final String username;
  final bool estado;
  final List<RolSimple>? roles;
  final String? createdAt;

  Usuario({
    required this.usuarioId,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    required this.username,
    required this.estado,
    this.roles,
    this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    List<RolSimple>? rolesList;
    
    if (json['roles'] != null) {
      rolesList = (json['roles'] as List)
          .map((rol) => RolSimple.fromJson(rol))
          .toList();
    }
    
    return Usuario(
      usuarioId: json['usuarioId'],
      nombre: json['nombre'],
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'],
      username: json['username'],
      estado: json['estado'] ?? false,
      roles: rolesList,
      createdAt: json['createdAt'],
    );
  }
}

class RolSimple {
  final String rolId;
  final String nombre;
  final bool estado;

  RolSimple({
    required this.rolId,
    required this.nombre,
    required this.estado,
  });

  factory RolSimple.fromJson(Map<String, dynamic> json) {
    return RolSimple(
      rolId: json['rolId'],
      nombre: json['nombre'],
      estado: json['estado'] ?? false,
    );
  }
}