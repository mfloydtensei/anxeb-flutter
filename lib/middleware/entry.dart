library anxeb_flutter;

import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// =======================================================
/// ENTRY SCREEN (single-screen apps)
/// =======================================================
class EntryScreen extends StatelessWidget {
  final ScreenWidget home;
  final ThemeData? theme;

  const EntryScreen({
    super.key,
    required this.home,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final app = home.application;
    final isLocalized = app.localization != null;
    final localizationDelegate = app.localization;

    return MaterialApp(
      home: home,
      navigatorObservers: app.settings.analytics.available == true
          ? [app.analytics!.observer]
          : [],
      theme: theme ??
          ThemeData(
            primaryColor: app.settings.colors.primary,
            colorScheme: ColorScheme.light(
              primary: app.settings.colors.primary,
              secondary: app.settings.colors.secudary,
              secondaryContainer: app.settings.colors.navigation,
              onSecondary: Colors.white,
              brightness: Brightness.light,
            ),
            fontFamily: 'Montserrat',
          ),
      localizationsDelegates: isLocalized
          ? [
              localizationDelegate!,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ]
          : const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
      supportedLocales: isLocalized
          ? localizationDelegate!.supportedLocales
          : const [
              Locale('en'),
              Locale('es'),
              Locale.fromSubtags(languageCode: 'es'),
            ],
      locale: localizationDelegate?.currentLocale,
      routes: {
        '/${home.name}': (BuildContext context) => home,
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

/// =======================================================
/// ENTRY PAGE (multi-page router-based apps)
/// =======================================================
class EntryPage<A extends Application, M extends PageInfo<A, M>> extends StatefulWidget{
  final ThemeData? theme;
  final String? title;
  final PageMiddleware<A, M> middleware;
  final List<PageWidget Function()>? pages;
  final List<PageContainer<A, M> Function()>? containers;
  final PageWidget Function()? errorPage;

  const EntryPage({
    super.key,
    required this.middleware,
    this.pages,
    this.containers,
    this.theme,
    this.title,
    this.errorPage,
  });

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    // Inicializa GoRouter usando las páginas del middleware
    _router = GoRouter(
      routes: [
        for (final pageBuilder in widget.pages ?? [])
          GoRoute(
            path: '/${pageBuilder().name}',
            builder: (context, state) => pageBuilder(),
          ),
      ],
      errorBuilder: (context, state) =>
          widget.errorPage?.call() ??
          Scaffold(
            body: Center(child: Text('Error: ${state.error}')),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = application;
    final isLocalized = app.localization != null;
    final localizationDelegate = app.localization;

    return MaterialApp.router(
      routerConfig: _router,
      title: widget.title ?? app.title,
      theme: widget.theme ??
          ThemeData(
            primaryColor: app.settings.colors.primary,
            colorScheme: ColorScheme.light(
              primary: app.settings.colors.primary,
              secondary: app.settings.colors.secudary,
              secondaryContainer: app.settings.colors.navigation,
              onSecondary: Colors.white,
              brightness: Brightness.light,
            ),
            fontFamily: 'Montserrat',
          ),
      localizationsDelegates: isLocalized
          ? [
              localizationDelegate!,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ]
          : const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
      supportedLocales: isLocalized
          ? localizationDelegate!.supportedLocales
          : const [
              Locale('en'),
              Locale('es'),
              Locale.fromSubtags(languageCode: 'es'),
            ],
      locale: localizationDelegate?.currentLocale,
      debugShowCheckedModeBanner: false,
    );
  }

  Application get application => widget.middleware.application;
}
