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
        title: Text("Vehículos Disponibles"),
        leading: IconButton(
          icon: Icon(Icons.person), // Ícono de usuario
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddVehicleScreen()),
              );
            },
          ),
        ],
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
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Buscar por marca o modelo',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Filtrar por tipo:"),
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
          SizedBox(height: 10),
          Text("Filtrar por precio (€)"),
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
              Text("Solo vehículos disponibles"),
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
          return Center(child: Text("No hay vehículos disponibles."));
        }

        final data = snapshot.data!.snapshot.value;
        if (data is! Map<dynamic, dynamic>) {
          return Center(child: Text("Error al cargar los datos."));
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
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0), // 🔥 Agrega espacio interno
                leading: SizedBox(
                  width:
                      80, // 🔥 Fija el ancho de la imagen para evitar el error
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
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
                ),
                title: Text("${vehicle['marca']} ${vehicle['modelo']}"),
                subtitle: Text("Precio: ${vehicle['precio']}€ / día"),
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

  Widget _buildUserDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userData?['nombre'] ?? 'Usuario'),
            accountEmail: Text(userData?['email'] ?? 'Sin Email'),
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
                  : Icon(Icons.person,
                      size: 40, color: Colors.white), // Imagen por defecto
            ),
          ),

          // ✅ Opción para "Editar Perfil"
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Editar Perfil"),
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
            leading: Icon(Icons.calendar_today),
            title: Text("Mis Rentings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RentingScreen()), // 🔥 Nueva pantalla
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Cerrar Sesión"),
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
    );
  }
}
