import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ss_movil/core/services/image_service.dart';

/// Widget para seleccionar imágenes de galería o cámara
class ImagePickerWidget extends StatefulWidget {
  final Function(File) onImageSelected;
  final Function(List<File>)? onMultipleImagesSelected;
  final bool allowMultiple;
  final String? label;
  final IconData? icon;

  const ImagePickerWidget({
    Key? key,
    required this.onImageSelected,
    this.onMultipleImagesSelected,
    this.allowMultiple = false,
    this.label,
    this.icon,
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImageService _imageService = ImageService();
  File? _selectedImage;
  List<File> _selectedImages = [];
  bool _isLoading = false;

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              if (widget.allowMultiple)
                ListTile(
                  leading: const Icon(Icons.collections),
                  title: const Text('Seleccionar Múltiples'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickMultipleImages();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    setState(() => _isLoading = true);
    try {
      final File? image = await _imageService.takePhotoWithCamera();
      if (image != null && mounted) {
        setState(() => _selectedImage = image);
        widget.onImageSelected(image);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _isLoading = true);
    try {
      final File? image = await _imageService.pickImageFromGallery();
      if (image != null && mounted) {
        setState(() => _selectedImage = image);
        widget.onImageSelected(image);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    setState(() => _isLoading = true);
    try {
      final List<File> images = await _imageService.pickMultipleImages();
      if (images.isNotEmpty && mounted) {
        setState(() => _selectedImages = images);
        widget.onMultipleImagesSelected?.call(images);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedImage != null || _selectedImages.isNotEmpty)
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.isNotEmpty
                  ? _selectedImages.length
                  : 1,
              itemBuilder: (context, index) {
                final image = _selectedImages.isNotEmpty
                    ? _selectedImages[index]
                    : _selectedImage;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          image!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedImages.isNotEmpty) {
                                _selectedImages.removeAt(index);
                              } else {
                                _selectedImage = null;
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _showImageSourceDialog,
          icon: Icon(widget.icon ?? Icons.image),
          label: Text(widget.label ?? 'Seleccionar Imagen'),
        ),
      ],
    );
  }
}
