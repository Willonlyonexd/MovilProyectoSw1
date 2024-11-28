import 'package:flutter/material.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';  // Importa la librería Lottie

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controlador para el PageView
  final PageController _controller = PageController();
  int currentPage = 0; // Para rastrear la página actual

  // Lista de páginas con datos
  final List<ContentConfig> slides = [
    ContentConfig(
      title: '¡Bienvenido a Ficctfy!',
      description: 'La mejor forma de disfrutar de la música en compañía. ¡Crea, comparte y vota las canciones con tus amigos en tiempo real!',
      pathImage: 'assets/Lottie/Animation-RoomPrincipal.json', // Animación Lottie
      backgroundColor: const Color.fromARGB(255, 0, 0, 0)!,  // Fondo oscuro azul grisáceo
    ),
    ContentConfig(
      title: 'Crea tu propia sala',
      description: 'Invita a tus amigos y empieza a disfrutar de música juntos. ¡Crea una sala en segundos y comienza a compartir!',
      pathImage: 'assets/Lottie/22.json', // Animación Lottie
      backgroundColor: const Color.fromARGB(255, 0, 79, 67)!,  // Fondo oscuro verde azulado
    ),
    ContentConfig(
      title: 'Únete a una sala',
      description: 'Únete a las salas de otros usuarios, comparte gustos musicales y vive la experiencia de escuchar juntos.',
      pathImage: 'assets/Lottie/23.json', // Animación Lottie
      backgroundColor: const Color.fromARGB(255, 102, 4, 76)!,  // Fondo oscuro naranja
    ),
    ContentConfig(
      title: 'La IA te ayuda a elegir',
      description: 'Nuestra inteligencia artificial sugiere canciones basadas en el gusto de todos. Luego, ¡tú y tus amigos pueden votar por las favoritas y hacer que suenen en la lista!',
      pathImage: 'assets/Lottie/ia.json', // Animación Lottie
      backgroundColor: Colors.indigo[900]!,  // Fondo oscuro índigo
    ),
    ContentConfig(
      title: '¡Todo listo!',
      description: '¡Ahora es tu turno! Crea una sala, invita a tus amigos y empieza a disfrutar de la música colaborativa.',
      pathImage: 'assets/Lottie/Animation-Pulpo.json', // Animación Lottie
      backgroundColor: Colors.black87,  // Fondo casi negro
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Página de contenido
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: slides.map((slide) => _buildPage(slide)).toList(),
          ),
          
          // Fila de botones: Omitir, Smooth Page Indicator, Siguiente/Finalizar
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón "Omitir" solo si no estamos en la última página
                currentPage < 4
                    ? GestureDetector(
                        onTap: () {
                          // Redirige a la pantalla principal cuando se omite
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            "Omitir",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),

                // Indicador de la página (en el medio)
                SmoothPageIndicator(
                  controller: _controller, // El controlador que sigue el PageView
                  count: 5, // Número de páginas
                  effect: WormEffect(
                    dotHeight: 10.0,
                    dotWidth: 10.0,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withOpacity(0.5),
                  ),
                ),

                // Botón "Siguiente" o "Finalizar"
                currentPage < 4
                    ? ElevatedButton(
                        onPressed: () {
                          _controller.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue, backgroundColor: const Color.fromARGB(255, 12, 12, 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Siguiente",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          // Redirige al usuario a la pantalla principal o login
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 11, 11, 11), backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Comenzar",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir cada página con la animación, título y descripción
  Widget _buildPage(ContentConfig slide) {
    return Container(
      color: slide.backgroundColor,  // Color de fondo personalizado
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Título encima de la animación
            Text(
              slide.title,
              style: TextStyle(
                fontSize: 28, // Tamaño de fuente más grande
                fontWeight: FontWeight.bold, // Negrita para el título
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            // Animación Lottie
            Lottie.asset(
              slide.pathImage,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            
            SizedBox(height: 20),
            
            // Descripción debajo de la animación
            Text(
              slide.description,
              style: TextStyle(
                fontSize: 20, // Tamaño de fuente más grande para la descripción
                fontWeight: FontWeight.w500, // Negrita moderada para la descripción
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Modelo ContentConfig para almacenar los datos de cada slide
class ContentConfig {
  final String title;
  final String description;
  final String pathImage;
  final Color backgroundColor;

  ContentConfig({
    required this.title,
    required this.description,
    required this.pathImage,
    required this.backgroundColor,
  });
}
