import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

/// =======================================================
/// DISK STORAGE HANDLER
/// =======================================================
class Disk {
  SharedPreferences? _shared;

  /// Inicializa SharedPreferences si aún no se ha hecho
  Future<void> _check() async {
    _shared ??= await SharedPreferences.getInstance();
  }

  /// Guarda un valor en disco
  Future<void> store(String key, dynamic value) async {
    await _check();

    if (value is double) {
      await _shared!.setDouble(key, value);
    } else if (value is int) {
      await _shared!.setInt(key, value);
    } else if (value is String) {
      await _shared!.setString(key, value);
    } else if (value is bool) {
      await _shared!.setBool(key, value);
    } else if (value is Data) {
      await _shared!.setString(key, value.toJson());
    } else if (value == null) {
      await _shared!.remove(key);
    } else {
      await _shared!.setString(key, value.toString());
    }
  }

  /// Obtiene un valor desde disco
  Future<T?> retrieve<T>(String key) async {
    await _check();
    final value = _shared!.get(key);

    if (value == null) return null;

    if (T == Data && value is String) {
      return Data(value) as T;
    }

    return value as T?;
  }

  /// Elimina una clave del almacenamiento
  Future<void> remove(String key) async {
    await _check();
    await _shared!.remove(key);
  }

  /// Limpia todo el almacenamiento local
  Future<void> clear() async {
    await _check();
    await _shared!.clear();
  }

  /// Verifica si una clave existe
  Future<bool> exists(String key) async {
    await _check();
    return _shared!.containsKey(key);
  }
}
