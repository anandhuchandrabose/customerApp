// lib/app/views/not_found_view.dart

import 'package:flutter/material.dart';

class NotFoundView extends StatelessWidget {
  const NotFoundView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '404 - Page Not Found',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
