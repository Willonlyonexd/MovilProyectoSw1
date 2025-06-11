class AuthQueries {
  static String get loginCliente => '''
    mutation LoginCliente(\$username: String!, \$password: String!) {
      loginCliente(username: \$username, password: \$password) {
        token
        cliente {
          clienteId
          nombre
          apellido
          username
          email
          telefono
        }
      }
    }
  ''';

  static String get login => '''
    mutation Login(\$username: String!, \$password: String!) {
      login(username: \$username, password: \$password) {
        token
        usuario {
          usuarioId
          nombre
          apellido
          username
          email
          telefono
          roles {
            nombre
          }
        }
      }
    }
  ''';
}