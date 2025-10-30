import 'package:anxeb_flutter/parts/auths/apple.dart';
import 'package:anxeb_flutter/parts/auths/facebook.dart';
import 'package:anxeb_flutter/parts/auths/google.dart';
import 'application.dart';
import 'model.dart';
import 'utils.dart';

/// =======================================================
/// BASE AUTH PROVIDER
/// =======================================================
abstract class AuthProvider {
  final Application application;

  const AuthProvider(this.application);

  /// Realiza logout — puede ser sobreescrito por subclases (Google, Facebook, Apple)
  Future<void> logout() async {}

  /// Inicia sesión y devuelve un modelo con los datos del usuario autenticado
  Future<AuthResultModel?> login() async => null;
}

/// =======================================================
/// AUTH RESULT MODEL
/// =======================================================
class AuthResultModel extends Model<AuthResultModel> {
  AuthResultModel([dynamic data]) : super(data);

  @override
  void init() {
    field(() => id, (v) => id = v, 'id');
    field(() => firstNames, (v) => firstNames = v, 'first_names');
    field(() => lastNames, (v) => lastNames = v, 'last_names');
    field(() => email, (v) => email = v, 'email');
    field(() => photo, (v) => photo = v, 'photo');
    field(() => token, (v) => token = v, 'token');
    field(() => provider, (v) => provider = v, 'provider');
    field(() => meta, (v) => meta = v, 'meta');
  }

  String? id;
  String? firstNames;
  String? lastNames;
  String? email;
  String? photo;
  String? token;
  String? provider;
  dynamic meta;

  @override
  String toString() =>
      Utils.convert.fromNamesToFullName(firstNames ?? '', lastNames ?? '');
}

/// =======================================================
/// AUTH PROVIDERS WRAPPER
/// =======================================================
class AuthProviders {
  late final GoogleAuth _google;
  late final FacebookAuth _facebook;
  late final AppleAuth _apple;

  AuthProviders(Application application) {
    _google = GoogleAuth(application);
    _facebook = FacebookAuth(application);
    _apple = AppleAuth(application);
  }

  GoogleAuth get google => _google;
  FacebookAuth get facebook => _facebook;
  AppleAuth get apple => _apple;

  /// Retorna el proveedor activo según el nombre (útil para manejo dinámico)
  AuthProvider? byName(String? name) {
    switch (name?.toLowerCase()) {
      case 'google':
        return _google;
      case 'facebook':
        return _facebook;
      case 'apple':
        return _apple;
      default:
        return null;
    }
  }
}
