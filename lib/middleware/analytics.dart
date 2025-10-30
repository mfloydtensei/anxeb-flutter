import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'device.dart';
import 'scope.dart';

class Analytics {
  Scope? _scope;
  String? _token;
  late final FirebaseAnalytics _analytics;
  late final FirebaseMessaging _messaging;
  late final FirebaseAnalyticsObserver _observer;
  Function(String token)? _onToken;
  Function(RemoteMessage message, MessageEventType event)? _onMessage;
  Function(RemoteMessage message, MessageEventType event)? _onMessageGlobal;
  final List<RemoteMessage> notifications = [];

  Analytics();

  /// Inicializa Firebase y los listeners de mensajería
  Future<void> init({
    Function(RemoteMessage message, MessageEventType event)? onMessage,
  }) async {
    _onMessageGlobal = onMessage;

    try {
      await Firebase.initializeApp();

      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);
      _messaging = FirebaseMessaging.instance;

      reset();

      _token = await _messaging.getToken();

      if (Device.isIOS) {
        await _messaging.requestPermission();
      }

      _messaging.onTokenRefresh.listen((token) {
        _token = token;
        _onToken?.call(_token!);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleMessage(message, MessageEventType.none);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessage(message, MessageEventType.resume);
      });
    } catch (err) {
      print('Analytics init error: $err');
    }
  }

  void reset() {
    _onToken = null;
    _onMessage = null;
  }

  void setup({Scope? scope}) {
    _scope = scope;
    if (_scope?.key != null) {
      firebase.logEvent(
        name: 'view_navigation',
        parameters: {'name': _scope!.key},
      );
    }
  }

  Future<void> log(String name, {Map<String, dynamic>? params}) {
    return firebase.logEvent(name: name, parameters: params);
  }

  Future<void> property(String name, String value) {
    return firebase.setUserProperty(name: name, value: value);
  }

  Future<void> setUserId(String id) {
    return firebase.setUserId(id: id);
  }

  Future<void> login() => firebase.logEvent(name: 'login');

  Future<void> logout() => firebase.logEvent(name: 'logout');

  Future<void> signUp() => firebase.logEvent(name: 'sign_up');

  void configure({
    Function(String token)? onToken,
    Function(RemoteMessage message, MessageEventType event)? onMessage,
  }) {
    _onToken = onToken;
    _onMessage = onMessage;
  }

  void _handleMessage(RemoteMessage message, MessageEventType event) {
    final notification = message.notification;

    final title = notification?.title;
    final body = notification?.body;

    notifications.add(message);

    if (_scope?.mounted == true && title != null && body != null) {
      _scope!.alerts.notification(title, message: body).show();
    }

    _onMessageGlobal?.call(message, event);
    _onMessage?.call(message, event);
  }

  String? get token => _token;

  FirebaseAnalytics get firebase => _analytics;

  FirebaseMessaging get messaging => _messaging;

  FirebaseAnalyticsObserver get observer => _observer;
}

enum MessageEventType { none, resume }
