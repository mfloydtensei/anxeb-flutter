import 'package:anxeb_flutter/anxeb.dart';

class GoogleAuth extends AuthProvider {
  final GoogleSignIn _google;

  GoogleAuth(Application application)
      : _google = GoogleSignIn(
          signInOption: application.settings.auths.google.signInOption,
          scopes: application.settings.auths.google.scopes,
          hostedDomain: application.settings.auths.google.hostedDomain,
          clientId: application.settings.auths.google.clientId,
        ),
        super(application);

  @override
  Future<void> logout() async {
    await _google.signOut();
  }

  @override
  Future<AuthResultModel?> login({bool silent = false}) async {
    try {
      GoogleSignInAccount? profileData;

      // 🔹 Si hay sesión previa y el login es silencioso
      if (silent && (await _google.isSignedIn())) {
        profileData = _google.currentUser ?? await _google.signInSilently();
      } else {
        // 🔹 Forzamos inicio de sesión manual
        profileData = await _google.signIn();
      }

      // 🔹 Si el usuario canceló o no se autenticó
      if (profileData == null) {
        return null;
      }

      // 🔹 Obtenemos los tokens
      final authData = await profileData.authentication;

      // 🔹 Procesamos el nombre y la foto
      final displayNameParts =
          (profileData.displayName ?? '').split(' ').where((x) => x.isNotEmpty).toList();

      final photoUrl = profileData.photoUrl;
      final photo = (photoUrl != null && photoUrl.contains('='))
          ? photoUrl.substring(0, photoUrl.lastIndexOf('='))
          : photoUrl;

      // 🔹 Construimos el resultado
      final result = AuthResultModel()
        ..id = profileData.id
        ..firstNames = displayNameParts.isNotEmpty ? displayNameParts.first : ''
        ..lastNames =
            displayNameParts.length > 1 ? displayNameParts.sublist(1).join(' ') : ''
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
