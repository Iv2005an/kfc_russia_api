API for receiving data from KFC Russia. The library has a class with static methods for retrieving data.

## Usage

Receive a `dio` response from KFC Russia with information about restaurants, and outputting the request data to the console:

```dart
import 'package:kfc_russia_api/kfc_russia_api.dart';

void main() async {
  final kfcRestaurants = await KFC.getRestaurants();
  print('kfcRestaurants: $kfcRestaurants');
}
```

Output of product data:
```dart
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

OUTPUT:
Id: 198345
Title: Green Tea large
Image URL: https://s82079.cdn.ngenix.net/nunvk035chfabj311zn6upgczg2a
```

