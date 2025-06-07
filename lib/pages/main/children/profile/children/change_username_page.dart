// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/text_field.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/logic/input_validator.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';

class ChangeUsernamePage extends StatefulWidget {
  final String currentName;

  const ChangeUsernamePage({
    super.key, 
    required this.currentName
  });

  @override
  State<ChangeUsernamePage> createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage> {
  final usernameController = TextEditingController();
  bool isActionLoading = false;

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.currentName;
  }

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      isScrollable: true,
      title: "Change Username",
      children: [
        // NOTE: Bagian header
        const Text('Use real name to ease verification. This name will be shown in some pages.'),
        const SizedBox(height: 16),

        // NOTE: Bagian form utama
        LmbTextField(
          hint: 'Username',
          controller: usernameController,
          inputType: TextInputType.name,
        ),
        const SizedBox(height: 32),

        // NOTE: Bagian tombol
        LmbPrimaryButton(
          text: 'Confirm',
          isLoading: isActionLoading,
          isFullWidth: true,
          onPressed: () async {
            final username = usernameController.text.trim();
            final usernameError = InputValidator.empty(username, "Name", minLen: 4, maxLen: 64);
            if (usernameError != null) {
              WindowProvider.toastError(context, usernameError);
              return;
            }

            setState(() => isActionLoading = true);
            if (await AuthenticatorService.instance.handleChangeName(context, username)) {
              WindowProvider.toastSuccess(context, 'Username successfully updated');
              Navigator.pop(context);
            }
            setState(() => isActionLoading = false);
          },
        ),

        const SizedBox(height: 128),
      ]
    );
  }
}