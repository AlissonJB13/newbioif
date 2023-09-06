import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static ValueNotifier<Brightness> tema = ValueNotifier(Brightness.light);

  static setTheme() {
    tema.value = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    changeStatusNavigationBar();
  }

  static changeStatusNavigationBar() {
    bool isDark = tema.value == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarColor:
          isDark ? Color(0x767676) : const Color.fromARGB(255, 04, 82, 37),
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor:
          isDark ? Color(0x767676) : const Color(0xFFFAFAFA),
    ));
  }
}
