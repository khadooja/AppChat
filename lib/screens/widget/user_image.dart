import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePiker extends StatefulWidget {
  const UserImagePiker({super.key, required this.onimagePickFn});

  final void Function(File pickedImage) onimagePickFn;

  @override
  State<UserImagePiker> createState() => _UserImagePikerState();
}

class _UserImagePikerState extends State<UserImagePiker> {
  File? _pickedImage;
  void _pickImage() async {
    final XFile? pickedImageFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (pickedImageFile != null) {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
      widget.onimagePickFn(_pickedImage!);
    }

   // Navigator.of(context).pop({'pickedImage': _pickedImage});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage:_pickedImage == null ? null : FileImage(_pickedImage!),
        ),
        TextButton.icon(
          onPressed: () {
            _pickImage();
          },
          icon: const Icon(Icons.image),
          label: const Text('Add Image'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        )
      ],
    );
  }
}
