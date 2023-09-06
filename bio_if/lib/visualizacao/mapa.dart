import 'package:bio_if/customizacao/customappbar.dart';
import 'package:bio_if/customizacao/themedscaffold.dart';
import 'package:bio_if/visualizacao/home.dart';
import 'especies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

//import 'package:bio_if/customizacao/apptheme.dart';

class Mapa extends StatefulWidget {
  const Mapa({Key? key}) : super(key: key);

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  final MapController _mapController = MapController();

  List<Marker> _marcadores = [];

  String? _LatLongStr = "";

  LatLng _posicaoCamera = LatLng(-26.511861, -51.984996);
  double _zoomCamera = 18.0;

  Future<bool> _checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _exibirAlertDialog(
      String statusMessage, bool showButton, bool showProgress) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress)
                CircularProgressIndicator(
                    color: Color.fromARGB(255, 4, 82,
                        37)), // Mostra o CircularProgressIndicator se showProgress for true
              SizedBox(height: 16),
              Text(statusMessage),
            ],
          ),
          actions: showButton && !showProgress
              ? [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const Home())); // Fecha o AlertDialog
                    },
                    child: const Text("OK"),
                  ),
                ]
              : null,
        );
      },
    );
  }

  _adicionarMarcador(LatLng latLng) async {
    bool isConnected = await _checkInternetConnectivity();

    if (!isConnected) {
      _exibirAlertDialog("Sem conexão com internet", true, false);
      return;
    }

    //_exibirAlertDialog("Obtendo Localização", false, true);

    List<Placemark> enderecos =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    //_exibirAlertDialog("Obtendo Localização", false, true);

    if (enderecos.isNotEmpty) {
      Placemark endereco = enderecos.first;
      String? nomeEndereco = endereco.street;
      //String? rua = endereco.thoroughfare;

      final marcador = Marker(
        width: 40,
        height: 40,
        point: latLng,
        builder: (ctx) => Container(
          child: IconButton(
            icon: Icon(Icons.location_on),
            color: Colors.red,
            iconSize: 40,
            onPressed: () {
              setState(() {
                _marcadores.removeWhere((m) =>
                    m.point.latitude == latLng.latitude &&
                    m.point.longitude == latLng.longitude);
                _LatLongStr = null;
              });
            },
          ),
        ),
      );

      setState(() {
        _marcadores.add(marcador);
        _LatLongStr =
            "$nomeEndereco\nLat: ${latLng.latitude.toStringAsFixed(6)} - Lng: ${latLng.longitude.toStringAsFixed(6)}";
        //_LatLongStr = "Lat ${latLng.latitude} - Lng ${latLng.longitude}";
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Especies(_LatLongStr.toString()),
        ),
      );
    }
  }

  _movimentarCamera() async {
    final newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _posicaoCamera = LatLng(newPosition.latitude, newPosition.longitude);
      _zoomCamera = 15.0;
    });
  }

  @override
  void initState() {
    super.initState();
    _movimentarCamera();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      tema: Brightness.light,
      appBar: CustomAppBar(title: "Adicione a Localização"),
      body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _posicaoCamera,
            zoom: _zoomCamera,
            onTap: (tapPosition, point) {
              setState(() {
                _adicionarMarcador(point);
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright')),
                ),
              ],
            ),
          ]),
    );
  }
}
