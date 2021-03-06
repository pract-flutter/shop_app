import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavorite(String token, String userId) async {
    final oldStatus = isFavorite;
    this.isFavorite = !isFavorite;
    notifyListeners();

    final url =
        'https://hg-flutter-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';

    final res = await http.put(url, body: json.encode(isFavorite));

    if (res.statusCode >= 400) {
      _setFavValue(oldStatus);
      throw HttpException('Could not update');
    }
  }
}
