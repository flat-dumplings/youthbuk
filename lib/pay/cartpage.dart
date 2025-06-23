import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youthbuk/pay/models/cart_item.dart';
import 'payment_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<CartItem> cartItems = [
    CartItem(
      name: '[강내연꽃마을] 고구마 캐기 체험',
      price: 30000,
      quantity: 1,
      reservedDate: DateTime(2025, 6, 26),
    ),
    //CartItem(name: '충북 농촌 체험 프로그램 B', price: 18000, quantity: 1),
  ];

  int get totalPrice =>
      cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

  void _increaseQuantity(int index) {
    setState(() {
      cartItems[index].quantity++;
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '장바구니',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFFDFDFD),
      body:
          cartItems.isEmpty
              ? Center(
                child: Text(
                  '장바구니에 담긴 상품이 없습니다.',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              )
              : ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                itemCount: cartItems.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '예약일: ${item.reservedDate!.year}.${item.reservedDate!.month.toString().padLeft(2, '0')}.${item.reservedDate!.day.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 12.w),
                        Text(
                          '${item.price}원',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _decreaseQuantity(index),
                              icon: Icon(
                                Icons.remove_circle_outline,
                                size: 24.sp,
                              ),
                            ),
                            Text(
                              '${item.quantity}',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            IconButton(
                              onPressed: () => _increaseQuantity(index),
                              icon: Icon(Icons.add_circle_outline, size: 24.sp),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => _removeItem(index),
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '총액: $totalPrice원',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            ElevatedButton(
              onPressed:
                  cartItems.isEmpty
                      ? null
                      : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => PaymentPage(
                                  cartItems: cartItems,
                                  totalAmount: totalPrice,
                                ),
                          ),
                        );
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFA86A),
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                '주문하기',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
