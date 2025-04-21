import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/network_controller.dart';

class NetworkView extends GetView<NetworkController> {
  const NetworkView({super.key});

  Widget _buildErrorIcon() {
    return const Icon(
      Icons.error_outline,
      size: 100,
      color: Colors.red,
    );
  }

  Widget _buildNoConnectionIcon() {
    return const Icon(
      Icons.signal_wifi_off,
      size: 100,
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => controller.errorMessage.value.contains('No internet')
                  ? _buildNoConnectionIcon()
                  : _buildErrorIcon()),
              const SizedBox(height: 20),
              Obx(() => Text(
                    controller.errorMessage.value.split('.').first,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 10),
              Obx(() => Text(
                    controller.errorMessage.value.contains('.')
                        ? controller.errorMessage.value.split('.').skip(1).join('.')
                        : '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  )),
              const SizedBox(height: 20),
              Obx(() => controller.isConnected.value
                  ? ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Back to App'),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.forceAppUpdate();
                      },
                      child: const Text('Retry'),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
