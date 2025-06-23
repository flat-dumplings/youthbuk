class CartItem {
  final String name;
  final int price;
  int quantity;
  final DateTime? reservedDate;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    required this.reservedDate,
  });
}
