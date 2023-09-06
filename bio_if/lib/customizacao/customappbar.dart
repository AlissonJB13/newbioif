import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color.fromARGB(255, 4, 82, 37) // Cor do AppBar no tema claro
          : const Color(0xFF28372F), // Cor do AppBar no tema escuro
      // Outras configurações do AppBar, como ícones, ações, etc.
    );
  }
}
