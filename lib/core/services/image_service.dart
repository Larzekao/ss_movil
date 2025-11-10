import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Servicio para manejar selección y captura de imágenes
class ImageService {
  static final ImageService _instance = ImageService._internal();

  factory ImageService() {
    return _instance;
  }

  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Selecciona una imagen de la galería
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Captura una foto con la cámara
  Future<File?> takePhotoWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo with camera: $e');
      return null;
    }
  }

  /// Selecciona múltiples imágenes de la galería
  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);

      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  /// Abre un diálogo para elegir entre cámara o galería
  Future<File?> pickImageWithDialog({
    required Function(ImageSource) onSourceSelected,
  }) async {
    try {
      // Este es un helper que puede ser usado desde la UI
      // para mostrar un diálogo personalizado
      return null;
    } catch (e) {
      print('Error in image picker dialog: $e');
      return null;
    }
  }
}
