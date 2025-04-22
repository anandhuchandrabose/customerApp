import 'package:flutter/material.dart';
import 'package:customerapp/app/views/design_system/colors.dart';

class AppIcons {
  // Navigation
  static const IconData arrowBack = Icons.arrow_back;
  static const IconData search = Icons.search;
  static const IconData mic = Icons.mic;
  static const IconData location = Icons.location_pin;
  static const IconData add = Icons.add;
  static const IconData check = Icons.check_circle;
  static const IconData phone = Icons.phone;
  static const IconData bookmark = Icons.bookmark_border;

  // Other icons (commented out for future use, not needed for address section)
  
  static const IconData home = Icons.home;
  static const IconData cart = Icons.shopping_cart;
  static const IconData profile = Icons.account_circle;
  static const IconData favorite = Icons.favorite_border;
  static const IconData favoriteFilled = Icons.favorite;
  static const IconData filter = Icons.filter_list;
  static const IconData sort = Icons.sort;
  static const IconData veg = Icons.eco;
  static const IconData nonVeg = Icons.local_dining;
  static const IconData star = Icons.star;
  static const IconData offer = Icons.local_offer;
  static const IconData arrowDown = Icons.arrow_drop_down;
  static const IconData arrowForward = Icons.arrow_forward;
  

  // Default Icon Size
  static const double defaultSize = 24.0;

  // Predefined Icon Widgets
  static Icon backIcon({Color? color, double? size}) => Icon(
        arrowBack,
        color: color ?? AppColors.textHighestEmphasis,
        size: size ?? defaultSize,
      );

  static Icon searchIcon({Color? color, double? size}) => Icon(
        search,
        color: color ?? AppColors.textMedEmphasis,
        size: size ?? defaultSize,
      );

  static Icon micIcon({Color? color, double? size}) => Icon(
        mic,
        color: color ?? AppColors.textMedEmphasis,
        size: size ?? defaultSize,
      );

  static Icon locationPinIcon({Color? color, double? size}) => Icon(
        location,
        color: color ?? AppColors.primary,
        size: size ?? defaultSize,
      );

  static Icon addIcon({Color? color, double? size}) => Icon(
        add,
        color: color ?? AppColors.primary,
        size: size ?? defaultSize,
      );

  static Icon checkIcon({Color? color, double? size}) => Icon(
        check,
        color: color ?? AppColors.primary,
        size: size ?? defaultSize,
      );

  static Icon phoneIcon({Color? color, double? size}) => Icon(
        phone,
        color: color ?? AppColors.textMedEmphasis,
        size: size ?? defaultSize,
      );

  static Icon bookmarkIcon({Color? color, double? size}) => Icon(
        bookmark,
        color: color ?? AppColors.positive,
        size: size ?? defaultSize,
      );

  // Other icon methods (commented out for future use)

  static Icon homeIcon({Color? color, double? size}) => Icon(
        home,
        color: color ?? AppColors.textMedEmphasis,
        size: size ?? defaultSize,
      );

  static Icon cartIcon({Color? color, double? size}) => Icon(
        cart,
        color: color ?? AppColors.textMedEmphasis,
        size: size ?? defaultSize,
      );

  static Icon profileIcon({Color? color, double? size}) => Icon(
        profile,
        color: color ?? AppColors.textMedEmphasis,
        size: size ?? 36,
      );

  static Icon favoriteIcon({Color? color, double? size, bool filled = false}) => Icon(
        filled ? favoriteFilled : favorite,
        color: color ?? AppColors.textMedEmphasis,
        size: size ?? defaultSize,
      );

  static Icon vegIcon({Color? color, double? size}) => Icon(
        veg,
        color: color ?? Colors.green,
        size: size ?? defaultSize,
      );

  static Icon nonVegIcon({Color? color, double? size}) => Icon(
        nonVeg,
        color: color ?? Colors.red,
        size: size ?? defaultSize,
      );
  
}