import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_service.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // if a token exists, jump straight to dashboard
    return AuthService.token != null ? const RouteSettings(name: '/dashboard')
                                     : null;
  }
}