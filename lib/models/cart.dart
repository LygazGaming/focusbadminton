import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;
}

class Cart {
  final List<CartItem> items;

  Cart({List<CartItem>? items}) : items = items ?? [];

  double get total => items.fold(0, (sum, item) => sum + item.total);

  void addItem(Product product) {
    final existingItem = items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity == 0) {
      items.add(CartItem(product: product));
    } else {
      existingItem.quantity++;
    }
  }

  void removeItem(Product product) {
    items.removeWhere((item) => item.product.id == product.id);
  }

  void updateQuantity(Product product, int quantity) {
    final existingItem = items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (quantity <= 0) {
      items.remove(existingItem);
    } else {
      existingItem.quantity = quantity;
    }
  }

  void clear() {
    items.clear();
  }

  bool get isEmpty => items.isEmpty;
}
