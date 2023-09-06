import 'package:bio_if/customizacao/customappbar.dart';
import 'package:flutter/material.dart';
import 'apptheme.dart'; // Importe o arquivo que define o AppTheme

class ThemedScaffold extends StatefulWidget {
  final Brightness tema;
  final CustomAppBar appBar;
  final Widget body;

  const ThemedScaffold({
    required this.tema,
    required this.appBar,
    required this.body,
  });

  @override
  _ThemedScaffoldState createState() => _ThemedScaffoldState();
}

class _ThemedScaffoldState extends State<ThemedScaffold>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    AppTheme.setTheme();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    AppTheme.setTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTheme.tema,
      builder: (BuildContext context, Brightness appTheme, _) {
        return Theme(
          data: ThemeData(
            brightness: appTheme,
            // Defina outras configurações de tema aqui, se necessário
          ),
          child: Scaffold(
            appBar: widget.appBar,
            body: widget.body,
          ),
        );
      },
    );
  }
}
