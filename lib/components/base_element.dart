import 'package:flutter/material.dart';

class LmbBaseElement extends StatelessWidget {
  final List<Widget> children;
  final bool isScrollable;
  final bool showNavbar;
  final String? title;
  final bool showBackButton;

  const LmbBaseElement({
    super.key,
    required this.children,
    this.isScrollable = true,
    this.showNavbar = true,
    this.title,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // NOTE: Template tiap page
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );

    return GestureDetector(
      // NOTE: Tutup keyboard kalo pencet diluar textfield
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        resizeToAvoidBottomInset: true,

        // NOTE: Ngecek harus pake navbar, backbutton, title atau tidak
        appBar: showNavbar
            ? AppBar(
                automaticallyImplyLeading: showBackButton,
                title: title != null ? Text(title!) : null,
              )
            : null,

        // NOTE: Ngecek harus pake scrollable atau centered scrollable
        body: isScrollable
            ? SingleChildScrollView(child: content)
            : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    reverse: true,
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: content,
                      ),
                    ),
                  );
                },
              ),
            ),
      ),
    );
  }
}