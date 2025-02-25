import 'package:carventureapp/screens/add_vehicle_screen.dart';
import 'package:carventureapp/screens/renting_screen.dart';
import 'package:carventureapp/screens/vehicle_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_svg/svg.dart';
import 'auth_screen.dart';
import 'user_details_screen.dart';
import 'package:intl/intl.dart';

/**
 * Clase HomeScreen
 *
 * Esta pantalla actúa como el punto central de la aplicación, permitiendo a los usuarios 
 * explorar y gestionar vehículos disponibles para alquilar. También proporciona acceso 
 * a la información del usuario y opciones adicionales a través de un menú lateral.
 *
 * Funcionalidades principales:
 * - Muestra una lista de vehículos disponibles con la posibilidad de filtrarlos.
 * - Permite buscar vehículos por marca o modelo.
 * - Ofrece filtros por tipo de vehículo y rango de precios.
 * - Indica si un vehículo está disponible para alquilar.
 * - Accede a la pantalla de detalles del vehículo seleccionado.
 * - Integra un menú lateral con opciones para editar perfil, revisar reservas activas y cerrar sesión.
 * - Permite agregar nuevos vehículos a la base de datos.
 *
 * Métodos destacados:
 * - `_loadUserData()`: Carga la información del usuario desde Firebase.
 * - `_loadReservedVehicles()`: Obtiene la lista de vehículos reservados para evitar mostrar opciones no disponibles.
 * - `_buildFilters()`: Genera la interfaz de filtros y búsqueda.
 * - `_buildVehicleList()`: Carga y muestra la lista de vehículos disponibles con las opciones de filtrado aplicadas.
 * - `_buildUserDrawer(BuildContext context)`: Construye el menú lateral con información del usuario y opciones adicionales.
 *
 * Diseño:
 * - Barra de navegación con degradado en tonos morado y azul.
 * - Fondo con efecto de neón para mantener la temática futurista de la aplicación.
 * - Tarjetas de vehículos con imágenes, información y estilos personalizados.
 * - Menú lateral con fondo degradado y opciones de navegación resaltadas.
 */


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _vehiclesRef =
      FirebaseDatabase.instance.ref().child('vehiculos');
  final DatabaseReference _reservationsRef =
      FirebaseDatabase.instance.ref().child('reservas');

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // 🔥 Clave para abrir Drawer

  User? user;
  Map<dynamic, dynamic>? userData;
  List<String> reservedVehicleIds = [];

  // 🔍 Variables para filtros y búsqueda
  String searchQuery = '';
  String selectedType = 'Todos';
  double minPrice = 0;
  double maxPrice = 200;
  bool showOnlyAvailable = false;

  List<String> vehicleTypes = ['Todos', 'Coche', 'Moto'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadReservedVehicles(); // 🔥 Cargar vehículos reservados al iniciar
  }

  Future<void> _loadUserData() async {
    user = _auth.currentUser;
    if (user != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(user!.uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists && snapshot.value != null) {
        setState(() {
          userData = snapshot.value as Map<dynamic, dynamic>;
        });
      }
    }
  }

  // 🔥 Cargar lista de vehículos reservados
  Future<void> _loadReservedVehicles() async {
    DatabaseEvent event = await _reservationsRef.once();
    DateTime today = DateTime.now();

    if (event.snapshot.value != null &&
        event.snapshot.value is Map<dynamic, dynamic>) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        reservedVehicleIds = data.entries
            .where((entry) {
              var reserva = entry.value as Map<dynamic, dynamic>;

              if (reserva.containsKey('fecha_inicio') &&
                  reserva.containsKey('fecha_fin') &&
                  reserva.containsKey('vehiculo')) {
                DateTime startDate =
                    DateFormat("yyyy-MM-dd").parse(reserva['fecha_inicio']);
                DateTime endDate =
                    DateFormat("yyyy-MM-dd").parse(reserva['fecha_fin']);

                return today.isAfter(startDate) && today.isBefore(endDate);
              }
              return false;
            })
            .map((entry) => entry.value['vehiculo'].toString())
            .toList();
      });

      print(
          "🚗 Vehículos Reservados: $reservedVehicleIds"); // ✅ Debug en consola
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // 🔥 Asignamos la clave aquí
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "CARVENTURE",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        leading: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _scaffoldKey.currentState!.openDrawer(),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.person, size: 30, color: Colors.white),
          ),
        ),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.exit_to_app, size: 28, color: Colors.white),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddVehicleScreen()),
          );
        },
        backgroundColor: Colors.indigoAccent,
        child: Icon(Icons.add, size: 30, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      drawer: _buildUserDrawer(context),
      body: Column(
        children: [
          _buildFilters(), // 🔍 Sección de búsqueda y filtros
          Expanded(child: _buildVehicleList()),
        ],
      ),
    );
  }

  // 🔍 Filtros y Búsqueda
  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Buscar por marca o modelo',
              prefixIcon: Icon(Icons.search, color: Colors.indigo),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Filtrar por tipo:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              DropdownButton<String>(
                value: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                items: vehicleTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text("Filtrar por precio (€)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          RangeSlider(
            values: RangeValues(minPrice, maxPrice),
            min: 0,
            max: 200,
            divisions: 20,
            labels: RangeLabels('${minPrice.toInt()}€', '${maxPrice.toInt()}€'),
            onChanged: (values) {
              setState(() {
                minPrice = values.start;
                maxPrice = values.end;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Solo vehículos disponibles",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Switch(
                value: showOnlyAvailable,
                onChanged: (value) {
                  setState(() {
                    showOnlyAvailable = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🚗 Lista de vehículos filtrados
  Widget _buildVehicleList() {
    return StreamBuilder(
      stream: _vehiclesRef.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return Center(
            child: Text(
              "No hay vehículos disponibles.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          );
        }

        final data = snapshot.data!.snapshot.value;
        if (data is! Map<dynamic, dynamic>) {
          return Center(
            child: Text(
              "Error al cargar los datos.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          );
        }

        Map<dynamic, dynamic> vehicles = data;

        // 🔍 Aplicar filtros y ocultar vehículos reservados
        List<MapEntry<dynamic, dynamic>> filteredVehicles =
            vehicles.entries.where((entry) {
          var vehicle = entry.value;

          bool matchesSearch = searchQuery.isEmpty ||
              (vehicle['marca']
                      ?.toString()
                      .toLowerCase()
                      .contains(searchQuery) ??
                  false) ||
              (vehicle['modelo']
                      ?.toString()
                      .toLowerCase()
                      .contains(searchQuery) ??
                  false);

          bool matchesType =
              selectedType == 'Todos' || vehicle['tipo'] == selectedType;

          bool matchesPrice = vehicle['precio'] != null &&
              vehicle['precio'] >= minPrice &&
              vehicle['precio'] <= maxPrice;

          bool matchesAvailability = !showOnlyAvailable ||
              (vehicle['disponibilidad'] != null &&
                  vehicle['disponibilidad'] == true);

          bool isNotReserved =
              !reservedVehicleIds.contains(entry.key.toString());

          return matchesSearch &&
              matchesType &&
              matchesPrice &&
              matchesAvailability &&
              isNotReserved;
        }).toList();

        return ListView.builder(
          itemCount: filteredVehicles.length,
          itemBuilder: (context, index) {
            var vehicle = filteredVehicles[index].value;
            String vehicleId = filteredVehicles[index].key.toString();

            // 🔥 Obtener imagen del vehículo o imagen por defecto
            String imageUrl = (vehicle['imagenes'] != null &&
                    vehicle['imagenes'].isNotEmpty)
                ? vehicle['imagenes'][0]
                : "https://cdn-icons-png.flaticon.com/512/1998/1998701.png"; // 🔥 Imagen por defecto

            return Card(
              elevation: 6,
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported,
                          size: 50, color: Colors.grey);
                    },
                  ),
                ),
                title: Text(
                  "${vehicle['marca']} ${vehicle['modelo']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Precio: ${vehicle['precio']}€ / día",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.indigo),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VehicleDetailsScreen(
                        vehicleId: vehicleId,
                        vehicleData: vehicle,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // 🔥 Menú lateral con fondo degradado y mejores estilos
  Widget _buildUserDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              accountName: Text(
                userData?['nombre'] ?? 'Usuario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                userData?['email'] ?? 'Sin Email',
                style: TextStyle(fontSize: 16),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: userData?['profileImage'] != null
                    ? ClipOval(
                        child: SvgPicture.network(
                          userData!['profileImage'],
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                          placeholderBuilder: (context) =>
                              CircularProgressIndicator(),
                        ),
                      )
                    : Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),

            // ✅ Opción para "Editar Perfil"
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text(
                "Editar Perfil",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onTap: () async {
                final updatedUserData = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            UserDetailsScreen(userData: userData)));

                // 🔥 Si los datos se actualizaron, refrescamos la UI
                if (updatedUserData != null) {
                  setState(() {
                    userData = updatedUserData;
                  });
                }
              },
            ),

            // ✅ Opción para "Mis Rentings"
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.white),
              title: Text(
                "Mis Rentings",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          RentingScreen()), // 🔥 Nueva pantalla
                );
              },
            ),

            // ✅ Opción para "Cerrar Sesión"
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.white),
              title: Text(
                "Cerrar Sesión",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onTap: () async {
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
