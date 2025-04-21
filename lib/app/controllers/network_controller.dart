import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final isConnected = true.obs;
  final errorMessage = RxString('');
  final bool showError = false;

  String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'Unable to connect to the server. Please check your internet connection.';
    } else if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timed out. Please try again.';
        case DioExceptionType.sendTimeout:
          return 'Unable to send data. Please check your connection.';
        case DioExceptionType.receiveTimeout:
          return 'Unable to receive data. Please try again.';
        case DioExceptionType.badResponse:
          return 'Server error (${error.response?.statusCode}). Please try again later.';
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return 'Unable to connect to the server. Please check your internet connection.';
          }
          return 'An unexpected error occurred. Please try again.';
        default:
          return 'Network error occurred. Please try again.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _startMonitoring();
  }

  Future<void> _checkInitialConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void _startMonitoring() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    isConnected.value = result != ConnectivityResult.none;
    if (!isConnected.value) {
      errorMessage.value = 'No internet connection. Please check your network settings.';
      Get.toNamed('/network');
    } else if (Get.currentRoute == '/network') {
      errorMessage.value = '';
      Get.back();
    }
  }

  void handleError(dynamic error) {
    errorMessage.value = getErrorMessage(error);
    if (!Get.isDialogOpen!) {
      Get.toNamed('/network');
    }
  }
}
