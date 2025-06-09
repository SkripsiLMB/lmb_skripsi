import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/helpers/logic/firestore_service.dart';
import 'package:lmb_skripsi/helpers/logic/sbstorage_service.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/model/lmb_product.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final List<LmbProduct> productList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProductList();
  }

  Future<void> fetchProductList() async {
    setState(() => isLoading = true);
    final result = await FirestoreService.instance.getProductList(limit: null);
    productList.clear();
    productList.addAll(result);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      title: "Products",
      children: [
        ...productList.map((product) {
          final thumbnailUrl = SbStorageService.instance.getPublicUrl("${product.id}.png", "product-thumbnail");
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LmbCard(
              isFullWidth: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 8,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(4),
                    child: 
                    Image(
                      image: NetworkImage(thumbnailUrl!),
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/broken_product.png',
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                          width: 80,
                          height: 80,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.labelMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                        ),
                        Text(
                          ValueFormatter.formatPriceIDR(product.price),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ),
          );
        }),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),

        if (!isLoading && productList.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text("No products found.")),
          ),
      ],
    );
  }
}