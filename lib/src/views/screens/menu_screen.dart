import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> menuData = [];
  int selectedCategoryIndex = 0;
  String filter = 'default';

  @override
  void initState() {
    super.initState();
    loadMenuData();
  }

  Future<void> loadMenuData() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/menu_data_es.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    setState(() {
      menuData = jsonList;
    });
  }

  List<dynamic> getFilteredProducts() {
    if (menuData.isEmpty) return [];
    List<dynamic> productos =
        List.from(menuData[selectedCategoryIndex]['productos']);

    switch (filter) {
      case 'precio_asc':
        productos.sort((a, b) => a['precio'].compareTo(b['precio']));
        break;
      case 'precio_desc':
        productos.sort((a, b) => b['precio'].compareTo(a['precio']));
        break;
      case 'nombre_asc':
        productos.sort(
            (a, b) => a['nombre'].toString().compareTo(b['nombre'].toString()));
        break;
      case 'nombre_desc':
        productos.sort(
            (a, b) => b['nombre'].toString().compareTo(a['nombre'].toString()));
        break;
      default:
        break;
    }

    return productos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú del Restaurante'),
        backgroundColor: Colors.teal,
      ),
      body: menuData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: menuData.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategoryIndex = index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selectedCategoryIndex == index
                                ? Colors.teal
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              menuData[index]['nombre'],
                              style: TextStyle(
                                color: selectedCategoryIndex == index
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("Ordenar:"),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: filter,
                        items: const [
                          DropdownMenuItem(
                              value: 'default', child: Text('Por defecto')),
                          DropdownMenuItem(
                              value: 'precio_asc',
                              child: Text('Más barato')),
                          DropdownMenuItem(
                              value: 'precio_desc',
                              child: Text('Más caro')),
                          DropdownMenuItem(
                              value: 'nombre_asc',
                              child: Text('Nombre: A–Z')),
                          DropdownMenuItem(
                              value: 'nombre_desc',
                              child: Text('Nombre: Z–A')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => filter = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: getFilteredProducts().length,
                    itemBuilder: (context, index) {
                      final producto = getFilteredProducts()[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: Image.asset(
                                  producto['imagen'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    producto['nombre'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${producto['precio'].toString()} Bs'),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}
