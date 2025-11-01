import 'package:anxeb_flutter/anxeb.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuth extends AuthProvider {
  final String fetchCallbackRoute;
  final String Function() nonce;
  final Api api;

  AppleAuth(Application application)
      : fetchCallbackRoute = application.settings.auths.apple.fetchCallbackRoute,
        nonce = application.settings.auths.apple.nonce,
        api = application.settings.auths.apple.api ?? application.api,
        super(application);

  @override
  Future<void> logout() async {
    // Apple Sign-In no maneja sesión persistente en el dispositivo.
    // Aquí podrías limpiar tokens o llamar a tu backend si fuera necesario.
    return;
  }

  @override
  Future<AuthResultModel?> login({bool silent = false}) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        nonce: nonce.call(),
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 🔹 Enviamos los datos al backend configurado
      final response = await api.post(fetchCallbackRoute, {
        'identifier': credential.userIdentifier,
        'first_name': credential.givenName,
        'last_name': credential.familyName,
        'email': credential.email,
        'token': credential.identityToken,
        'code': credential.authorizationCode,
      });

      final info = response['info'] ?? {};

      // 🔹 Construimos el resultado de autenticación
      final result = AuthResultModel()
        ..id = credential.userIdentifier
        ..firstNames = credential.givenName ?? info['first_name']
        ..lastNames = credential.familyName ?? info['last_name']
        ..email = credential.email ?? info['email']
        ..photo = null
        ..token = credential.identityToken
        ..provider = 'apple'
        ..meta = {
          'state': credential.state,
          'authorizationCode': credential.authorizationCode,
        };

      return result;
    } on SignInWithAppleAuthorizationException catch (err) {
      // 🔹 Manejo específico de errores de Apple
      if (err.code == AuthorizationErrorCode.canceled ||
          err.code == AuthorizationErrorCode.unknown) {
        return null;
      }
      rethrow;
    } catch (err) {
      // 🔹 Manejo genérico de errores
      rethrow;
    }
  }
}
