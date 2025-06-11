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
  // Cambiar a no-nullable con valor por defecto
  final bool mensajeConfirmacionEnviado; 
  final String? mensajeConfirmacionEnviadoEn;
  final String? horaLimiteConfirmacion;
  // Cambiar a no-nullable con valor por defecto
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
    // Valores por defecto para los booleanos
    this.mensajeConfirmacionEnviado = false,
    this.mensajeConfirmacionEnviadoEn,
    this.horaLimiteConfirmacion,
    this.confirmada = false,
    this.observaciones,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    // Conversiones seguras para evitar errores con valores nulos
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
      estado: json['estado'] ?? 'PENDIENTE',
      // Conversión segura para booleanos
      mensajeConfirmacionEnviado: json['mensajeConfirmacionEnviado'] == true,
      mensajeConfirmacionEnviadoEn: json['mensajeConfirmacionEnviadoEn'],
      horaLimiteConfirmacion: json['horaLimiteConfirmacion'],
      confirmada: json['confirmada'] == true,
      observaciones: json['observaciones'],
    );
  }

  // Método helper para mostrar el estado de manera amigable
  String get estadoFormatted {
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

  // Método helper para obtener color según estado
  Color getColorByEstado() {
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
        return Colors.black;
    }
  }
}