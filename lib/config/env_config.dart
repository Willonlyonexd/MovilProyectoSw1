class EnvConfig {
  // Cambia esta URL cuando lo despliegues
  static const String graphqlUrl = String.fromEnvironment(
    'GRAPHQL_URL',
    defaultValue: 'http://10.0.2.2:8080/graphql'
  );
}
