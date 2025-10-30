import 'dart:async';
import 'dart:ui' as ui show Codec, instantiateImageCodec;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;

/// Custom image provider that loads images with optional secured headers (e.g., Bearer token)
class SecuredImage extends ImageProvider<SecuredImage> {
  final String url;
  final double scale;
  final Map<String, String>? headers;
  final http.Client _client = http.Client();

   SecuredImage(
    this.url, {
    this.scale = 1.0,
    this.headers,
  });

  @override
  Future<SecuredImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<SecuredImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    SecuredImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', this);
        yield DiagnosticsProperty<ImageProvider>('Image key', key);
      },
    );
  }

  Future<ui.Codec> _loadAsync(SecuredImage key, ImageDecoderCallback decode) async {
    assert(key == this);

    final Uri resolved = Uri.base.resolve(key.url);

    final http.Response response;
    try {
      response = await _client.get(resolved, headers: headers);
    } catch (e) {
      throw Exception('HTTP request failed for $resolved: $e');
    }

    if (response.statusCode != 200) {
      throw Exception('HTTP request failed, statusCode: ${response.statusCode}, url: $resolved');
    }

    if (response.bodyBytes.isEmpty) {
      throw Exception('Empty response body: $resolved');
    }

    try {
      return await ui.instantiateImageCodec(response.bodyBytes);
    } catch (e) {
      throw Exception('Failed to decode image from $resolved: $e');
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SecuredImage &&
            other.url == url &&
            other.scale == scale);
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() => 'SecuredImage(url: $url, scale: $scale)';
}
