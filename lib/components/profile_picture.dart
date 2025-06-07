import 'dart:io';
import 'package:flutter/material.dart';

class LmbProfilePicture extends StatelessWidget {
  final File? localFile;
  final String? networkUrl;
  final double radius;

  const LmbProfilePicture({
    super.key,
    this.localFile,
    this.networkUrl,
    this.radius = 80,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (localFile != null) {
      imageProvider = FileImage(localFile!);
    } else if (networkUrl != null && networkUrl!.isNotEmpty) {
      imageProvider = NetworkImage(networkUrl!);
    } else {
      imageProvider = const AssetImage('assets/default_profile_picture.png');
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: imageProvider,
    );
  }
}