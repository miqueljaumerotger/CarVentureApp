import 'package:carventureapp/screens/add_vehicle_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_svg/svg.dart';
import 'auth_screen.dart';
import 'user_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _vehiclesRef =
      FirebaseDatabase.instance.ref().child('vehiculos');

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // 🔥 Clave para abrir Drawer

  User? user;
  Map<dynamic, dynamic>? userData;

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
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AuthScreen()));
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

        // 🔍 Aplicar filtros
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

          return matchesSearch &&
              matchesType &&
              matchesPrice &&
              matchesAvailability;
        }).toList();

        return ListView.builder(
  itemCount: filteredVehicles.length,
  itemBuilder: (context, index) {
    var vehicle = filteredVehicles[index].value;
    String imageUrl = (vehicle['imagenes'] != null && vehicle['imagenes'].isNotEmpty)
        ? vehicle['imagenes'][0] // Usa la primera imagen si está disponible
        : "https://cdn-icons-png.flaticon.com/512/1998/1998701.png"; // 🔥 Imagen por defecto

    return Card(
      child: ListTile(
        leading: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
        title: Text("${vehicle['marca'] ?? 'Desconocido'} ${vehicle['modelo'] ?? ''}"),
        subtitle: Text("Precio: ${vehicle['precio']}€ / día"),
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

          // ✅ Solo dejamos UNA opción para "Editar Perfil"
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

          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Cerrar Sesión"),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AuthScreen()));
            },
          ),
        ],
      ),
    );
  }
}
