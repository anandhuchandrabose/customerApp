import 'package:customerapp/app/views/design_system/colors.dart';
import 'package:flutter/material.dart';

class AppIcons {
  // Navigation
  static const IconData home = Icons.home;
  static const IconData cart = Icons.shopping_cart;
  static const IconData profile = Icons.account_circle;
  static const IconData search = Icons.search;

  // Actions
  static const IconData favorite = Icons.favorite_border;
  static const IconData favoriteFilled = Icons.favorite;
  static const IconData filter = Icons.filter_list;
  static const IconData sort = Icons.sort;
  static const IconData mic = Icons.mic;
  static const IconData location = Icons.location_pin;

  // Indicators
  static const IconData veg = Icons.eco;
  static const IconData nonVeg = Icons.local_dining;
  static const IconData star = Icons.star;
  static const IconData offer = Icons.local_offer;

  // Navigation Arrows
  static const IconData arrowDown = Icons.arrow_drop_down;
  static const IconData arrowBack = Icons.arrow_back;
  static const IconData arrowForward = Icons.arrow_forward;

  // Default Icon Size
  static const double defaultSize = 24.0;

  // Predefined Icon Widgets
  static Icon homeIcon({Color? color, double? size}) => Icon(
        home,
        color: color ?? Colors.black54,
        size: size ?? defaultSize,
      );

  static Icon cartIcon({Color? color, double? size}) => Icon(
        cart,
        color: color ?? Colors.black54,
        size: size ?? defaultSize,
      );

  static Icon profileIcon({Color? color, double? size}) => Icon(
        profile,
        color: color ?? Colors.black54,
        size: 36,
      );

  static Icon searchIcon({Color? color, double? size}) => Icon(
        search,
        color: color ?? Colors.black54,
        size: size ?? defaultSize,
      );

  static Icon favoriteIcon({Color? color, double? size, bool filled = false}) => Icon(
        filled ? favoriteFilled : favorite,
        color: color ?? Colors.black54,
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

      static Widget bookmarkIcon({Color? color, double? size}) {
    return Icon(
      Icons.bookmark_border,
      color: color ?? AppColors.positive,
      size: size ?? 24,
    );
  }   
      static Widget locationPinIcon({Color? color, double? size}) {
    return Icon(
      Icons.location_pin,
      color: color ?? AppColors.primary,
      size: size ?? 24,
    );
    
  }
}