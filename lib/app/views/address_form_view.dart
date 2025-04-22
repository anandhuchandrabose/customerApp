import 'package:customerapp/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import 'design_system/typography.dart';
import 'design_system/spacing.dart';
import 'design_system/icons.dart';
import 'design_system/colors.dart';

class AddressFormView extends GetView<LocationController> {
  final double latitude;
  final double longitude;
  final String initialAddress;

  AddressFormView({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.initialAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController flatHouseNoController = TextEditingController();
    final TextEditingController addressNameController = TextEditingController(text: initialAddress);
    final TextEditingController directionsController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    String addressType = 'home'; // Default value, lowercase to match API

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: AppIcons.backIcon(),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add New Address',
          style: AppTypography.heading2.copyWith(color: AppColors.backgroundPrimary),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Address Details',
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textHighestEmphasis,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.gapM,
              TextField(
                controller: addressNameController,
                decoration: InputDecoration(
                  labelText: 'Address Name (e.g., Home, Office)',
                  labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMedEmphasis),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textLowEmphasis.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: AppTypography.bodyMedium,
              ),
              AppSpacing.gapM,
              TextField(
                controller: flatHouseNoController,
                decoration: InputDecoration(
                  labelText: 'Flat/House No.',
                  labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMedEmphasis),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textLowEmphasis.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: AppTypography.bodyMedium,
              ),
              AppSpacing.gapM,
              TextField(
                controller: directionsController,
                decoration: InputDecoration(
                  labelText: 'Delivery Instructions (Optional)',
                  labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMedEmphasis),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textLowEmphasis.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: AppTypography.bodyMedium,
                maxLines: 3,
              ),
              AppSpacing.gapM,
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMedEmphasis),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textLowEmphasis.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: AppIcons.phoneIcon(),
                ),
                style: AppTypography.bodyMedium,
                keyboardType: TextInputType.phone,
              ),
              AppSpacing.gapM,
              Text(
                'Address Type',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHighestEmphasis,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.gapS,
              DropdownButtonFormField<String>(
                value: addressType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textLowEmphasis.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['home', 'office', 'other'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type.capitalize ?? type,
                      style: AppTypography.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    addressType = value;
                  }
                },
              ),
              AppSpacing.gapL,
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final result = await controller.saveNewAddress(
                              flatHouseNo: flatHouseNoController.text,
                              addressName: addressNameController.text,
                              directions: directionsController.text,
                              addressType: addressType,
                              phoneNumber: phoneController.text,
                              latitude: latitude,
                              longitude: longitude,
                            );
                            if (result['success'] == true) {
                              if (!Get.isSnackbarOpen) {
                                Get.snackbar('Success', result['message'] ?? 'Address saved');
                              }
                              Get.offAllNamed(AppRoutes.addressInput);
                            } else {
                              if (!Get.isSnackbarOpen) {
                                Get.snackbar('Error', result['message'] ?? 'Failed to save address');
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      controller.isLoading.value ? 'Saving...' : 'Save Address',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.backgroundPrimary),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}