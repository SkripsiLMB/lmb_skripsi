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
    if (localFile != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(localFile!),
      );
    }

    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        child: ClipOval(
          child: Image.network(
            networkUrl!,
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/default_profile_picture.png',
                fit: BoxFit.cover,
                width: radius * 2,
                height: radius * 2,
              );
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: const AssetImage('assets/default_profile_picture.png'),
    );
  }
}