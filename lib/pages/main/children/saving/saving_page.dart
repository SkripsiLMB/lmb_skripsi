import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/enum/lmb_saving_type.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/pages/main/children/saving/children/deposit_page.dart';

class SavingPage extends StatefulWidget {
  const SavingPage({super.key});

  @override
  State<SavingPage> createState() => _SavingPageState();
}

class _SavingPageState extends State<SavingPage> {
  final Map<LmbSavingType, int> savings = {
    LmbSavingType.mandatory: 2000000,
    LmbSavingType.principal: 1000000,
    LmbSavingType.voluntary: 500000,
  };

  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      title: "Saving",
      useLargeAppBar: true,
      showBackButton: false,
      usePadding: false,
      children: [
        // NOTE: Total saving card
        Container(
          padding: const EdgeInsets.only(top: 12),
          height: 120,
          child: PageView.builder(
            itemCount: savings.length,
            controller: _pageController,
            physics: const PageScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final entry = savings.entries.elementAt(index);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: LmbCard(
                  isFullWidth: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        entry.key.label,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        ValueFormatter.formatPriceIDR(entry.value),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // NOTE: Idikator index
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              savings.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 12 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),

        // NOTE: Tombol deposit
        Padding(
          padding: const EdgeInsets.all(16),
          child: LmbPrimaryButton(
            text: "Deposit",
            isFullWidth: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DepositPage()),
              );
            },
          ),
        ),
      ],
    );
  }
}