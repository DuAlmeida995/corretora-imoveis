import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import 'package:aura_frontend/data/models/imovel_model.dart';
import 'package:aura_frontend/features/home/propriety_card.dart';
import 'package:aura_frontend/routes/app_routes.dart';

class ImoveisMapPage extends StatefulWidget {
  final List<ImovelModel> imoveis;

  const ImoveisMapPage({super.key, required this.imoveis});

  @override
  State<ImoveisMapPage> createState() => _ImoveisMapPageState();
}

class _ImoveisMapPageState extends State<ImoveisMapPage> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  bool _isLoading = true;
  LatLng _center = const LatLng(-23.5505, -46.6333);
  ImovelModel? _selectedImovel;

  @override
  void initState() {
    super.initState();
    _generateMarkers();
  }

  Future<void> _generateMarkers() async {
    List<Marker> newMarkers = [];
    List<LatLng> points = [];
    final Random random = Random();

    print(
        'DEBUG: Iniciando geocodificacao de ${widget.imoveis.length} imoveis.');

    for (var imovel in widget.imoveis) {
      String cepLimpo = imovel.cep.replaceAll(RegExp(r'[^0-9]'), '');

      if (cepLimpo.isEmpty) {
        print('DEBUG: Imovel ${imovel.matricula} sem CEP valido. Pulando.');
        continue;
      }

      final LatLng? coords = await _getCoordinatesFromCep(cepLimpo);

      if (coords != null) {
        double offsetLat = (random.nextDouble() - 0.5) * 0.0002;
        double offsetLon = (random.nextDouble() - 0.5) * 0.0002;

        final adjustedCoords =
            LatLng(coords.latitude + offsetLat, coords.longitude + offsetLon);

        points.add(adjustedCoords);
        newMarkers.add(
          Marker(
            point: adjustedCoords,
            width: 60,
            height: 60,
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImovel = imovel;
                });
              },
              child: _buildCustomPin(),
            ),
          ),
        );
        print(
            'DEBUG: Marcador adicionado para CEP $cepLimpo em $adjustedCoords');
      } else {
        print('DEBUG: Falha ao obter coordenadas para o CEP $cepLimpo');
      }

      await Future.delayed(const Duration(milliseconds: 1200));
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
        _isLoading = false;

        if (points.isNotEmpty) {
          _center = points.first;
          _mapController.move(_center, 13.0);
        }
      });
      print(
          'DEBUG: Processo finalizado. Total de marcadores: ${_markers.length}');
    }
  }

  Future<LatLng?> _getCoordinatesFromCep(String cep) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?postalcode=$cep&country=Brazil&format=json&limit=1');

      print('DEBUG: Requesting: $url');

      final response =
          await http.get(url, headers: {'User-Agent': 'AuraFrontendApp/1.0'});

      print('DEBUG: Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          print('DEBUG: Coordenada encontrada: $lat, $lon');
          return LatLng(lat, lon);
        } else {
          print('DEBUG: Resposta vazia ou formato invalido: ${response.body}');
        }
      } else {
        print('DEBUG: Erro HTTP na requisicao: ${response.body}');
      }
    } catch (e) {
      print('DEBUG: Excecao ao buscar CEP $cep: $e');
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 12.0,
              onTap: (_, __) => setState(() => _selectedImovel = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.aura_imobiliaria',
                tileBuilder: isDark ? _darkModeTileBuilder : null,
              ),
              MarkerLayer(markers: _markers),
              Positioned(
                top: 50,
                left: 20,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: backgroundColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                  onPressed: () => Navigator.pop(context),
                  child: Icon(CupertinoIcons.back, color: primaryColor),
                ),
              ),
              if (_isLoading)
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: backgroundColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ]),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CupertinoActivityIndicator(),
                        const SizedBox(width: 8),
                        Text("Buscando por CEP...",
                            style:
                                TextStyle(fontSize: 12, color: primaryColor)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (_selectedImovel != null)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.propertyDetails,
                      arguments: _selectedImovel);
                },
                child: SizedBox(
                  height: 370,
                  child: PropertyCard(
                    imovel: _selectedImovel!,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.propertyDetails,
                          arguments: _selectedImovel);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomPin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ]),
          child: const Icon(CupertinoIcons.house_fill,
              color: Colors.white, size: 16),
        ),
        ClipPath(
          clipper: _TriangleClipper(),
          child: Container(
            color: Colors.black,
            width: 10,
            height: 6,
          ),
        ),
      ],
    );
  }

  Widget _darkModeTileBuilder(
      BuildContext context, Widget tileWidget, TileImage tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -1,
        0,
        0,
        0,
        255,
        0,
        -1,
        0,
        0,
        255,
        0,
        0,
        -1,
        0,
        255,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: tileWidget,
    );
  }
}

class _TriangleClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(Size size) {
    final path = ui.Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<ui.Path> oldClipper) => false;
}
