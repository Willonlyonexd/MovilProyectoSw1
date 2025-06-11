import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'env_config.dart';
import 'dart:async';

final FlutterSecureStorage _storage = FlutterSecureStorage();

GraphQLClient getGraphQLClient() {
  final httpLink = HttpLink(EnvConfig.graphqlUrl);

  final authLink = AuthLink(
    getToken: () async {
      final token = await _storage.read(key: "token");
      return token != null ? "Bearer $token" : null;
    },
  );

  // Implementación correcta del tenantHeaderLink
  final tenantHeaderLink = Link.function((request, [forward]) {
    // Crear un StreamController para manejar la respuesta
    final controller = StreamController<Response>();
    
    // Proceso asíncrono para obtener el tenantId y actualizar headers
    Future<void> handle() async {
      try {
        final tenantId = await _storage.read(key: "tenantId") ?? "1";
        
        // Actualizar los headers con el tenantId
        final req = request.updateContextEntry<HttpLinkHeaders>(
          (headers) => HttpLinkHeaders(
            headers: {
              ...?headers?.headers,
              "X-Tenant-ID": tenantId,
            },
          ),
        );
        
        // Continuar con el flujo
        if (forward != null) {
          await forward(req).forEach(controller.add)
              .then((_) => controller.close())
              .catchError(controller.addError);
        } else {
          controller.close();
        }
      } catch (e) {
        controller.addError(e);
      }
    }
    
    // Iniciar el proceso sin esperar
    handle();
    
    // Retornamos el stream inmediatamente
    return controller.stream;
  });

  final link = tenantHeaderLink.concat(authLink).concat(httpLink);

  return GraphQLClient(
    cache: GraphQLCache(
      store: InMemoryStore(),
      partialDataPolicy: PartialDataCachePolicy.reject,
    ),
    link: link,
    defaultPolicies: DefaultPolicies(
      query: Policies(
        fetch: FetchPolicy.networkOnly, // Siempre obtener datos frescos
      ),
      mutate: Policies(
        fetch: FetchPolicy.networkOnly, // Para mutaciones, siempre ir a la red
      ),
    ),
  );
}

// Función para limpiar la caché de GraphQL
void limpiarCacheGraphQL() {
  try {
    final client = getGraphQLClient();
    client.cache.store.reset();
    debugPrint('🧹 Caché de GraphQL limpiada correctamente');
  } catch (e) {
    debugPrint('❌ Error limpiando caché de GraphQL: $e');
  }
}