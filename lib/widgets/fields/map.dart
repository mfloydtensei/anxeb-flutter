import 'dart:async';
import 'dart:math';
import '../../middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../middleware/utils.dart';

class MapFieldValue {
  double? radius;
  double? zoom;
  Color? color;
  LatLng? location;

  MapFieldValue({
    double? latitude,
    double? longitude,
    this.radius,
    this.zoom,
    this.color,
  }) {
    if (latitude != null && longitude != null) {
      location = LatLng(latitude, longitude);
    }
  }

  void setLocation(double latitude, double longitude) {
    location = LatLng(latitude, longitude);
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': location?.latitude,
      'longitude': location?.longitude,
      'radius': radius,
      'zoom': zoom,
      'color': color != null ? Utils.convert.fromColorToHex(color!) : null,
    };
  }
}

class MapFieldController {
  void Function(String lookup)? _query;
  void Function()? _refresh;
  bool _initialized = false;

  void _init({
    required void Function(String lookup) query,
    required void Function() refresh,
  }) {
    _query = query;
    _refresh = refresh;
    _initialized = true;
  }

  void query(String lookup) => _query?.call(lookup);
  void refresh() => _refresh?.call();
}

class MapField extends FieldWidget<MapFieldValue, MapField> {
  final double height;
  final String marketImageAsset;
  final Future<MapFieldValue?> Function(String text)? onLookup;
  final String? apiKey;
  final String? initialQuery;
  final String? queryLanguage;
  final MapFieldController? controller;

   MapField({
    required Scope scope,
    required String name,
    super.key,
    String? group,
    String? label,
    IconData? icon,
    EdgeInsets? margin,
    EdgeInsets? padding,
    bool readonly = false,
    bool visible = true,
    ValueChanged<MapFieldValue?>? onSubmitted,
    ValueChanged<MapFieldValue?>? onApplied,
    ValueChanged<MapFieldValue?>? onChanged,
    GestureTapCallback? onTab,
    GestureTapCallback? onBlur,
    GestureTapCallback? onFocus,
    FormFieldValidator<MapFieldValue?>? validator,
    MapFieldValue? Function(dynamic value)? parser,
    FieldFocusType? focusType,
    Future<MapFieldValue?> Function()? fetcher,
    Function(MapFieldValue?)? applier,
    FieldWidgetTheme? theme,
    this.onLookup,
    this.height = 250,
    required this.marketImageAsset,
    this.apiKey,
    this.initialQuery,
    this.queryLanguage,
    this.controller,
  }) : super(
          scope: scope,
          name: name,
          group: group,
          label: label,
          icon: icon,
          margin: margin,
          padding: padding,
          readonly: readonly,
          visible: visible,
          onSubmitted: onSubmitted,
          onApplied: onApplied,
          onChanged: onChanged,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          validator: validator,
          parser: parser,
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
        );

  @override
  Field<MapFieldValue, MapField> createState() => _MapFieldState();
}

class _MapFieldState extends Field<MapFieldValue, MapField> {
  GoogleMapController? _controller;
  BitmapDescriptor? _pointer;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  GoogleGeocodingApi? _api;
  late MarkerId _mainMarkerId;
  late CircleId _mainCircleId;
  late MapFieldValue _default;
  bool _fetchWhenControllerAvailable = false;
  late int _tick;

