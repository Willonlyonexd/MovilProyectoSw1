import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:reproductor_colaborativo_sw1/config/graphql_config.dart';
import 'package:reproductor_colaborativo_sw1/models/reserva_model.dart';
import 'package:reproductor_colaborativo_sw1/providers/reserva_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MisReservasPage extends ConsumerStatefulWidget {
  const MisReservasPage({super.key});

  @override
  ConsumerState<MisReservasPage> createState() => _MisReservasPageState();
}

class _MisReservasPageState extends ConsumerState<MisReservasPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Filtros de estado para pestañas
  final List<String> _filtros = ['Todas', 'Pendientes', 'Confirmadas', 'Historial'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filtros.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    
    // Cargar reservas al iniciar
    _cargarReservas();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _cargarReservas() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Recargar usando el provider
      await ref.refresh(reservasClienteProvider.future);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar reservas: ${e.toString()}';
      });
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
            content: Text('Reserva cancelada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Recargar las reservas
        _cargarReservas();
      } else {
        throw Exception('No se pudo cancelar la reserva');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  List<dynamic> _getReservasFiltradas(List<dynamic> reservas) {
    if (_tabController.index == 0) {
      // Todas las reservas, pero ordenadas por fecha y estado
      final List<dynamic> ordenadas = List.from(reservas);
      ordenadas.sort((a, b) {
        // Primero pendientes y confirmadas (futuras), luego el resto
        final aPrioridad = a.estado == 'PENDIENTE' || a.estado == 'CONFIRMADA' ? 0 : 1;
        final bPrioridad = b.estado == 'PENDIENTE' || b.estado == 'CONFIRMADA' ? 0 : 1;
        
        if (aPrioridad != bPrioridad) {
          return aPrioridad - bPrioridad;
        }
        
        // Ordenar por fecha (más cercanas primero)
        final aFecha = DateTime.parse(a.fechaReserva);
        final bFecha = DateTime.parse(b.fechaReserva);
        return aFecha.compareTo(bFecha);
      });
      return ordenadas;
    } else if (_tabController.index == 1) {
      // Pendientes
      return reservas.where((r) => r.estado == 'PENDIENTE').toList();
    } else if (_tabController.index == 2) {
      // Confirmadas
      return reservas.where((r) => r.estado == 'CONFIRMADA').toList();
    } else {
      // Historial (completadas, canceladas, no-show)
      return reservas.where((r) => 
        r.estado == 'COMPLETADA' || 
        r.estado == 'CANCELADA' || 
        r.estado == 'NO_SHOW'
      ).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar el provider para obtener las reservas
    final reservasAsync = ref.watch(reservasClienteProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: _cargarReservas,
        color: Colors.tealAccent,
        backgroundColor: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Mis Reservas",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
              const SizedBox(height: 20),

              // Botón para agregar reserva
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/reservation').then((_) => _cargarReservas());
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
                isScrollable: true,
                indicatorColor: Colors.tealAccent,
                labelColor: Colors.tealAccent,
                unselectedLabelColor: Colors.white70,
                tabs: _filtros.map((filtro) => Tab(text: filtro)).toList(),
                onTap: (_) => setState(() {}),
              ),
              
              const SizedBox(height: 15),

              // Lista de reservas con estado async
              Expanded(
                child: reservasAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  ),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Error al cargar reservas',
                          style: TextStyle(color: Colors.red[300]),
                        ),
                        TextButton(
                          onPressed: _cargarReservas,
                          child: const Text('Reintentar', style: TextStyle(color: Colors.tealAccent)),
                        ),
                      ],
                    ),
                  ),
                  data: (reservas) {
                    final reservasFiltradas = _getReservasFiltradas(reservas);
                    
                    if (reservasFiltradas.isEmpty) {
                      String mensaje = '';
                      
                      switch (_tabController.index) {
                        case 0:
                          mensaje = "No tienes reservas.";
                          break;
                        case 1:
                          mensaje = "No tienes reservas pendientes.";
                          break;
                        case 2:
                          mensaje = "No tienes reservas confirmadas.";
                          break;
                        case 3:
                          mensaje = "No tienes historial de reservas.";
                          break;
                      }
                      
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _tabController.index == 0 ? Icons.event_busy : Icons.calendar_today,
                              color: Colors.white54,
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              mensaje,
                              style: const TextStyle(color: Colors.white70),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildReservaCard(BuildContext context, dynamic reserva) {
    // Formatear fecha para mostrarla mejor
    final fecha = DateTime.parse(reserva.fechaReserva);
    final fechaFormateada = DateFormat('E, d MMM yyyy', 'es_ES').format(fecha);
    
    // Determinar color según estado
    final Color estadoColor = _getColorForEstado(reserva.estado);
    final bool esHistorico = reserva.estado == 'COMPLETADA' || 
                              reserva.estado == 'CANCELADA' || 
                              reserva.estado == 'NO_SHOW';
    
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
                  '🪑 Mesa ${reserva.mesa.numero}',
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
                    _getEstadoText(reserva.estado),
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
            Text(
              '📅 $fechaFormateada',
              style: const TextStyle(fontSize: 14, color: Colors.white),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botones contextuales según el estado
                if (!esHistorico) ...[
                  TextButton.icon(
                    onPressed: () => _cancelarReserva(reserva.reservaId),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text("Cancelar"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
                  if (reserva.estado == 'PENDIENTE')
                    TextButton.icon(
                      onPressed: () {
                        // Aquí iría la lógica para confirmar la reserva
                        // O navegar a una vista detallada
                      },
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
                ] else
                  // Para reservas históricas, solo mostrar detalles
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
            )
          ],
        ),
      ),
    );
  }
  
  String _getEstadoText(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'CONFIRMADA':
        return 'Confirmada';
      case 'CANCELADA':
        return 'Cancelada';
      case 'COMPLETADA':
        return 'Completada';
      case 'NO_SHOW':
        return 'No asistió';
      default:
        return estado;
    }
  }
  
  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return Colors.orange;
      case 'CONFIRMADA':
        return Colors.green;
      case 'CANCELADA':
        return Colors.red;
      case 'COMPLETADA':
        return Colors.blue;
      case 'NO_SHOW':
        return Colors.grey;
      default:
        return Colors.white;
    }
  }
}