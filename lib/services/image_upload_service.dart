import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageUploadService {
  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      // 🔥 Tu URL de subida de Cloudinary
      String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dvipt4jpn/image/upload";

      // 🔥 Tu clave de subida de Cloudinary (debes configurarla)
      String uploadPreset = "ml_default";

      var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      print("📤 Subiendo imagen a Cloudinary...");

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        print("✅ Imagen subida correctamente: ${jsonResponse['secure_url']}");
        return jsonResponse['secure_url'];
      } else {
        print("❌ Error al subir imagen: ${jsonResponse.toString()}");
        return null;
      }
    } catch (e) {
      print("❌ Excepción en subida a Cloudinary: $e");
      return null;
    }
  }
}