  @override
  void init() {
    _tick = widget.scope.tick;
    _api = GoogleGeocodingApi(widget.apiKey ?? '', isLogged: false);
    _mainMarkerId = const MarkerId('main');
    _mainCircleId = const CircleId('main');
    _default = MapFieldValue(latitude: 18.5, longitude: -69.9, zoom: 7.0); // fallback en RD

    final ctrl = widget.controller;
    if (ctrl != null && !ctrl._initialized) {
      ctrl._init(
        query: (lookup) {
          if (lookup.isNotEmpty) {
            _api?.search(lookup, language: widget.queryLanguage ?? 'es').then((searchResults) {
              if (searchResults.results.isNotEmpty) {
                final result = searchResults.results.first;
                final loc = result.geometry?.location;
                if (loc != null) {
                  rasterize(() {
                    busy = false;
                    _updateLocation(LatLng(loc.lat, loc.lng));
                  });
                }
              }
            });
          }
        },
        refresh: () {
          fetch();
        },
      );
    }
  }

@override
Future<MapFieldValue?> lookup() async {
  final controller = TextEditingController(text: widget.initialQuery ?? '');
  final text = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Búsqueda personalizada'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Dirección',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(null),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(controller.text),
          child: const Text('Buscar'),
        ),
      ],
    ),
  );

  if (text != null && text.isNotEmpty && widget.onLookup != null) {
    return await widget.onLookup!(text);
  }

  return value;
}


  @override
  Widget display([String? text]) {
    final showLoader = value?.location == null && _default.location == null;

    final mapContainer = Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.scope.application.settings.dialogs.dialogRadius + 2),
        border: Border.all(
          color: widget.scope.application.settings.fields.focusColor,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.scope.application.settings.dialogs.dialogRadius),
        child: showLoader
            ? Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.scope.application.settings.colors.primary,
                  ),
                ),
              )
            : GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  zoom: value?.zoom ?? _default.zoom ?? 5,
                  target: value?.location ?? _default.location!,
                ),
                compassEnabled: false,
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                mapToolbarEnabled: true,
                myLocationButtonEnabled: false,
                tiltGesturesEnabled: false,
                trafficEnabled: false,
                buildingsEnabled: false,
                indoorViewEnabled: false,
                circles: _circles,
                markers: _markers,
                rotateGesturesEnabled: false,
                myLocationEnabled: false,
                onCameraIdle: () async {
                  if (_controller != null) {
                    final mzoom = await _controller!.getZoomLevel();
                    if (value?.zoom != mzoom) {
                      value?.zoom = mzoom;
                      _renderMarker();
                    }
                  }
                },
                onTap: (location) => _updateLocation(location),
                onMapCreated: (controller) async {
                  if (!mounted) return;
                  final bitmap = await BitmapDescriptor.fromAssetImage(
                    createLocalImageConfiguration(context, size: const Size.square(48)),
                    widget.marketImageAsset,
                  );
                  rasterize(() {
                    _pointer = bitmap;
                    _controller = controller;
                    if (_fetchWhenControllerAvailable) {
                      _fetchWhenControllerAvailable = false;
                      fetch();
                    }
                  });
                },
              ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: SizedBox(height: widget.height, child: mapContainer),
    );
  }

  void _updateLocation(LatLng location) {
    submit(
      MapFieldValue(
        latitude: location.latitude,
        longitude: location.longitude,
        zoom: value?.zoom,
        radius: value?.radius,
        color: value?.color,
      ),
    );
  }

  Future<void> _renderMarker() async {
    final location = value?.location ?? _default.location;
    if (location == null || _pointer == null || _controller == null) return;

    _markers = {
      Marker(
        markerId: _mainMarkerId,
        position: location,
        draggable: true,
        icon: _pointer!,
        onDragEnd: _updateLocation,
      ),
    };

    if (value?.radius != null && (value!.radius!) > 0) {
      _circles = {
        Circle(
          circleId: _mainCircleId,
          center: location,
          radius: value!.radius!,
          strokeWidth: 0,
          fillColor: value!.color ??
              widget.scope.application.settings.colors.navigation.withValues(alpha: 0.3),
        ),
      };
    } else {
      _circles = {
        Circle(
          circleId: _mainCircleId,
          center: location,
          radius: 0,
          strokeWidth: 0,
          fillColor: Colors.transparent,
        ),
      };
    }

    await _controller!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: value?.zoom ?? _default.zoom ?? 5),
      ),
    );

    rasterize();
  }

  @override
  Future<MapFieldValue?> fetch([bool apply = true]) async {
    final cvalue = await super.fetch(false);
    var calculateZoom = cvalue?.radius == null || cvalue?.radius != value?.radius;

    if (_tick != widget.scope.tick) {
      calculateZoom = false;
      _tick = widget.scope.tick;
    }

    await super.fetch();

    if (calculateZoom && value?.radius != null && value!.radius! > 0) {
      value!.zoom = (15 - log(value!.radius! / 500) / log(2));
    }

    if (_pointer == null) {
      _fetchWhenControllerAvailable = true;
    } else {
      _fetchWhenControllerAvailable = false;
      _renderMarker();
    }

    return value;
  }

  @override
  void present() {
    _renderMarker();
  }
}
