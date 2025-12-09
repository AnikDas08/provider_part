import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/favorite_controller.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavoriteController>(
      init: FavoriteController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('Favorite')),
          body: const Center(child: Text('Favorite Screen')),
        );
      },
    );
  }
}
