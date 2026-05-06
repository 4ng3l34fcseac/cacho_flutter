// Importamos Flutter para la interfaz de usuario
import 'package:flutter/material.dart';
// Importamos la librería matemática para generar números aleatorios
import 'dart:math';

// Función principal que inicia la aplicación
void main() => runApp(
  MaterialApp(
    home: JuegoDado(), // La pantalla principal es nuestro juego de dados
    debugShowCheckedModeBanner: false, // Ocultamos la etiqueta "Debug"
  ),
);

// StatefulWidget porque el estado de los dados cambia con cada lanzamiento
class JuegoDado extends StatefulWidget {
  @override
  _JuegoDadoState createState() => _JuegoDadoState();
}

class _JuegoDadoState extends State<JuegoDado> with SingleTickerProviderStateMixin {
  // Variables de estado
  List<int> dados = [1, 1, 1, 1, 1]; // Almacena los valores actuales de los 5 dados
  String resultadoJugada = "Lanza los dados para jugar"; // Texto del resultado
  Color resultadoColor = Colors.white; // Color del texto del resultado
  
  // Variables para animaciones
  late AnimationController _controller; // Controlador de animación
  late Animation<double> _rotationAnimation; // Animación de rotación
  late Animation<double> _scaleAnimation; // Animación de escala
  bool _isAnimating = false; // Bandera para saber si está animando
  List<int> _dadosTemp = [1, 1, 1, 1, 1]; // Valores temporales durante animación
  
  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador de animación
    // duration: duración de la animación (800 milisegundos)
    // vsync: this sincroniza la animación con el ciclo de dibujo del widget
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Configuramos la animación de rotación: el dado girará de 0 a 360 grados (2*PI radianes)
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic, // Curva de aceleración: empieza rápido y termina suave
      ),
    );
    
    // Configuramos la animación de escala: el dado se encoge y vuelve a su tamaño normal
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut, // Curva elástica para efecto de rebote
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose(); // Liberamos recursos del controlador
    super.dispose();
  }
  
  // Función que lanza los dados con animación
  void lanzarCacho() async {
    if (_isAnimating) return; // Si ya está animando, no hacemos nada
    
    setState(() {
      _isAnimating = true; // Marcamos que estamos animando
      // Generamos valores temporales aleatorios para mostrar durante la animación
      _dadosTemp = List.generate(5, (_) => Random().nextInt(6) + 1);
    });
    
    // Iniciamos la animación
    _controller.forward(from: 0);
    
    // Esperamos a que termine la animación
    await _controller.forward().orCancel;
    
    // Después de la animación, actualizamos los dados con valores finales
    setState(() {
      dados = List.generate(5, (_) => Random().nextInt(6) + 1);
      resultadoJugada = evaluarJugada(dados); // Evaluamos la jugada
      _isAnimating = false; // Animación terminada
    });
  }
  
  // Función que evalúa el tipo de jugada según las reglas del juego de dados
  String evaluarJugada(List<int> dados) {
    // Ordenamos los dados para facilitar la evaluación de escaleras
    List<int> dadosOrdenados = List.from(dados)..sort();
    
    // Contamos la frecuencia de cada número (cuántas veces aparece cada valor)
    // Ejemplo: si tenemos [1,1,3,3,3], conteo será {1:2, 3:3}
    Map<int, int> conteo = {};
    for (var dado in dados) {
      conteo[dado] = (conteo[dado] ?? 0) + 1;
    }
    
    // Obtenemos las frecuencias y las ordenamos de mayor a menor
    // Ejemplo: [3,2] para el caso [1,1,3,3,3]
    var frecuencias = conteo.values.toList()..sort((a, b) => b.compareTo(a));
    
    // 1. Verificar si es GRANDE o DORMIDA (5 dados iguales)
    if (frecuencias[0] == 5) {
      resultadoColor = Colors.green; // Cambiamos el color a verde
      return "¡GRANDE / DORMIDA! 🏆";
    }
    
    // 2. Verificar si es POKER (4 dados iguales)
    if (frecuencias[0] == 4) {
      resultadoColor = Colors.blue; // Color azul para poker
      return "POKER 🃏";
    }
    
    // 3. Verificar ESCALERAS
    // Escalera mayor: 3-4-5-6-1 (después de ordenar: 1,3,4,5,6)
    // Verificamos si existen todos estos números
    if (dadosOrdenados.contains(1) && dadosOrdenados.contains(3) && 
        dadosOrdenados.contains(4) && dadosOrdenados.contains(5) && dadosOrdenados.contains(6)) {
      resultadoColor = Colors.orange; // Color naranja para escaleras
      return "ESCALERA MAYOR 🌟";
    }
    
    // Escalera media: 2-3-4-5-6
    // Verificamos si es una secuencia exacta de 2 a 6
    if (dadosOrdenados[0] == 2 && dadosOrdenados[1] == 3 && 
        dadosOrdenados[2] == 4 && dadosOrdenados[3] == 5 && dadosOrdenados[4] == 6) {
      resultadoColor = Colors.orange;
      return "ESCALERA MEDIA ⭐";
    }
    
    // Escalera menor: 1-2-3-4-5
    // Verificamos si es una secuencia exacta de 1 a 5
    if (dadosOrdenados[0] == 1 && dadosOrdenados[1] == 2 && 
        dadosOrdenados[2] == 3 && dadosOrdenados[3] == 4 && dadosOrdenados[4] == 5) {
      resultadoColor = Colors.orange;
      return "ESCALERA MENOR ✨";
    }
    
    // 4. Verificar FULL (3 iguales + 2 iguales)
    if (frecuencias[0] == 3 && frecuencias[1] == 2) {
      resultadoColor = Colors.purple; // Color morado para full
      return "FULL CASAS 🏠";
    }
    
    // 5. Verificar TRICA (3 iguales y 2 distintos)
    if (frecuencias[0] == 3 && frecuencias[1] == 1) {
      resultadoColor = Colors.teal; // Color teal para trica
      return "TRICA 🎲";
    }
    
    // 6. Verificar DOBLE PAR (2 pares distintos y un dado diferente)
    if (frecuencias[0] == 2 && frecuencias[1] == 2 && frecuencias[2] == 1) {
      resultadoColor = Colors.indigo; // Color índigo para doble par
      return "DOBLE PAR 🎯";
    }
    
    // 7. Verificar PAR (2 dados iguales y los otros 3 diferentes)
    if (frecuencias[0] == 2 && frecuencias[1] == 1 && frecuencias[2] == 1) {
      // Identificamos qué número es el que forma el par
      int numeroPar = 0;
      for (var entry in conteo.entries) {
        if (entry.value == 2) {
          numeroPar = entry.key; // Guardamos el valor que aparece 2 veces
          break;
        }
      }
      
      // Mostramos el nombre específico del par según su número
      switch (numeroPar) {
        case 1:
          resultadoColor = Colors.red;
          return "BALAS (Par de Ases) 🅰️";
        case 2:
          resultadoColor = Colors.amber;
          return "TONTOS (Par de 2) 2️⃣";
        case 3:
          resultadoColor = Colors.lightGreen;
          return "TRENES (Par de 3) 3️⃣";
        case 4:
          resultadoColor = Colors.cyan;
          return "CUADRAS (Par de 4) 4️⃣";
        case 5:
          resultadoColor = Colors.pink;
          return "QUINAS (Par de 5) 5️⃣";
        case 6:
          resultadoColor = Colors.orangeAccent;
          return "SENAS (Par de 6) 6️⃣";
        default:
          resultadoColor = Colors.white;
          return "PAR 🎲";
      }
    }
    
    // 8. Verificar NULO (combinaciones específicas que no puntúan)
    // Convertimos los dados ordenados en una cadena para comparar con las combinaciones nulas
    String claveNulo = dadosOrdenados.join(',');
    
    // Lista de combinaciones consideradas nulas
    List<String> nulos = [
      "1,2,3,5,6",  // Combinación 1-2-3-5-6
      "1,2,4,5,6",  // Combinación 1-2-4-5-6
      "1,2,3,4,6"   // Combinación 1-2-3-4-6
    ];
    
    if (nulos.contains(claveNulo)) {
      resultadoColor = Colors.grey; // Color gris para nulo
      return "NULO ⚫";
    }
    
    // 9. Por defecto, es BALA (Sencilla) - cualquier combinación no clasificada
    resultadoColor = Colors.white70;
    return "BALA (Sencilla) 🎲";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 90, 7), // Fondo verde oscuro
      appBar: AppBar(
        title: Text("JUEGO DE DADOS"), // Título de la aplicación
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        backgroundColor: const Color.fromARGB(255, 171, 7, 7), // Barra roja
        centerTitle: true,
        toolbarHeight: 100, // Altura de la barra
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centramos verticalmente
          children: [
            // Contenedor del resultado de la jugada
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54, // Fondo semitransparente
                borderRadius: BorderRadius.circular(10), // Bordes redondeados
              ),
              child: Text(
                resultadoJugada, // Texto que muestra el resultado
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: resultadoColor, // Color dinámico según la jugada
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30), // Espacio vertical de 30 píxeles
            
            // Primera fila de dados (posiciones 0, 1, 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dado 1 con animación
                _buildDadoAnimado(0),
                SizedBox(width: 20), // Espacio entre dados
                // Dado 2 con animación
                _buildDadoAnimado(1),
                SizedBox(width: 20),
                // Dado 3 con animación
                _buildDadoAnimado(2),
              ],
            ),
            SizedBox(height: 20), // Espacio vertical
            
            // Segunda fila de dados (posiciones 3 y 4)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dado 4 con animación
                _buildDadoAnimado(3),
                SizedBox(width: 20),
                // Dado 5 con animación
                _buildDadoAnimado(4),
              ],
            ),
            SizedBox(height: 40), // Espacio vertical
            
            // Botón para lanzar los dados
            ElevatedButton(
              onPressed: lanzarCacho, // Acción al presionar
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(54, 13, 101, 1), // Color morado
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                elevation: 8, // Sombra elevada
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Bordes circulares
                ),
              ),
              child: Text(
                "¡LANZAR EL CACHO!",
                style: TextStyle(
                  fontSize: 20,
                  color: const Color.fromARGB(255, 237, 235, 235),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget que construye un dado con animación (rotación y escala)
  Widget _buildDadoAnimado(int index) {
    // Si está animando, mostramos los valores temporales, si no, los valores finales
    int valorActual = _isAnimating ? _dadosTemp[index] : dados[index];
    
    // Si está animando, aplicamos las animaciones de rotación y escala
    if (_isAnimating) {
      return AnimatedBuilder(
        animation: _controller, // El controlador que maneja la animación
        builder: (context, child) {
          return Transform(
            // Matriz de transformación que combina rotación y escala
            transform: Matrix4.identity()
              ..translate(50.0, 50.0) // Movemos el centro de transformación al centro del dado
              ..rotateZ(_rotationAnimation.value) // Rotamos en el eje Z (giro)
              ..translate(-50.0, -50.0) // Regresamos al punto original
              ..scale(_scaleAnimation.value), // Aplicamos escala para efecto de rebote
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10), // Sombra sutil
                ],
              ),
              child: Image.asset(
                'assets/$valorActual.png', // Muestra la imagen del dado según el valor
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      );
    } else {
      // Sin animación: mostramos el dado estático
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10),
          ],
        ),
        child: Image.asset(
          'assets/$valorActual.png',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        ),
      );
    }
  }
}