import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reproductor_colaborativo_sw1/models/reserva_model.dart';
import 'package:reproductor_colaborativo_sw1/providers/reserva_provider.dart';

class MisReservasPage extends ConsumerStatefulWidget {
  const MisReservasPage({super.key});

  @override
  ConsumerState<MisReservasPage> createState() => _MisReservasPageState();
}

class _MisReservasPageState extends ConsumerState<MisReservasPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late TabController _tabController;
  bool _isLoading = false;
  bool _initialDataLoaded = false;
  DateTime? _lastLoadTime;
  
  // Solo 3 pestañas: Pendientes, Confirmadas, Historial
  final List<String> _filtros = ['Pendientes', 'Confirmadas', 'Historial'];
  
  @override
  bool get wantKeepAlive => true; // Para AutomaticKeepAliveClientMixin
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filtros.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    
    // Registrar para eventos de ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);
    
    // Cargar reservas al iniciar
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
      _cargarReservas(forzarRefresh: true);
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
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
        // Resetear el provider completamente
        ref.invalidate(reservasClienteProvider);
      }
      
      // Esperar a que se complete la carga
      await ref.refresh(reservasClienteProvider.future);
      
      // Marcar que ya cargamos datos al menos una vez
      _initialDataLoaded = true;
      _lastLoadTime = DateTime.now();
      
      debugPrint('✅ MisReservasPage: Reservas recargadas exitosamente');
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

  Future<void> _confirmarReserva(String reservaId) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Confirmar Reserva', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Deseas confirmar esta reserva?', 
          style: TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Sí, confirmar'),
          ),
        ],
      ),
    );
    
    if (confirmar != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await ref.read(reservaActionsProvider.notifier).confirmarReserva(reservaId);
      
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reserva confirmada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Forzar refresco completo
        await _cargarReservas(forzarRefresh: true);
        
        // Cambiar a la pestaña de Confirmadas
        _tabController.animateTo(1);
        setState(() {}); // Forzar rebuild
      } else {
        throw Exception('No se pudo confirmar la reserva');
      }
    } catch (e) {
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

  Future<void> _cancelarReserva(String reservaId) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Cancelar Reserva', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro que deseas cancelar esta reserva?', 
          style: TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.tealAccent)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    
    if (confirmar != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await ref.read(reservaActionsProvider.notifier).cancelarReserva(reservaId);
      
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reserva cancelada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Forzar refresco completo
        await _cargarReservas(forzarRefresh: true);
        
        // Cambiar a la pestaña de Historial
        _tabController.animateTo(2);
        setState(() {}); // Forzar rebuild
      } else {
        throw Exception('No se pudo cancelar la reserva');
      }
    } catch (e) {
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
  
  List<Reserva> _getReservasFiltradas(List<Reserva> reservas) {
    // Listar todos los estados para depuración
    final estadosInfo = reservas.map((r) => 
      'ID:${r.reservaId} - ${r.estado} (confirmada=${r.confirmada})'
    ).toList();
    debugPrint('🔍 Estados detallados: $estadosInfo');
    
    switch (_tabController.index) {
      case 0: // Pendientes - Activas no confirmadas
        final pendientes = reservas.where((r) => r.isPendiente).toList();
        
        pendientes.sort((a, b) {
          final aFecha = DateTime.parse(a.fechaReserva);
          final bFecha = DateTime.parse(b.fechaReserva);
          return aFecha.compareTo(bFecha); // Ordenar por proximidad
        });
        
        debugPrint('📊 MisReservasPage: ${pendientes.length} reservas pendientes');
        return pendientes;
        
      case 1: // Confirmadas - Activas y confirmadas
        final confirmadas = reservas.where((r) => r.isConfirmada).toList();
        
        confirmadas.sort((a, b) {
          final aFecha = DateTime.parse(a.fechaReserva);
          final bFecha = DateTime.parse(b.fechaReserva);
          return aFecha.compareTo(bFecha); // Ordenar por proximidad
        });
        
        debugPrint('📊 MisReservasPage: ${confirmadas.length} reservas confirmadas');
        return confirmadas;
        
      case 2: // Historial - Canceladas, Completadas, NoShow
        final historial = reservas.where((r) => r.isHistorica).toList();
        
        historial.sort((a, b) {
          final aFecha = DateTime.parse(a.fechaReserva);
          final bFecha = DateTime.parse(b.fechaReserva);
          return bFecha.compareTo(aFecha); // Historial: más recientes primero
        });
        
        debugPrint('📊 MisReservasPage: ${historial.length} reservas en historial');
        return historial;
        
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Para AutomaticKeepAliveClientMixin
    
    // Usar el provider para obtener las reservas
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
              const SizedBox(height: 20),

              // Botón para agregar reserva
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/reservation').then((_) async {
                      await _cargarReservas(forzarRefresh: true);
                      // Asegurar que después de crear una reserva se muestre la pestaña "Pendientes"
                      _tabController.animateTo(0);
                      setState(() {}); // Forzar rebuild
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Agregar Reserva"),
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
              
              // Pestañas para filtrar reservas
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.tealAccent,
                labelColor: Colors.tealAccent,
                unselectedLabelColor: Colors.white70,
                tabs: _filtros.map((filtro) => Tab(text: filtro)).toList(),
                onTap: (_) => setState(() {}),
              ),
              
              const SizedBox(height: 15),

              // Lista de reservas con estado async
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
                          debugPrint('⚠️ MisReservasPage: No hay reservas para mostrar');
                        } else {
                          debugPrint('✅ MisReservasPage: ${reservas.length} reservas cargadas');
                          
                          // Contar reservas por tipo usando los métodos auxiliares del modelo
                          final pendientes = reservas.where((r) => r.isPendiente).length;
                          final confirmadas = reservas.where((r) => r.isConfirmada).length;
                          final historial = reservas.where((r) => r.isHistorica).length;
                          
                          debugPrint('📊 MisReservasPage: Pendientes: $pendientes, Confirmadas: $confirmadas, Historial: $historial');
                        }
                        
                        final reservasFiltradas = _getReservasFiltradas(reservas);
                        
                        if (reservasFiltradas.isEmpty) {
                          String mensaje = '';
                          IconData icono = Icons.calendar_today;
                          
                          switch (_tabController.index) {
                            case 0:
                              mensaje = "No tienes reservas pendientes.";
                              icono = Icons.pending_actions;
                              break;
                            case 1:
                              mensaje = "No tienes reservas confirmadas.";
                              icono = Icons.check_circle_outline;
                              break;
                            case 2:
                              mensaje = "No tienes historial de reservas.";
                              icono = Icons.history;
                              break;
                          }
                          
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  icono,
                                  color: Colors.white54,
                                  size: 60,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  mensaje,
                                  style: const TextStyle(color: Colors.white70),
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
                        
                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: reservasFiltradas.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final reserva = reservasFiltradas[index];
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
            
            // Mostrar botones de acción según el estado
            if (!esHistorico) Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _cancelarReserva(reserva.reservaId),
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text("Cancelar"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 8),
                // No mostrar el botón Confirmar si ya está confirmada (usando el método del modelo)
                if (!estaConfirmada)
                  TextButton.icon(
                    onPressed: () => _confirmarReserva(reserva.reservaId),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text("Confirmar"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () {
                      // Navegar al detalle de la reserva
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text("Detalles"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.tealAccent,
                    ),
                  ),
              ],
            ) else
              // Para reservas históricas, solo mostrar detalles
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Navegar al detalle de la reserva
                    },
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text("Ver detalles"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.tealAccent,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}