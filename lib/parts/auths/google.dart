import 'package:anxeb_flutter/anxeb.dart';
import 'package:google_sign_in/google_sign_in.dart' as g;

class GoogleAuth extends AuthProvider {
  final g.GoogleSignIn _google;

  GoogleAuth(Application application)
      : _google = g.GoogleSignIn(
          scopes: const ['email', 'profile'],
          // Estos campos ya no son obligatorios ni usados directamente,
          // se configuran automáticamente desde google-services.json / GoogleService-Info.plist
          // hostedDomain: application.settings.auths.google.hostedDomain,
          // clientId: application.settings.auths.google.clientId,
        ),
        super(application);

  @override
  Future<void> logout() async {
    try {
      await _google.signOut();
      await _google.disconnect();
    } catch (_) {
      // Ignora errores silenciosamente (por ejemplo si el usuario no tenía sesión activa)
    }
  }

  @override
  Future<AuthResultModel?> login({bool silent = false}) async {
    try {
      g.GoogleSignInAccount? profileData;

      // 🔹 Intento silencioso (si el usuario ya tiene sesión)
      if (silent) {
        profileData = await _google.signInSilently();
      }

      // 🔹 Si no hay sesión o silent falló, fuerza inicio manual
      profileData ??= await _google.signIn();

      // 🔹 Si el usuario canceló el login
      if (profileData == null) return null;

      // 🔹 Tokens de autenticación
      final authData = await profileData.authentication;

      // 🔹 Nombre y foto
      final displayNameParts = (profileData.displayName ?? '')
          .split(' ')
          .where((x) => x.isNotEmpty)
          .toList();

      final photoUrl = profileData.photoUrl;
      final photo = (photoUrl != null && photoUrl.contains('='))
          ? photoUrl.substring(0, photoUrl.lastIndexOf('='))
          : photoUrl;

      // 🔹 Resultado estructurado
      final result = AuthResultModel()
        ..id = profileData.id
        ..firstNames = displayNameParts.isNotEmpty ? displayNameParts.first : ''
        ..lastNames = displayNameParts.length > 1
            ? displayNameParts.sublist(1).join(' ')
            : ''
        ..email = profileData.email
        ..photo = photo
        ..token = authData.idToken
        ..provider = 'google'
        ..meta = {
          'serverAuthCode': profileData.serverAuthCode,
          'accessToken': authData.accessToken,
        };

      return result;
    } catch (err, st) {
      throw Exception('Google login error: $err\n$st');
    }
  }
}
