// import 'package:get/get.dart';
// import '../data/repositories/cart_repository.dart';

// class CartController extends GetxController {
//   final cartRepo = Get.find<CartRepository>();

//   var cartItems = <Map<String, dynamic>>[].obs;
//   var isLoading = false.obs;
//   // In real app, you'd have user ID from auth
//   var userId = 'myUserId';

//   Future<void> addToCart(String itemId) async {
//     try {
//       isLoading.value = true;
//       // For simplicity, let’s say quantity is always 1
//       final response = await cartRepo.addItemToCart(
//         userId: userId,
//         itemId: itemId,
//         quantity: 1,
//       );
//       if (response.statusCode == 200) {
//         Get.snackbar('Success', 'Item added to cart');
//         // Optionally refetch cart
//         fetchCartItems();
//       } else {
//         Get.snackbar('Error', 'Failed to add item');
//       }
//     } catch (e) {
//       Get.snackbar('Exception', e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> fetchCartItems() async {
//     try {
//       isLoading.value = true;
//       final response = await cartRepo.fetchCart(userId);
//       if (response.statusCode == 200) {
//         // Suppose data = [{ "itemId": ..., "quantity": ... }, ...]
//         cartItems.value =
//             (response.data as List).map((e) => e as Map<String, dynamic>).toList();
//       } else {
//         Get.snackbar('Error', 'Failed to get cart');
//       }
//     } catch (e) {
//       Get.snackbar('Exception', e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void clearCart() {}

//   void removeFromCart(int index) {}
// }
