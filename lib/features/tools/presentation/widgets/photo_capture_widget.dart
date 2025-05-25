import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // Temporarily disabled for web testing
import 'dart:io';

class PhotoCaptureWidget extends StatefulWidget {
  final Function(List<String>) onPhotosChanged;
  final int maxPhotos;

  const PhotoCaptureWidget({
    super.key,
    required this.onPhotosChanged,
    this.maxPhotos = 5,
  });

  @override
  State<PhotoCaptureWidget> createState() => _PhotoCaptureWidgetState();
}

class _PhotoCaptureWidgetState extends State<PhotoCaptureWidget> {
  final List<String> _photoPaths = [];
  // final ImagePicker _picker = ImagePicker(); // Temporarily disabled for web testing

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Photos (Optional)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${_photoPaths.length}/${widget.maxPhotos}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Capture photos to document the tool condition',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        if (_photoPaths.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photoPaths.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_photoPaths[index]),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
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
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _photoPaths.length >= widget.maxPhotos
                    ? null
                    : () => _capturePhoto('camera'),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _photoPaths.length >= widget.maxPhotos
                    ? null
                    : () => _capturePhoto('gallery'),
                icon: const Icon(Icons.photo_library),
                label: const Text('From Gallery'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _capturePhoto(dynamic source) async {
    // Temporarily disabled for web testing - image_picker not available
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo capture temporarily disabled for web testing'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    // TODO: Re-enable when image_picker is available
    /*
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _photoPaths.add(photo.path);
        });
        widget.onPhotosChanged(_photoPaths);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    */
  }

  void _removePhoto(int index) {
    setState(() {
      _photoPaths.removeAt(index);
    });
    widget.onPhotosChanged(_photoPaths);
  }
}
