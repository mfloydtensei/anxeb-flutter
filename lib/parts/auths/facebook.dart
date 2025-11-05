import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart' as FB;

class FacebookAuth extends AuthProvider {
  final FB.FacebookAuth _facebook = FB.FacebookAuth.instance;

  FacebookAuth(Application application) : super(application);

  @override
  Future<void> logout() async {
    await _facebook.logOut();
  }

  @override
  Future<AuthResultModel?> login({bool silent = false}) async {
    try {
      FB.AccessToken? session;

      // 🔹 Intento silencioso (si ya hay sesión activa)
      final existingToken = await _facebook.accessToken;
      if (silent && existingToken != null) {
        session = existingToken;
      } else {
        // 🔹 Forzamos login manual
        final auth = await _facebook.login(permissions: ['email']);

        if (auth.status == FB.LoginStatus.failed) {
          throw Exception(auth.message ?? 'Facebook login failed.');
        }

        if (auth.status == FB.LoginStatus.success) {
          session = auth.accessToken;
        } else {
          // 🔹 Usuario canceló
          return null;
        }
      }

      if (session == null) {
        return null;
      }

      // 🔹 Solicitamos los datos del usuario desde Graph API
      final api = Api('https://graph.facebook.com/v12.0/');
      final profileData = await api.get(
        'me?fields=name,first_name,last_name,email&access_token=${session.tokenString}',
      );

      // 🔹 Construimos el resultado
      final result = AuthResultModel()
        ..id = profileData['id']
        ..firstNames = profileData['first_name']
        ..lastNames = profileData['last_name']
        ..email = profileData['email']
        ..photo =
            'https://graph.facebook.com/v12.0/me/picture?height=320&access_token=${session.tokenString}'
        ..token = session.tokenString // ✅ propiedad correcta
        ..provider = 'facebook'
        ..meta = {
          //'userId': session.userId,
         // 'expires': session.expires.toIso8601String(),
          //'permissions': session.grantedPermissions.join(','),
         // 'declinedPermissions': session.declinedPermissions.join(','),
        };

      return result;
    } catch (err, st) {
      throw Exception('Facebook login error: $err\n$st');
    }
  }
}
