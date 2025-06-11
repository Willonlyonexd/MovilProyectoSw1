class Cliente {
  final String clienteId;
  final String nombre;
  final String apellido;
  final String? email;
  final String? telefono;
  final String username;
  final String? direccion;
  final String? fechaNacimiento;
  final bool estado; // Cambiado a no-nullable

  Cliente({
    required this.clienteId,
    required this.nombre,
    required this.apellido,
    this.email,
    this.telefono,
    required this.username,
    this.direccion,
    this.fechaNacimiento,
    this.estado = true, // Valor predeterminado
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      clienteId: json['clienteId']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      email: json['email']?.toString(),
      telefono: json['telefono']?.toString(),
      username: json['username']?.toString() ?? '',
      direccion: json['direccion']?.toString(),
      fechaNacimiento: json['fechaNacimiento']?.toString(),
      estado: json['estado'] == true, // Conversión segura
    );
  }

  factory Cliente.empty() {
    return Cliente(
      clienteId: '0',
      nombre: '',
      apellido: '',
      username: '',
      estado: false,
    );
  }
}