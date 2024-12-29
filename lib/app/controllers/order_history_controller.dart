import 'package:get/get.dart';

class OrderHistoryController extends GetxController {
  // Example past orders. In a real app, you'd fetch from backend.
  var orders = <String>['Past Order 1', 'Past Order 2'].obs;
}
