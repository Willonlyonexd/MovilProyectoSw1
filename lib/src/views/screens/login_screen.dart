import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:app_links/app_links.dart';
import 'package:reproductor_colaborativo_sw1/providers/auth_provider.dart';
import '../widgets/animated_gradient_text.dart';
import 'package:reproductor_colaborativo_sw1/config/graphql_config.dart';
import 'package:reproductor_colaborativo_sw1/models/cliente_model.dart';
import 'package:reproductor_colaborativo_sw1/models/usuario_model.dart';
import 'package:reproductor_colaborativo_sw1/services/user_provider.dart';

import 'dart:async';

// Definir un enum para los tipos de usuario
enum UserType { cliente, mesero }

// Provider para el usuario mesero
final meseroProvider = StateProvider<Usuario?>((ref) {
  return null;
});

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  StreamSubscription? _sub;
  late final AppLinks _appLinks;
  bool _isCheckingAuth = true;
  bool _isLogging = false;
  
  // Tipo de usuario por defecto
  UserType _selectedUserType = UserType.cliente;

  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScaleAnimation;

  // Mutación para login de cliente
  static const String loginClienteMutation = r'''
    mutation LoginCliente($username: String!, $password: String!) {
      loginCliente(username: $username, password: $password) {
        token
        cliente {
          clienteId
          nombre
          username
          apellido
          telefono
          email
        }
      }
    }
  ''';
  
  // Mutación para login de usuario/mesero
  static const String loginUsuarioMutation = r'''
    mutation Login($username: String!, $password: String!) {
      login(username: $username, password: $password) {
        token
        usuario {
          usuarioId
          nombre
          apellido
          username
          email
          telefono
          roles {
            rolId
            nombre
          }
        }
      }
    }
  ''';

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _checkExistingToken();
    _listenToRedirects();
    
    _buttonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonAnimController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkExistingToken() async {
    try {
      final token = await _secureStorage.read(key: 'token');
      final userType = await _secureStorage.read(key: 'userType');
      
      if (token != null && userType != null) {
        String route = '/home';
        
        if (userType == 'cliente') {
          final clienteId = await _secureStorage.read(key: 'clienteId');
          final clienteNombre = await _secureStorage.read(key: 'clienteNombre');
          final clienteUsername = await _secureStorage.read(key: 'clienteUsername');
          
          if (clienteId != null && clienteNombre != null && clienteUsername != null) {
            ref.read(clienteProvider.notifier).state = Cliente(
              clienteId: clienteId,
              nombre: clienteNombre,
              username: clienteUsername, apellido: '',
            );
          }
        } else if (userType == 'mesero') {
          // Restaurar información del mesero
          final usuarioId = await _secureStorage.read(key: 'usuarioId');
          final usuarioNombre = await _secureStorage.read(key: 'usuarioNombre');
          final usuarioUsername = await _secureStorage.read(key: 'usuarioUsername');
          
          if (usuarioId != null && usuarioNombre != null && usuarioUsername != null) {
            ref.read(meseroProvider.notifier).state = Usuario(
              usuarioId: usuarioId,
              nombre: usuarioNombre,
              apellido: '',  // No guardamos apellido en secure storage
              email: '',     // No guardamos email en secure storage
              username: usuarioUsername,
              estado: true,
            );
          }
          
          route = '/mesero/home'; // Ruta específica para meseros
        }
        
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacementNamed(context, route);
        });
      } else {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    } catch (e) {
      print('Error verificando autenticación: $e');
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  void _listenToRedirects() {
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.toString().startsWith('myapp://callback')) {
        print("Deep link recibido: $uri");
      }
    }, onError: (err) {
      print("Error en uriLinkStream: $err");
    });
  }

  Future<void> _login() async {
    setState(() {
      _isLogging = true;
    });
    
    try {
      final client = getGraphQLClient();
      late final MutationOptions options;
      
      // Elegir la mutación según el tipo de usuario seleccionado
      if (_selectedUserType == UserType.cliente) {
        options = MutationOptions(
          document: gql(loginClienteMutation),
          variables: {
            "username": userController.text,
            "password": passwordController.text,
          },
        );
      } else {
        options = MutationOptions(
          document: gql(loginUsuarioMutation),
          variables: {
            "username": userController.text,
            "password": passwordController.text,
          },
        );
      }
      
      final result = await client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? "Error de autenticación");
      }

      String? token;
      String nombre = "";
      String route = '/home';
      
      // Procesar según el tipo de usuario
      if (_selectedUserType == UserType.cliente) {
        // Verificar que result.data no sea null y contenga loginCliente
        if (result.data != null && result.data!.containsKey('loginCliente')) {
          token = result.data!['loginCliente']['token'];
          final clienteData = result.data!['loginCliente']['cliente'];
          
          if (clienteData != null) {
            final cliente = Cliente.fromJson(clienteData);
            
            await _secureStorage.write(key: 'userType', value: 'cliente');
            await _secureStorage.write(key: 'clienteId', value: cliente.clienteId);
            await _secureStorage.write(key: 'clienteNombre', value: cliente.nombre);
            await _secureStorage.write(key: 'clienteUsername', value: cliente.username);
            
            ref.read(clienteProvider.notifier).state = cliente;
            nombre = cliente.nombre;
          }
        }
      } else {
        // Verificar que result.data no sea null y contenga login
        if (result.data != null && result.data!.containsKey('login')) {
          token = result.data!['login']['token'];
          final usuarioData = result.data!['login']['usuario'];
          
          if (usuarioData != null) {
            // Crear una instancia de Usuario
            final usuario = Usuario(
              usuarioId: usuarioData['usuarioId'],
              nombre: usuarioData['nombre'],
              apellido: usuarioData['apellido'] ?? '',
              email: usuarioData['email'] ?? '',
              telefono: usuarioData['telefono'],
              username: usuarioData['username'],
              estado: true,
              // Capturar roles si están presentes
              roles: (usuarioData['roles'] as List?)?.map((rol) => RolSimple(
                rolId: rol['rolId'],
                nombre: rol['nombre'],
                estado: true
              )).toList(),
            );
            
            await _secureStorage.write(key: 'userType', value: 'mesero');
            await _secureStorage.write(key: 'usuarioId', value: usuario.usuarioId);
            await _secureStorage.write(key: 'usuarioNombre', value: usuario.nombre);
            await _secureStorage.write(key: 'usuarioUsername', value: usuario.username);
            
            // Guardar usuario en el provider
            ref.read(meseroProvider.notifier).state = usuario;
            
            nombre = usuario.nombre;
            route = '/mesero/home'; // Ruta específica para meseros
          }
        }
      }

      // Verificar que se haya obtenido un token
      if (token == null || token.isEmpty) {
        throw Exception('No se pudo obtener el token de autenticación');
      }
      
      await _secureStorage.write(key: 'token', value: token);
      await _secureStorage.write(key: 'tenantId', value: '1'); // Valor por defecto

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Bienvenido $nombre"),
          backgroundColor: Colors.green[700],
        ),
      );

      Navigator.pushReplacementNamed(context, route);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: ${e.toString()}"),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLogging = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    userController.dispose();
    passwordController.dispose();
    _buttonAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Comida 100% Peruana',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              const AnimatedMovingGradientText(
                text: 'Sabor Andino',
                textStyle: TextStyle(
                  fontSize: 100,
                  fontFamily: 'Ocean',
                  fontWeight: FontWeight.normal,
                ),
                gradientColors: [
                  Color.fromARGB(255, 243, 33, 33),
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 245, 1, 1),
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 243, 4, 4),
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 240, 4, 4),
                ],
                duration: Duration(seconds: 5),
              ),
              const SizedBox(height: 5),
              Lottie.asset(
                'assets/Lottie/log2.json',
                width: 350,
                height: 350,
                fit: BoxFit.contain,
              ),
              
              // Selector de tipo de usuario
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildUserTypeButton(
                        title: 'Cliente',
                        icon: Icons.person,
                        isSelected: _selectedUserType == UserType.cliente,
                        onPressed: () {
                          setState(() {
                            _selectedUserType = UserType.cliente;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildUserTypeButton(
                        title: 'Personal',
                        icon: Icons.badge,
                        isSelected: _selectedUserType == UserType.mesero,
                        onPressed: () {
                          setState(() {
                            _selectedUserType = UserType.mesero;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 15),
              TextField(
                controller: userController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.person, color: Colors.orange),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.orange, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.orange, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.orange, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.orange, width: 2.0),
                  ),
                ),
                onSubmitted: (_) {
                  if (userController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                    _login();
                  }
                },
              ),
              const SizedBox(height: 30),
              
              // Botón de login con animación
              GestureDetector(
                onTapDown: (_) => _buttonAnimController.forward(),
                onTapUp: (_) => _buttonAnimController.reverse(),
                onTapCancel: () => _buttonAnimController.reverse(),
                child: ScaleTransition(
                  scale: _buttonScaleAnimation,
                  child: ElevatedButton.icon(
                    icon: _isLogging 
                        ? SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2.0,
                            )
                          )
                        : const Icon(Icons.login),
                    label: Text(_isLogging ? 'Iniciando sesión...' : 'Iniciar Sesión'),
                    onPressed: _isLogging 
                        ? null 
                        : () {
                            if (userController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                              _login();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Completa los campos'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      disabledBackgroundColor: Colors.orange.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.app_registration),
                label: const Text('Registrarse'),
                onPressed: _isLogging ? null : () {
                  Navigator.pushNamed(context, '/registro');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  disabledBackgroundColor: Colors.orange.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              
              // Mostrar mensaje específico según el tipo de usuario
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _selectedUserType == UserType.cliente
                      ? '¡Inicia sesión para realizar y gestionar tus reservas!'
                      : '¡Inicia sesión para gestionar mesas y pedidos!',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Método auxiliar para crear botones de selección de tipo de usuario
  Widget _buildUserTypeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(title),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.orange : Colors.transparent,
        foregroundColor: isSelected ? Colors.black : Colors.white,
        elevation: isSelected ? 4 : 0,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}