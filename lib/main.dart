import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart'; // Añadir esta importación
import 'package:graphql_flutter/graphql_flutter.dart'; // Añadir si usas GraphQL
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive para GraphQL (si lo usas)
  // await initHiveForFlutter();
  
  // Inicializar datos de localización para español
  
    await initializeDateFormatting();

  runApp(const ProviderScope(child: MyApp()));
}