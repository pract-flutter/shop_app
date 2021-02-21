import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    const url = 'https://hg-flutter-default-rtdb.firebaseio.com/orders.json';

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((id, data) {
        loadedOrders.add(OrderItem(
          id: id,
          amount: data['amount'],
          dateTime: DateTime.parse(data['dateTime']),
          products: (data['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price']),
              )
              .toList(),
        ));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://hg-flutter-default-rtdb.firebaseio.com/orders.json';

    final timestamp = DateTime.now();
    final res = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'price': cp.price,
                  'quantity': cp.quantity,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(res.body)['name'],
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
