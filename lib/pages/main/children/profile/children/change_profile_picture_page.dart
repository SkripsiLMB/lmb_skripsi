// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/profile_picture.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/logic/sbstorage_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';

class ChangeProfilePicturePage extends StatefulWidget {
  final String? nik;

  const ChangeProfilePicturePage({
    super.key,
    this.nik,
  });

  @override
  State<ChangeProfilePicturePage> createState() => _ChangeProfilePicturePageState();
}

class _ChangeProfilePicturePageState extends State<ChangeProfilePicturePage> {
  File? selectedImage;
  bool isActionLoading = false;

  @override
  Widget build(BuildContext context) {
    final profilePictureUrl = SbStorageService.instance.getPublicUrl('${widget.nik}.jpg', "profile-pictures");

    return LmbBaseElement(
      isScrollable: true,
      title: "Change Profile Picture",
      children: [
        const Text('Upload a clear picture of yourself. This picture will only be visible to you and shown in some pages.'),
        const SizedBox(height: 16),

        // NOTE: Image Preview
        Center(
          child: GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);

              if (pickedFile != null) {
                setState(() {
                  selectedImage = File(pickedFile.path);
                });
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                LmbProfilePicture(
                  localFile: selectedImage,
                  networkUrl: profilePictureUrl,
                  radius: 80
                ),
                const Text(
                  'Tap to change',
                  style: TextStyle(
                    color: LmbColors.brand
                  ),
                ),
              ],
            )
          )
        ),
        const SizedBox(height: 32),

        // NOTE: Save Button
        LmbPrimaryButton(
          text: 'Save',
          isLoading: isActionLoading,
          onPressed: () async {
            if (selectedImage == null) {
              WindowProvider.toastSuccess(context, 'Profile picture uunchanged');
              Navigator.pop(context); 
              return;
            }
            setState(() => isActionLoading = true);
            try {
              LmbUser? userData = await LmbLocalStorage.getValue<LmbUser>(
                "user_data",
                fromJson: (json) => LmbUser.fromJson(json),
              );
              if (userData == null) {
                WindowProvider.toastError(context, 'Something went wrong');
                return;
              }
              await SbStorageService.instance.uploadImage(
                bucket: "profile-pictures",
                imageFile: selectedImage!,
                path: '${userData.nik}.jpg',
              );
              WindowProvider.toastSuccess(context, 'Profile picture updated successfully');
              AuthenticatorService.instance.forceReloadUserDataStream();
              Navigator.pop(context); 
            } catch (e) {
              WindowProvider.toastError(context, 'Failed to upload: ${e.toString()}');
            } finally {
              setState(() => isActionLoading = false);
            }
          },
          isFullWidth: true,
        ),
        const SizedBox(height: 128),
      ],
    );
  }
}