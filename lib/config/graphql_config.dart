  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  import 'package:graphql_flutter/graphql_flutter.dart';
  import 'env_config.dart';

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  GraphQLClient getGraphQLClient() {
    final httpLink = HttpLink(EnvConfig.graphqlUrl);

    final authLink = AuthLink(
      getToken: () async {
        final token = await _storage.read(key: "token");
        return token != null ? "Bearer $token" : null;
      },
    );

    // 🔸 Asegura que X-Tenant-ID esté siempre presente
    final tenantHeaderLink = Link.function(
      (request, [next]) {
        request.updateContextEntry<HttpLinkHeaders>(
          (headers) => HttpLinkHeaders(
            headers: {
              ...?headers?.headers,
              "X-Tenant-ID": "1", // <-- aquí puedes reemplazar con lógica dinámica si lo necesitas
            },
          ),
        );
        return next!(request);
      },
    );

    final link = tenantHeaderLink.concat(authLink).concat(httpLink);

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );
  }
