import 'package:latlong2/latlong.dart';

class SelectedLocation {
  final LatLng coordinates;
  final String address;
  final String cep;
  final String logradouro;
  final String cidade;
  final String bairro;

  SelectedLocation({
    required this.coordinates,
    required this.address,
    required this.cep,
    required this.logradouro,
    required this.cidade,
    required this.bairro,
  });
}
