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
            _scaffoldKey.currentState!
                .openDrawer(); // 🔥 Ahora sí se abre el Drawer
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
        ],
      ),
      drawer: _buildUserDrawer(context),
      body: StreamBuilder(
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
          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              String key = vehicles.keys.elementAt(index);
              var vehicle = vehicles[key];

              return Card(
                child: ListTile(
                  leading: Image.network(vehicle['imagenes'][0] ?? '',
                      width: 80, height: 80, fit: BoxFit.cover),
                  title: Text(
                      "${vehicle['marca'] ?? 'Desconocido'} ${vehicle['modelo'] ?? ''}"),
                  subtitle: Text(
                      "Precio: ${vehicle['precio'] ?? 'Precio no disponible'}€ / dia"),
                ),
              );
            },
          );
        },
      ),
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
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => AuthScreen()));
          },
        ),
      ],
    ),
  );
}

}
