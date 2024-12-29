// import 'package:dio/dio.dart';
// import 'package:http/src/response.dart';
// import '../services/api_service.dart';

// class CartRepository {
//   final ApiService api;

//   CartRepository({required this.api});

//   // For example: add item to cart
//   Future<Response> addItemToCart({
//     required String userId,
//     required String itemId,
//     required int quantity,
//   }) async {
//     // POST /cart
//     final response = await api.post('/cart', body: {
//       'userId': userId,
//       'itemId': itemId,
//       'quantity': quantity,
//     });
//     return response;
//   }

//   // For example: fetch cart items
//   Future<Response> fetchCart(String userId) async {
//     // GET /cart?userId=xxx
//     final response = await api.get('/cart', queryParams: {
//       'userId': userId,
//     });
//     return response;
//   }

//   // More cart operations as needed
// }
