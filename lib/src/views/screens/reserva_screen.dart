import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:reproductor_colaborativo_sw1/config/graphql_config.dart';
import 'package:reproductor_colaborativo_sw1/providers/reserva_provider.dart';
import 'package:reproductor_colaborativo_sw1/services/user_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../providers/auth_provider.dart';

class ReservaScreen extends ConsumerStatefulWidget {
  const ReservaScreen({super.key});

  @override
  ConsumerState<ReservaScreen> createState() => _ReservaScreenState();
}

class _ReservaScreenState extends ConsumerState<ReservaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  bool _isLoadingMesas = true;
  bool _showDisponibilidad = false;
  String _errorMessage = '';

  int? cantidadPersonas;
  DateTime? fechaReserva;
  TimeOfDay? horaReserva;
  String? observaciones;
  int? mesaId;
  List<Map<String, dynamic>> _mesas = [];

  // Para visualizar disponibilidad de mesas
  List<Map<String, dynamic>> _mesasDisponibles = [];
  List<Map<String, dynamic>> _mesasOcupadas = [];

  @override
  void initState() {
    super.initState();
    // Establecer fecha y hora predeterminadas
    fechaReserva = DateTime.now().add(const Duration(days: 1));
    horaReserva = const TimeOfDay(hour: 19, minute: 0);
    
    // Log de inicio
    debugPrint('🔍 ReservaScreen: Iniciando con fecha ${fechaReserva.toString()} y hora ${horaReserva.toString()}');
    
    // Cargar mesas disponibles
    _cargarMesas();
  }

  Future<void> _cargarMesas() async {
    setState(() {
      _isLoadingMesas = true;
      _errorMessage = '';
    });
    
    try {
      final client = getGraphQLClient();
      final tenantId = await _secureStorage.read(key: 'tenantId') ?? '1';
      
      debugPrint('🔍 ReservaScreen: Cargando mesas para tenant: $tenantId');
      
      final result = await client.query(QueryOptions(
        document: gql('''
          query GetMesas(\$tenantId: ID!) {
            mesasByTenantId(tenantId: \$tenantId) {
              mesaId
              numero
              capacidad
              estado
            }
          }
        '''),
        variables: {
          'tenantId': tenantId,
        },
        fetchPolicy: FetchPolicy.noCache, // Evitar caché para datos frescos
      ));
      
      if (result.hasException) {
        debugPrint('❌ ReservaScreen: Error en consulta GraphQL: ${result.exception.toString()}');
        throw Exception(result.exception.toString());
      }
      
      // Verificar que los datos existen
      if (result.data == null || result.data!['mesasByTenantId'] == null) {
        debugPrint('❌ ReservaScreen: Respuesta GraphQL sin datos de mesas');
        throw Exception('No se recibieron datos de mesas');
      }
      
      final mesasData = result.data!['mesasByTenantId'] as List<dynamic>;
      debugPrint('✅ ReservaScreen: Se encontraron ${mesasData.length} mesas');
      
      // Procesar y mapear de forma segura los datos de mesas
      _mesas = mesasData.map((mesa) {
        // Registrar datos crudos para depuración
        debugPrint('🔍 Mesa raw data: ${mesa.toString()}');
        
        // Extraer valores con manejo seguro
        final mesaId = mesa['mesaId']?.toString() ?? '';
        final numero = int.tryParse(mesa['numero']?.toString() ?? '0') ?? 0;
        final capacidad = int.tryParse(mesa['capacidad']?.toString() ?? '0') ?? 0;
        final estado = mesa['estado'] == true;
        
        debugPrint('📊 Mesa procesada: ID=$mesaId, Número=$numero, Capacidad=$capacidad, Estado=$estado');
        
        return {
          'mesa_id': mesaId,
          'numero': numero,
          'capacidad': capacidad,
          'estado': estado,
        };
      }).toList();
      
      // Ordenar mesas por número
      _mesas.sort((a, b) => (a['numero'] as int).compareTo(b['numero'] as int));
      
      debugPrint('✅ ReservaScreen: Mesas cargadas y ordenadas correctamente');
      
    } catch (e) {
      debugPrint('❌ ReservaScreen: Error al cargar mesas: ${e.toString()}');
      setState(() {
        _errorMessage = 'Error al cargar mesas: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMesas = false;
        });
      }
    }
  }

  Future<void> _verificarDisponibilidad() async {
    if (fechaReserva == null || horaReserva == null || cantidadPersonas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha, hora y cantidad de personas')),
      );
      return;
    }
    
    setState(() {
      _isLoadingMesas = true;
      _showDisponibilidad = true;
    });
    
    try {
      final client = getGraphQLClient();
      final tenantId = await _secureStorage.read(key: 'tenantId') ?? '1';
      final fechaStr = DateFormat('yyyy-MM-dd').format(fechaReserva!);
      final horaStr = '${horaReserva!.hour.toString().padLeft(2, '0')}:${horaReserva!.minute.toString().padLeft(2, '0')}';
      
      debugPrint('🔍 ReservaScreen: Verificando disponibilidad para Fecha=$fechaStr, Hora=$horaStr, Personas=$cantidadPersonas');
      
      // Consulta para obtener mesas Y reservas del día seleccionado
      final result = await client.query(QueryOptions(
        document: gql('''
          query VerificarDisponibilidad(\$tenantId: ID!, \$fecha: String!) {
            mesas: mesasByTenantId(tenantId: \$tenantId) {
              mesaId
              numero
              capacidad
              estado
            }
            reservas: reservasByTenantIdAndFechaReserva(tenantId: \$tenantId, fecha: \$fecha) {
              reservaId
              hora
              mesa {
                mesaId
                numero
              }
              estado
            }
          }
        '''),
        variables: {
          'tenantId': tenantId,
          'fecha': fechaStr,
        },
        fetchPolicy: FetchPolicy.noCache, // Evitar caché para datos frescos
      ));
      
      if (result.hasException) {
        debugPrint('❌ ReservaScreen: Error en consulta de disponibilidad: ${result.exception.toString()}');
        throw Exception(result.exception.toString());
      }
      
      // Verificar que los datos existen
      if (result.data == null) {
        debugPrint('❌ ReservaScreen: No se recibieron datos de disponibilidad');
        throw Exception('No se recibieron datos de disponibilidad');
      }
      
      // Procesar los datos de las mesas
      final mesasData = result.data!['mesas'] as List<dynamic>? ?? [];
      debugPrint('✅ ReservaScreen: Se encontraron ${mesasData.length} mesas en total');
      
      final reservasData = result.data!['reservas'] as List<dynamic>? ?? [];
      debugPrint('✅ ReservaScreen: Se encontraron ${reservasData.length} reservas para la fecha seleccionada');
      
      final List<Map<String, dynamic>> todasMesas = [];
      
      // Mapear mesas de forma segura
      for (var mesa in mesasData) {
        final mesaMap = {
          'mesa_id': mesa['mesaId']?.toString() ?? '',
          'numero': int.tryParse(mesa['numero']?.toString() ?? '0') ?? 0,
          'capacidad': int.tryParse(mesa['capacidad']?.toString() ?? '0') ?? 0,
          'estado': mesa['estado'] == true, // Convertir cualquier valor a booleano
        };
        
        todasMesas.add(mesaMap);
        debugPrint('📊 Mesa disponible: ID=${mesaMap['mesa_id']}, Número=${mesaMap['numero']}, Capacidad=${mesaMap['capacidad']}, Estado=${mesaMap['estado']}');
      }
      
      // Resetear listas
      _mesasDisponibles = [];
      _mesasOcupadas = [];
      
      // Convertir hora seleccionada a minutos para comparación
      final horaSeleccionadaMinutos = horaReserva!.hour * 60 + horaReserva!.minute;
      debugPrint('🕒 Hora seleccionada en minutos: $horaSeleccionadaMinutos');
      
      // Algoritmo para determinar disponibilidad
      for (var mesa in todasMesas) {
        final mesaId = mesa['mesa_id'].toString();
        final numero = mesa['numero'] as int;
        final capacidad = mesa['capacidad'] as int;
        final estado = mesa['estado'] as bool;
        
        // Solo considerar mesas activas y con capacidad suficiente
        if (estado && capacidad >= cantidadPersonas!) {
          bool estaDisponible = true;
          
          // Comprobar si hay reservas que puedan interferir
          for (var reserva in reservasData) {
            final reservaEstado = reserva['estado']?.toString().toUpperCase() ?? '';
            final mesaReservaId = reserva['mesa']?['mesaId']?.toString() ?? '';
            
            // Solo revisar reservas activas o confirmadas
            if (reservaEstado != 'CANCELADA' && 
                reservaEstado != 'NO_SHOW' && 
                mesaReservaId == mesaId) {
              
              // Extraer hora de la reserva
              final horaReservaStr = reserva['hora'] as String? ?? '';
              if (horaReservaStr.isEmpty) continue;
              
              final List<String> horaParts = horaReservaStr.split(':');
              if (horaParts.length >= 2) {
                // CORRECCIÓN: Arreglado el problema de precedencia de operadores
                final horaReservaMinutos = (int.tryParse(horaParts[0]) ?? 0) * 60 + (int.tryParse(horaParts[1]) ?? 0);
                debugPrint('🔍 Comparando reserva en mesa $mesaId: hora reserva=$horaReservaMinutos vs hora seleccionada=$horaSeleccionadaMinutos');
                
                // La mesa está ocupada si la hora solicitada está dentro de +/- 2 horas
                // de una reserva existente (margen de 2 horas para la comida)
                if ((horaSeleccionadaMinutos >= horaReservaMinutos - 60) && 
                    (horaSeleccionadaMinutos <= horaReservaMinutos + 120)) {
                  estaDisponible = false;
                  debugPrint('❌ Mesa $mesaId (Número $numero) no disponible por reserva existente');
                  break;
                }
              }
            }
          }
          
          // Agregar mesa a la lista correspondiente
          if (estaDisponible) {
            _mesasDisponibles.add(mesa);
            debugPrint('✅ Mesa $mesaId (Número $numero) disponible');
          } else {
            _mesasOcupadas.add(mesa);
            debugPrint('❌ Mesa $mesaId (Número $numero) ocupada');
          }
        } else {
          // Mesas inactivas o con capacidad insuficiente
          _mesasOcupadas.add(mesa);
          if (!estado) {
            debugPrint('❌ Mesa $mesaId (Número $numero) inactiva');
          } else {
            debugPrint('❌ Mesa $mesaId (Número $numero) con capacidad insuficiente: $capacidad < $cantidadPersonas');
          }
        }
      }
      
      debugPrint('✅ ReservaScreen: Total mesas disponibles: ${_mesasDisponibles.length}, Total mesas ocupadas: ${_mesasOcupadas.length}');
      
      // Si no hay mesas disponibles
      if (_mesasDisponibles.isEmpty) {
        _errorMessage = 'No hay mesas disponibles para esa fecha y hora con la capacidad requerida';
        debugPrint('❌ ReservaScreen: No hay mesas disponibles');
      } else {
        _errorMessage = '';
        // Preseleccionar la mesa con menor capacidad pero suficiente
        _mesasDisponibles.sort((a, b) => (a['capacidad'] as int).compareTo(b['capacidad'] as int));
        
        // CORRECCIÓN: Usar int.tryParse para convertir de String a int
        final mesaIdStr = _mesasDisponibles.first['mesa_id'].toString();
        mesaId = int.tryParse(mesaIdStr);
        
        debugPrint('✅ ReservaScreen: Mesa preseleccionada: ID=$mesaIdStr (${mesaId ?? "null"}), Número=${_mesasDisponibles.first['numero']}, Capacidad=${_mesasDisponibles.first['capacidad']}');
      }
      
    } catch (e) {
      debugPrint('❌ ReservaScreen: Error al verificar disponibilidad: ${e.toString()}');
      setState(() {
        _errorMessage = 'Error al verificar disponibilidad: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMesas = false;
        });
      }
    }
  }

  Future<void> enviarReservaGraphQL() async {
    // Validación final
    if (fechaReserva == null || horaReserva == null || mesaId == null || cantidadPersonas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Obtener ID del cliente desde secure storage
      final clienteId = await _secureStorage.read(key: 'clienteId');
      if (clienteId == null) {
        throw Exception('No se encontró información del cliente');
      }
      
      final tenantId = await _secureStorage.read(key: 'tenantId') ?? '1';
      
      // Formatear la hora en formato de 24 horas (HH:MM)
      final horaFormateada = '${horaReserva!.hour.toString().padLeft(2, '0')}:${horaReserva!.minute.toString().padLeft(2, '0')}';
      final fechaFormateada = DateFormat('yyyy-MM-dd').format(fechaReserva!);
      
      debugPrint('🔍 ReservaScreen: Creando reserva - MesaID: ${mesaId.toString()}, Fecha: $fechaFormateada, Hora: $horaFormateada, Personas: $cantidadPersonas');
      
      // Crear la reserva usando el provider
      try {
        final resultado = await ref.read(reservaActionsProvider.notifier).crearReserva(
          mesaId: mesaId.toString(),
          fechaReserva: fechaFormateada,
          hora: horaFormateada,
          cantidadPersonas: cantidadPersonas!,
          observaciones: observaciones,
        );
        
        debugPrint('✅ ReservaScreen: Resultado de crear reserva: $resultado');
        
        if (resultado) {
          // IMPORTANTE: Limpiar caché después de crear la reserva
          limpiarCacheGraphQL();
          debugPrint('🧹 ReservaScreen: Caché limpiada después de crear reserva');
          
          // Mostrar mensaje de éxito y regresar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Reserva creada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Recargar las reservas del cliente
          debugPrint('🔄 ReservaScreen: Recargando lista de reservas');
          ref.refresh(reservasClienteProvider);
          
          // Dar tiempo para que aparezca el mensaje
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else {
          throw Exception('No se pudo crear la reserva');
        }
      } catch (e) {
        debugPrint('❌ ReservaScreen: Error en provider al crear reserva: ${e.toString()}');
        throw e;
      }
    } catch (e) {
      debugPrint('❌ ReservaScreen: Error general al crear reserva: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get mesasFiltradas {
    if (cantidadPersonas == null) return [];
    if (_showDisponibilidad) {
      return _mesasDisponibles;
    }
    return _mesas
        .where((mesa) => mesa['capacidad'] >= cantidadPersonas!)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el cliente actual
    final cliente = ref.watch(clienteProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Reservar Mesa'),
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
      ),
      body: _isLoadingMesas && !_showDisponibilidad ? 
        // Mostrar indicador de carga mientras se cargan las mesas
        const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
        : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (cliente != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.tealAccent,
                        child: Text(
                          cliente.nombre.isNotEmpty ? cliente.nombre[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, ${cliente.nombre}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Text(
                              'Vamos a crear tu reserva',
                              style: TextStyle(color: Colors.tealAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              if (_errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              
              const Text(
                'Detalles de tu reserva',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              // Dropdown para cantidad de personas
              Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                ),
                child: DropdownButtonFormField<int>(
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Cantidad de personas',
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.people, color: Colors.tealAccent),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  value: cantidadPersonas,
                  items: List.generate(10, (i) => i + 1)
                      .map((num) => DropdownMenuItem(
                            value: num,
                            child: Text('$num ${num == 1 ? 'persona' : 'personas'}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      cantidadPersonas = value;
                      mesaId = null;
                      _showDisponibilidad = false;
                    });
                    debugPrint('👥 ReservaScreen: Cantidad de personas seleccionada: $value');
                  },
                  validator: (value) => value == null ? 'Selecciona la cantidad' : null,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Selector de fecha
              Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.tealAccent),
                  title: Text(
                    fechaReserva == null
                        ? 'Selecciona una fecha'
                        : DateFormat('EEEE, dd MMMM yyyy').format(fechaReserva!),
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: fechaReserva ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colors.tealAccent,
                              onPrimary: Colors.black,
                              surface: Color(0xFF303030),
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        fechaReserva = picked;
                        _showDisponibilidad = false;
                      });
                      debugPrint('📅 ReservaScreen: Fecha seleccionada: ${DateFormat('yyyy-MM-dd').format(picked)}');
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Selector de hora
              Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.tealAccent),
                  title: Text(
                    horaReserva == null
                        ? 'Selecciona una hora'
                        : horaReserva!.format(context),
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: horaReserva ?? TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colors.tealAccent,
                              onPrimary: Colors.black,
                              surface: Color(0xFF303030),
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        horaReserva = picked;
                        _showDisponibilidad = false;
                      });
                      debugPrint('🕒 ReservaScreen: Hora seleccionada: ${picked.format(context)}');
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Botón para verificar disponibilidad
              if (!_showDisponibilidad)
                ElevatedButton.icon(
                  icon: _isLoadingMesas
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isLoadingMesas ? 'Verificando...' : 'Verificar disponibilidad'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    disabledBackgroundColor: Colors.tealAccent.withOpacity(0.5),
                  ),
                  onPressed: _isLoadingMesas 
                      ? null
                      : () {
                          if (fechaReserva != null && horaReserva != null && cantidadPersonas != null) {
                            debugPrint('🔍 ReservaScreen: Botón verificar disponibilidad presionado');
                            _verificarDisponibilidad();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor completa fecha, hora y cantidad de personas'),
                              ),
                            );
                          }
                        },
                ),
              
              if (_showDisponibilidad) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disponibilidad para ${DateFormat('EEEE, dd MMMM').format(fechaReserva!)} a las ${horaReserva!.format(context)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _mesasDisponibles.isEmpty
                            ? 'No hay mesas disponibles para esta fecha y hora.'
                            : 'Hay ${_mesasDisponibles.length} mesas disponibles.',
                        style: TextStyle(
                          color: _mesasDisponibles.isEmpty ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Selector de mesa (solo si hay disponibles)
                if (_mesasDisponibles.isNotEmpty) ...[
                  const Text(
                    'Selecciona una mesa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Grid de mesas disponibles
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _mesasDisponibles.length,
                    itemBuilder: (context, index) {
                      final mesa = _mesasDisponibles[index];
                      // CORRECCIÓN: Usar comparación segura de tipos
                      final mesaIdStr = mesa['mesa_id'].toString();
                      final isSelected = mesaId != null && mesaId.toString() == mesaIdStr;
                      
                      return InkWell(
                        onTap: () {
                          setState(() {
                            // CORRECCIÓN: Usar int.tryParse para conversión segura
                            mesaId = int.tryParse(mesaIdStr);
                            debugPrint('👆 ReservaScreen: Mesa seleccionada: ID=$mesaIdStr (${mesaId ?? "null"}), Número=${mesa['numero']}');
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.tealAccent.withOpacity(0.3) 
                                : Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.tealAccent : Colors.grey.withOpacity(0.5),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                // CORRECCIÓN: Mejorar visualización cuando numero es 0
                                mesa['numero'] == 0 ? 'Mesa ${mesa['mesa_id']}' : 'Mesa ${mesa['numero']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.tealAccent : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${mesa['capacidad']} personas',
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: isSelected 
                                      ? Colors.tealAccent.withOpacity(0.7) 
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ],
              
              // Campo de observaciones
              if (_showDisponibilidad && _mesasDisponibles.isNotEmpty) ...[
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Observaciones (opcional)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.note_alt, color: Colors.tealAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.tealAccent.withOpacity(0.3)),
                    ),
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    observaciones = value;
                    debugPrint('📝 ReservaScreen: Observaciones ingresadas: $value');
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Botón de confirmar reserva
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isLoading ? 'Creando reserva...' : 'Confirmar Reserva'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      disabledBackgroundColor: Colors.tealAccent.withOpacity(0.5),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (mesaId != null) {
                              debugPrint('💾 ReservaScreen: Botón confirmar reserva presionado');
                              enviarReservaGraphQL();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Por favor selecciona una mesa'),
                                ),
                              );
                            }
                          },
                  ),
                ),
              ],
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}