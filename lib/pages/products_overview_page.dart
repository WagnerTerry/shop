import 'package:flutter/material.dart';
import 'package:shop/components/product_item.dart';
import 'package:shop/data/dummy_data.dart';
import 'package:shop/models/product.dart';

class ProductsOverviewPage extends StatelessWidget {
  final List<Product> loadedProducts = dummyProducts;
  ProductsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Loja'),
        centerTitle: true,
      ),
      body: GridView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: loadedProducts.length,
          itemBuilder: (ctx, i) => ProductItem(product: loadedProducts[i]),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 elementos no grid
            childAspectRatio:
                3 / 2, // dimensão entre altura e largura no caso 1.5
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          )),
    );
  }
}
