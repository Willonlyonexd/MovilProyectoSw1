import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reproductor_colaborativo_sw1/config/graphql_config.dart';
import 'package:reproductor_colaborativo_sw1/models/reserva_model.dart';
import 'package:reproductor_colaborativo_sw1/providers/reserva_provider.dart';

class MisReservasPage extends ConsumerStatefulWidget {
  const MisReservasPage({super.key});

  @override
  ConsumerState<MisReservasPage> createState() => _MisReservasPageState();
}

class _MisReservasPageState extends ConsumerState<MisReservasPage> 
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool _isLoading = false;
  bool _initialDataLoaded = false;
  DateTime? _lastLoadTime;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    
    // Registrar para eventos de ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);
    
    // Cargar reservas al iniciar, limpiando caché
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarReservas(forzarRefresh: true);
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Si ya cargamos datos inicialmente y han pasado más de 5 segundos, recargamos
    if (_initialDataLoaded && _lastLoadTime != null) {
      final difference = DateTime.now().difference(_lastLoadTime!);
      if (difference.inSeconds > 5) {
        _cargarReservas(forzarRefresh: true);
      }
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Cuando la app vuelve al primer plano, recargar datos
    if (state == AppLifecycleState.resumed) {
      limpiarCacheGraphQL();
      _cargarReservas(forzarRefresh: true);
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  Future<void> _cargarReservas({bool forzarRefresh = false}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      debugPrint('🔄 MisReservasPage: Cargando reservas (forzarRefresh: $forzarRefresh)');
      
      if (forzarRefresh) {
        limpiarCacheGraphQL();
        ref.invalidate(reservasClienteProvider);
      }
      
      // Esperar a que se complete la carga
      final reservas = await ref.refresh(reservasClienteProvider.future);
      
      // Depuración: Mostrar estado de cada reserva
      for (final r in reservas) {
        debugPrint('📊 Reserva[${r.reservaId}]: estado=${r.estado}, confirmada=${r.confirmada}, isPendiente=${r.isPendiente}, isConfirmada=${r.isConfirmada}');
      }
      
      _initialDataLoaded = true;
      _lastLoadTime = DateTime.now();
      
      debugPrint('✅ MisReservasPage: ${reservas.length} reservas cargadas');
    } catch (e) {
      debugPrint('❌ MisReservasPage: Error al cargar reservas: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Reserva> _ordenarReservas(List<Reserva> reservas) {
    // Ordenar reservas: próximas primero, luego las confirmadas, luego históricas
    return reservas..sort((a, b) {
      // 1. Reservas históricas al final
      if (a.isHistorica && !b.isHistorica) return 1;
      if (!a.isHistorica && b.isHistorica) return -1;
      
      // 2. Para reservas activas, ordenar por fecha
      final aFecha = DateTime.parse(a.fechaReserva);
      final bFecha = DateTime.parse(b.fechaReserva);
      
      // Si ambas son históricas, las más recientes primero
      if (a.isHistorica && b.isHistorica) {
        return bFecha.compareTo(aFecha);
      }
      
      // Para las no históricas, las más próximas primero
      return aFecha.compareTo(bFecha);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final reservasAsync = ref.watch(reservasClienteProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => _cargarReservas(forzarRefresh: true),
        color: Colors.tealAccent,
        backgroundColor: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Mis Reservas",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.tealAccent),
                    onPressed: () => _cargarReservas(forzarRefresh: true),
                    tooltip: 'Actualizar reservas',
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Banner informativo de WhatsApp
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF075E54).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF075E54).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF25D366),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.telegram, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gestión por WhatsApp",
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Recibirás un mensaje para confirmar o cancelar tu reserva. No es necesario hacerlo desde la app.",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Botón para agregar reserva
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(context, '/reservation');
                    limpiarCacheGraphQL();
                    await _cargarReservas(forzarRefresh: true);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Crear Nueva Reserva"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              
              // Resumen de reservas (opcional)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: reservasAsync.maybeWhen(
                  data: (reservas) {
                    final pendientes = reservas.where((r) => r.isPendiente).length;
                    final confirmadas = reservas.where((r) => r.isConfirmada).length;
                    final historicas = reservas.where((r) => r.isHistorica).length;
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildEstadisticaChip(
                          pendientes, 
                          'Por confirmar', 
                          Colors.orange
                        ),
                        _buildEstadisticaChip(
                          confirmadas, 
                          'Confirmadas', 
                          Colors.green
                        ),
                        _buildEstadisticaChip(
                          historicas, 
                          'Historial', 
                          Colors.blueGrey
                        ),
                      ],
                    );
                  },
                  orElse: () => const SizedBox(),
                ),
              ),

              const SizedBox(height: 15),

              // Lista de reservas (todas juntas, sin pestañas)
              Expanded(
                child: Stack(
                  children: [
                    reservasAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.tealAccent),
                      ),
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'Error al cargar reservas',
                              style: TextStyle(color: Colors.red[300]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: TextStyle(color: Colors.red[200], fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => _cargarReservas(forzarRefresh: true),
                              child: const Text('Reintentar', style: TextStyle(color: Colors.tealAccent)),
                            ),
                          ],
                        ),
                      ),
                      data: (reservas) {
                        if (reservas.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white54,
                                  size: 60,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "No tienes reservas",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => _cargarReservas(forzarRefresh: true),
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text("Actualizar"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.tealAccent,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        final reservasOrdenadas = _ordenarReservas(reservas);
                        
                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: reservasOrdenadas.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final reserva = reservasOrdenadas[index];
                            return _buildReservaCard(context, reserva);
                          },
                        );
                      },
                    ),
                    if (_isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.tealAccent),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEstadisticaChip(int cantidad, String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            cantidad.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReservaCard(BuildContext context, Reserva reserva) {
    // Formatear fecha para mostrarla mejor
    final fecha = DateTime.parse(reserva.fechaReserva);
    final fechaFormateada = DateFormat('E, d MMM yyyy', 'es_ES').format(fecha);
    
    // Determinar color según estado
    final Color estadoColor = reserva.getColorByEstado();
    final String estadoTexto = reserva.estadoFormatted;
    final bool esHistorico = reserva.isHistorica;
    final bool estaConfirmada = reserva.isConfirmada;
    
    // Verificar si una reserva está próxima (dentro de 24 horas)
    final bool estaProxima = fecha.difference(DateTime.now()).inHours < 24 && !esHistorico;
    
    // Comprobar si la mesa tiene número o es null
    final String numeroMesa = reserva.mesa.numero == 0 ? 
                             reserva.mesa.mesaId : 
                             reserva.mesa.numero.toString();
    
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: estadoColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '🪑 Mesa $numeroMesa',
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: estadoColor, width: 1),
                  ),
                  child: Text(
                    estadoTexto,
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '📅 $fechaFormateada',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                if (estaProxima)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: const Text(
                      '¡Próxima!',
                      style: TextStyle(color: Colors.orange, fontSize: 10),
                    ),
                  ),
              ],
            ),
            Text(
              '⏰ Hora: ${reserva.hora}',
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            Text(
              '👥 Personas: ${reserva.cantidadPersonas}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            if (reserva.observaciones != null && reserva.observaciones!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '📝 ${reserva.observaciones}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70, fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 12),
            
            // Mensaje de WhatsApp en lugar de botones de acción
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF075E54).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.telegram, 
                    color: Color(0xFF25D366),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Gestiona esta reserva por WhatsApp",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}