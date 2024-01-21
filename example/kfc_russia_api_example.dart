import 'package:kfc_russia_api/kfc_russia_api.dart';

void main() async {
  final kfcMenuOfDefaultRestaurant = await KFC.getMenu();

  final menuData =
      kfcMenuOfDefaultRestaurant.data?['value'] as Map<String, dynamic>;

  final products = menuData['products'] as Map<String, dynamic>;

  final product = products.values.first;
  print("""Id: ${product['productId']}
Title: ${product['translation']['en']['title']}
Image URL: ${await KFC.getImageUrl(product['media']['image'])}""");
}
