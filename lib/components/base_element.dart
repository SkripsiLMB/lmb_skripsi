import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';

class LmbBaseElement extends StatelessWidget {
  final List<Widget> children;
  final Widget? bottomStickyCardItem;
  final bool isScrollable;
  final bool showAppbar;
  final bool useNavbarSafeArea;
  final String? title;
  final bool showBackButton;
  final bool useLargeAppBar;

  const LmbBaseElement({
    super.key,
    required this.children,
    this.bottomStickyCardItem,
    this.isScrollable = true,
    this.showAppbar = true,
    this.useNavbarSafeArea = false,
    this.title,
    this.showBackButton = true,
    this.useLargeAppBar = false
  });

  @override
  Widget build(BuildContext context) {
    // NOTE: Template tiap page
    final content = Padding(
      padding: useNavbarSafeArea 
                ? EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                : EdgeInsets.fromLTRB(16, 12, 16, 112),
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
        appBar: showAppbar
            ? AppBar(
                automaticallyImplyLeading: showBackButton,
                title: title != null ? Text(
                  title!,
                  style: TextStyle(
                    fontSize: useLargeAppBar ? 32 : 20,
                    fontWeight: useLargeAppBar ? FontWeight.bold : FontWeight.w500,
                  ),
                ) : null,
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

        // NOTE: Ngecek harus pake bottom bar atau ngga
        bottomNavigationBar: bottomStickyCardItem != null 
          ?  Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewPadding.bottom),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    offset: Offset(0, -1),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: bottomStickyCardItem,
            )
          : null
      ),
    );
  }
}