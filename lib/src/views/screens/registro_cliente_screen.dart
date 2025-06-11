import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:reproductor_colaborativo_sw1/config/graphql_config.dart';

class RegistroClienteScreen extends StatefulWidget {
  const RegistroClienteScreen({super.key});

  @override
  State<RegistroClienteScreen> createState() => _RegistroClienteScreenState();
}

class _RegistroClienteScreenState extends State<RegistroClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? nombre, apellido, email, telefono, direccion, username, password;
  DateTime? fechaNacimiento;
  int tenantId = 1;

  static const String createClienteMutation = r'''
    mutation CreateCliente($input: ClienteInput!) {
      createCliente(input: $input) {
        clienteId
        nombre
        username
        email
      }
    }
  ''';

  Future<void> registrarCliente() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final client = getGraphQLClient();

    final input = {
      "nombre": nombre,
      "apellido": apellido,
      "email": email,
      "telefono": telefono,
      "direccion": direccion,
      "username": username,
      "password": password,
      "fechaNacimiento": fechaNacimiento != null
          ? DateFormat('yyyy-MM-dd').format(fechaNacimiento!)
          : null,
      "estado": true,
      "tenantId": tenantId,
    };

    try {
      final result = await client.mutate(MutationOptions(
        document: gql(createClienteMutation),
        variables: {"input": input},
      ));

      if (result.hasException) {
        String errorMessage = "Error al registrar cliente";
        
        // Intentar extraer mensaje de error más específico
        if (result.exception?.graphqlErrors.isNotEmpty ?? false) {
          final firstError = result.exception!.graphqlErrors.first;
          if (firstError.message.contains("username") && 
              firstError.message.contains("exist")) {
            errorMessage = "El nombre de usuario ya existe";
          } else if (firstError.message.contains("email") && 
                    firstError.message.contains("exist")) {
            errorMessage = "El correo electrónico ya está registrado";
          } else {
            errorMessage = firstError.message;
          }
        }
        
        _mostrarError(errorMessage);
      } else {
        _mostrarExito("¡Te has registrado con éxito!");
        
        // Dar tiempo para que se muestre el mensaje antes de navegar
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      _mostrarError("Error inesperado: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Registro de Cliente'),
        backgroundColor: const Color.fromARGB(255, 7, 7, 7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen o animación para registro
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.asset(
                    'assets/images/registro.png', // Asegúrate de tener esta imagen
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.app_registration, size: 80, color: Colors.orange),
                  ),
                ),
              ),

              const Text(
                "Información Personal",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              
              // Datos personales
              _buildTextField(
                label: "Nombre", 
                icon: Icons.person, 
                onSaved: (v) => nombre = v,
              ),
              _buildTextField(
                label: "Apellido", 
                icon: Icons.person_outline, 
                onSaved: (v) => apellido = v,
              ),
              _buildTextField(
                label: "Email", 
                icon: Icons.email, 
                inputType: TextInputType.emailAddress, 
                onSaved: (v) => email = v,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El email es requerido";
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return "Ingresa un email válido";
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: "Teléfono", 
                icon: Icons.phone, 
                inputType: TextInputType.phone, 
                onSaved: (v) => telefono = v,
              ),
              _buildTextField(
                label: "Dirección", 
                icon: Icons.location_on, 
                onSaved: (v) => direccion = v,
              ),

              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: ListTile(
                  leading: const Icon(Icons.cake, color: Colors.orange),
                  title: Text(
                    fechaNacimiento == null
                        ? "Selecciona fecha de nacimiento"
                        : "Fecha de nacimiento: ${DateFormat('dd/MM/yyyy').format(fechaNacimiento!)}",
                    style: TextStyle(
                      color: fechaNacimiento == null ? Colors.grey : Colors.white,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colors.orange,
                              onPrimary: Colors.black,
                              surface: Color(0xFF303030),
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) setState(() => fechaNacimiento = picked);
                  },
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Información de Cuenta",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              
              // Datos de cuenta
              _buildTextField(
                label: "Nombre de usuario", 
                icon: Icons.account_circle, 
                onSaved: (v) => username = v,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El nombre de usuario es requerido";
                  }
                  if (value.length < 4) {
                    return "Mínimo 4 caracteres";
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                    return "Solo letras, números y guión bajo";
                  }
                  return null;
                },
              ),
              
              _buildTextField(
                label: "Contraseña", 
                icon: Icons.lock, 
                obscure: _obscurePassword,
                controller: _passwordController,
                onSaved: (v) => password = v,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La contraseña es requerida";
                  }
                  if (value.length < 6) {
                    return "Mínimo 6 caracteres";
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              
              _buildTextField(
                label: "Confirmar contraseña", 
                icon: Icons.lock_outline, 
                obscure: _obscureConfirmPassword,
                onSaved: (v) {}, // No necesitas guardar este valor
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor confirma tu contraseña";
                  }
                  if (value != _passwordController.text) {
                    return "Las contraseñas no coinciden";
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),
              
              // Checkbox de términos y condiciones
              CheckboxListTile(
                title: const Text(
                  "Acepto los términos y condiciones",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                activeColor: Colors.orange,
                value: true,  // Este valor debería ser controlado por el estado
                onChanged: (val) {
                  // Implementar lógica para términos y condiciones
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 30),
              
              // Botón de registro
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isSubmitting 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Icon(Icons.app_registration),
                  label: Text(_isSubmitting ? "Registrando..." : "Completar Registro"),
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            if (fechaNacimiento == null) {
                              _mostrarError("Por favor selecciona tu fecha de nacimiento");
                              return;
                            }
                            
                            _formKey.currentState!.save();
                            registrarCliente();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    disabledBackgroundColor: Colors.orange.withOpacity(0.5),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Link para ir al login
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "¿Ya tienes cuenta? Inicia sesión",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    bool obscure = false,
    Widget? suffixIcon,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          prefixIcon: Icon(icon, color: Colors.orange.shade200),
          suffixIcon: suffixIcon,
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
        keyboardType: inputType,
        validator: validator ?? ((value) => value == null || value.isEmpty ? "Este campo es requerido" : null),
        onSaved: onSaved,
      ),
    );
  }
}