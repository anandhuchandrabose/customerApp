import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../routes/app_routes.dart';
import 'design_system/typography.dart';
import 'design_system/spacing.dart';
import 'design_system/icons.dart';
import 'design_system/colors.dart';
import '../../utils/string_extensions.dart';

class AddressInputView extends GetView<LocationController> {
  const AddressInputView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: AppIcons.backIcon(),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Select Address',
          style: AppTypography.heading2.copyWith(color: AppColors.backgroundPrimary),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppSpacing.paddingL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search addresses...',
                    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMedEmphasis),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textLowEmphasis.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: AppIcons.searchIcon(),
                  ),
                  style: AppTypography.bodyMedium,
                  onChanged: (value) {
                    controller.addresses.value = controller.addresses.where((address) {
                      final name = address['addressName']?.toString().toLowerCase() ?? '';
                      final flat = address['flatHouseNo']?.toString().toLowerCase() ?? '';
                      return name.contains(value.toLowerCase()) || flat.contains(value.toLowerCase());
                    }).toList();
                  },
                ),
                AppSpacing.gapL,
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.locationPicker, arguments: {'isNewAddress': true});
                  },
                  child: Row(
                    children: [
                      AppIcons.addIcon(color: AppColors.primary),
                      AppSpacing.gapS,
                      Text(
                        'Add new address',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapL,
                Text(
                  'Saved Addresses',
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.textHighestEmphasis,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.gapM,
                Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  final addresses = controller.addresses;
                  if (addresses.isEmpty) {
                    return Text(
                      'No saved addresses found.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMedEmphasis),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      final isSelected = address['isSelected'] == true;
                      final addressId = address['addressId']?.toString() ?? '';
                      final createdAt = address['createdAt'] != null && address['createdAt'].isNotEmpty
                          ? DateTime.parse(address['createdAt']).toLocal().toString().split('.')[0]
                          : 'Unknown';
                      final receiverContact = address['phoneNumber']?.toString() ?? '';

                      return Card(
                        elevation: 2,
                        margin: AppSpacing.paddingS,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          leading: AppIcons.locationPinIcon(
                            color: isSelected ? AppColors.primary : AppColors.textMedEmphasis,
                          ),
                          title: Text(
                            address['addressName'] ?? 'Unnamed Address',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${address['flatHouseNo'] ?? ''}, ${StringExtensions(address['addressType'] as String? ?? 'Other').capitalize}',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textMedEmphasis),
                              ),
                              if (receiverContact.isNotEmpty)
                                Text(
                                  'Contact: $receiverContact',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMedEmphasis),
                                ),
                              Text(
                                'Added: $createdAt',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textLowEmphasis),
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? AppIcons.checkIcon(color: AppColors.primary)
                              : ElevatedButton(
                                  onPressed: addressId.isNotEmpty
                                      ? () {
                                          controller.setDefaultAddress(addressId);
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: addressId.isNotEmpty ? AppColors.primary : AppColors.textLowEmphasis,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Select',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.backgroundPrimary,
                                    ),
                                  ),
                                ),
                          onTap: () {
                            if (!isSelected && addressId.isNotEmpty) {
                              controller.setDefaultAddress(addressId);
                            }
                          },
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}