import 'dart:convert';

/// =======================================================
/// UNIVERSAL DATA CONTAINER
/// =======================================================
/// Envuelve estructuras dinámicas (Map o List) con acceso seguro
/// y helpers para serialización, clonación y manipulación.
class Data {
  dynamic _items;

  /// Crea un contenedor de datos desde:
  /// - String JSON
  /// - otro Data
  /// - Map o List
  Data([dynamic data]) {
    if (data != null) {
      if (data is String) {
        _items = json.decode(data);
      } else if (data is Data) {
        _items = data._items;
      } else {
        _items = data;
      }
    } else {
      _items = <String, dynamic>{};
    }
  }

  /// Acceso tipo map[key]
  dynamic operator [](dynamic key) => _items[key];

  /// Asignación tipo map[key] = value
  void operator []=(dynamic key, dynamic value) {
    if (_items is Map) {
      (_items as Map)[key] = value;
    }
  }

  /// Longitud del contenido
  int get length => _items is Map || _items is List ? _items.length : 0;

  /// Incluye un map dentro del contenedor actual
  void include(Map<String, Object?> data) {
    if (_items is Map<String, dynamic>) {
      _items.addAll(data);
    }
  }

  /// Mapea un campo tipo lista a una lista de T
  List<T> map<T>(String field, T Function(dynamic e) predicate) {
    final list = (_items is Map && _items[field] is List)
        ? (_items[field] as List)
        : <dynamic>[];
    return list.map(predicate).toList();
  }

  /// Convierte el contenido (o un campo específico) en lista de T
  List<T> list<T>(T Function(dynamic data) predicate, {String? field}) {
    final list = (field != null && _items is Map && _items[field] is List)
        ? (_items[field] as List)
        : (_items is List ? _items as List : <dynamic>[]);
    return list.map(predicate).toList();
  }

  /// Clona profundamente el contenido
  Data clone() => Data(jsonDecode(toJson()));

  /// Indica si el contenido es una lista
  bool isList() => _items is List;

  /// Indica si el contenedor está vacío
  bool get isEmpty =>
      _items == null ||
      (_items is Map && _items.isEmpty) ||
      (_items is List && _items.isEmpty);

  /// Imprime contenido formateado en consola (por partes)
  void $print() {
    final pattern = RegExp('.{1,800}');
    for (final match in pattern.allMatches(toJson(pretty: true))) {
      print(match.group(0));
    }
  }

  /// Devuelve los datos en formato Map limpio
  dynamic toObjects() {
    if (_items is Map) {
      return Map<String, dynamic>.from(_items);
    } else if (_items is List) {
      return List.from(_items);
    }
    return _items;
  }

  /// Elimina una propiedad por nombre
  void remove(String field) {
    if (_items is Map) {
      (_items as Map).remove(field);
    }
  }

  /// Convierte el contenido a JSON
  String toJson({bool pretty = false}) {
    if (_items == null) return '{}';
    final encoder = pretty
        ? const JsonEncoder.withIndent('  ')
        : const JsonEncoder();
    return encoder.convert(toObjects());
  }

  @override
  String toString() => _items.toString();
}
