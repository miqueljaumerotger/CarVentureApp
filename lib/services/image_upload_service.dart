import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/**
 * Clase ImageUploadService
 *
 * Esta clase maneja la carga de imágenes a Cloudinary mediante solicitudes HTTP.
 *
 * Funcionalidades principales:
 * - `uploadImageToCloudinary()`: Sube una imagen a Cloudinary y devuelve la URL segura de la imagen cargada.
 *
 * Uso:
 * - Se utiliza en la aplicación para permitir a los usuarios subir imágenes de vehículos.
 * - Requiere una URL de Cloudinary válida y un `upload_preset` configurado en la cuenta de Cloudinary.
 * - Maneja errores y excepciones en caso de fallos en la carga.
 */


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
