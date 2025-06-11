import 'package:flutter/material.dart';
import 'package:reproductor_colaborativo_sw1/models/mesa_model.dart';
import 'package:reproductor_colaborativo_sw1/models/cliente_model.dart';

class Reserva {
  final String reservaId;
  final String fechaReserva;
  final String hora;
  final int cantidadPersonas;
  final Mesa mesa;
  final Cliente cliente;
  final String estado;
  final bool mensajeConfirmacionEnviado; 
  final String? mensajeConfirmacionEnviadoEn;
  final String? horaLimiteConfirmacion;
  final bool confirmada;
  final String? observaciones;

  Reserva({
    required this.reservaId,
    required this.fechaReserva,
    required this.hora,
    required this.cantidadPersonas,
    required this.mesa,
    required this.cliente,
    required this.estado,
    this.mensajeConfirmacionEnviado = false,
    this.mensajeConfirmacionEnviadoEn,
    this.horaLimiteConfirmacion,
    this.confirmada = false,
    this.observaciones,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    // Capturar los valores originales para debugging
    String originalState = (json['estado'] ?? 'Activa').toString();
    bool isConfirmed = json['confirmada'] == true;
    
    print('📊 Reserva: Estado=${originalState}, Confirmada=${isConfirmed}');
    
    return Reserva(
      reservaId: json['reservaId'] ?? '',
      fechaReserva: json['fechaReserva'] ?? '',
      hora: json['hora'] ?? '',
      cantidadPersonas: int.tryParse(json['cantidadPersonas']?.toString() ?? '0') ?? 0,
      mesa: json['mesa'] != null 
          ? Mesa.fromJson(json['mesa']) 
          : Mesa(mesaId: '0', numero: 0, capacidad: 0, estado: false),
      cliente: json['cliente'] != null 
          ? Cliente.fromJson(json['cliente']) 
          : Cliente(clienteId: '0', nombre: '', apellido: '', username: ''),
      estado: originalState,
      mensajeConfirmacionEnviado: json['mensajeConfirmacionEnviado'] == true,
      mensajeConfirmacionEnviadoEn: json['mensajeConfirmacionEnviadoEn'],
      horaLimiteConfirmacion: json['horaLimiteConfirmacion'],
      confirmada: isConfirmed,
      observaciones: json['observaciones'],
    );
  }

  // Método helper para mostrar el estado de manera amigable en la UI
  String get estadoFormatted {
    if (estado.toUpperCase() == 'ACTIVA') {
      return confirmada ? 'Confirmada' : 'Pendiente';
    }
    
    switch (estado.toUpperCase()) {
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

  // Método helper para obtener color según estado para la UI
  Color getColorByEstado() {
    if (estado.toUpperCase() == 'ACTIVA') {
      return confirmada ? Colors.green : Colors.orange;
    }
    
    switch (estado.toUpperCase()) {
      case 'CANCELADA':
        return Colors.red;
      case 'COMPLETADA':
        return Colors.blue;
      case 'NO_SHOW':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
  
  // Método para verificar si es reserva pendiente
  bool get isPendiente => 
      estado.toUpperCase() == 'ACTIVA' && !confirmada;
  
  // Método para verificar si es reserva confirmada
  bool get isConfirmada => 
      estado.toUpperCase() == 'ACTIVA' && confirmada;
  
  // Método para verificar si es reserva histórica
  bool get isHistorica {
    final upperState = estado.toUpperCase();
    return upperState == 'CANCELADA' || 
           upperState == 'COMPLETADA' || 
           upperState == 'NO_SHOW';
  }
}