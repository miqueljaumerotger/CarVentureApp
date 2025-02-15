import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDetailsScreen extends StatefulWidget {
  final Map<dynamic, dynamic>? userData;

  UserDetailsScreen({this.userData});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _nameController.text = widget.userData!['nombre'] ?? '';
      _phoneController.text = widget.userData!['telefono']?.toString() ?? '';
    }
  }

  Future<void> _updateUserData() async {
  User? user = _auth.currentUser;
  if (user != null) {
    String userId = user.uid;
    String newName = _nameController.text.trim();
    String newPhone = _phoneController.text.trim();

    await _userRef.child(userId).update({
      'nombre': newName,
      'telefono': newPhone,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Datos actualizados correctamente")),
    );

    // ✅ Retornar los datos actualizados a `HomeScreen`
    Navigator.pop(context, {
      'nombre': newName,
      'telefono': newPhone,
      'email': widget.userData?['email'] ?? 'Sin Email',
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editar Perfil")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserData,
              child: Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }
}
