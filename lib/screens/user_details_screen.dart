import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importamos flutter_svg

class UserDetailsScreen extends StatefulWidget {
  final Map<dynamic, dynamic>? userData;

  UserDetailsScreen({this.userData});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child('users');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? selectedProfileImage;

  final List<String> profileImages = [
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Aquarius",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Blizzard",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Cyclone",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Dusk",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Echo",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Falcon",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Galaxy",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Horizon",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Inferno",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Jungle",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Knight",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Legend",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Mirage",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Nova",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Orion",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Phantom",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Quasar",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Radiant",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Shadow",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Twilight",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _nameController.text = widget.userData!['nombre'] ?? '';
      _phoneController.text = widget.userData!['telefono']?.toString() ?? '';
      selectedProfileImage =
          widget.userData!['profileImage'] ?? profileImages[0];
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
        'profileImage': selectedProfileImage, // 🔥 Guardar imagen seleccionada
      });

      print("Imagen de perfil guardada: $selectedProfileImage"); // Debug

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Datos actualizados correctamente")),
      );

      Navigator.pop(context, {
        'nombre': newName,
        'telefono': newPhone,
        'email': widget.userData?['email'] ?? 'Sin Email',
        'profileImage': selectedProfileImage,
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

            Text("Selecciona tu foto de perfil"),
            SizedBox(height: 10),

            // 🔥 Selector de Imágenes de Perfil (SVG)
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: profileImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedProfileImage = profileImages[index];
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            selectedProfileImage == profileImages[index]
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                        child: ClipOval(
                          child: SvgPicture.network(
                            profileImages[index],
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                            placeholderBuilder: (context) =>
                                CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
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
