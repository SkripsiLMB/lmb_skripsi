import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';

class ProductCard extends StatelessWidget {
  String? thumbnailUrl;
  String name;
  double price;
  
  ProductCard({
    super.key,
    this.thumbnailUrl,
    required this.name,
    required this.price
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

      },
      child: LmbCard(
        usePadding: false,
        child: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(4),
                child: Image(
                  image: thumbnailUrl != null
                    ? NetworkImage(thumbnailUrl!)
                    : AssetImage("assets/broken_product.png"),
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  width: 120,
                  height: 80,
                ),
              ),
              SizedBox(height: 4),
              Text(
                name,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                ValueFormatter.formatPriceIDR(price),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        )
      ),
    );
  }
}