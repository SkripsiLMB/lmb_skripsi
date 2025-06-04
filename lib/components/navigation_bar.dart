import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';

class LmbBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const LmbBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  static const List<IconData> _icons = [
    Icons.home_outlined,
    Icons.savings_outlined,
    Icons.pie_chart_outline,
    Icons.person_outline,
  ];

  static const List<String> _labels = [
    "Home",
    "Savings",
    "Loan",
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / 4;
    final offset = itemWidth * currentIndex;

    return Container(
      height: 100,
      padding: const EdgeInsets.only(bottom: 6),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.only(top: 4),
            child: Container(
              color: LmbColors.brand,
              height: 4,
            ),
          ),

          // NOTE: Background putih
          Padding(
            padding: EdgeInsetsGeometry.only(top: 6),
            child: Container(
              color: Theme.of(context).colorScheme.background,
            ),
          ),

          // NOTE: Drop biru
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad,
            top: 0,
            left: offset,
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: 6),
              child: Container(
                alignment: Alignment.center,
                width: itemWidth,
                child: CustomPaint(
                  painter: _NavBarPainter(currentIndex),
                ),
              )
            ),
          ),
          

          // NOTE: Dot Indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutQuad,
            top: 0,
            left: offset,
            child: Container(
              width: itemWidth,
              alignment: Alignment.center,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: LmbColors.brand,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.background,
                    width: 1.5
                  )
                ),
              ),
            )
          ),

          // Nav items
          Padding(
            padding: EdgeInsetsGeometry.only(top: 12),
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (index) {
                  final isSelected = currentIndex == index;
                  return GestureDetector(
                    onTap: () => onItemSelected(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _icons[index],
                          color: isSelected
                              ? LmbColors.brand
                              : LmbColors.textLow,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _labels[index],
                          style: TextStyle(
                            color: isSelected
                                ? LmbColors.brand
                                : LmbColors.textLow,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  final int selectedIndex;

  _NavBarPainter(this.selectedIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double itemWidth = width / 4;
    final double centerX = itemWidth * selectedIndex + itemWidth / 2;

    final Path bumpPath = Path();
    bumpPath.moveTo(centerX - 28, 0);
    bumpPath.quadraticBezierTo(centerX - 25, 0, centerX - 12, 12);
    bumpPath.quadraticBezierTo(centerX, 22, centerX + 12, 12);
    bumpPath.quadraticBezierTo(centerX + 25, 0, centerX + 28, 0);
    bumpPath.close();

    final Paint bumpPaint = Paint()
      ..color = LmbColors.brand
      ..style = PaintingStyle.fill;

    canvas.drawPath(bumpPath, bumpPaint);
  }

  @override
  bool shouldRepaint(covariant _NavBarPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex;
  }
}