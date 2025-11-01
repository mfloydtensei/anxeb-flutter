import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

// Exportación de todos los paquetes de íconos disponibles
export 'package:fluttericon/brandico_icons.dart';
export 'package:fluttericon/elusive_icons.dart';
export 'package:fluttericon/entypo_icons.dart';
export 'package:fluttericon/font_awesome5_icons.dart';
export 'package:fluttericon/font_awesome_icons.dart';
export 'package:fluttericon/fontelico_icons.dart';
export 'package:fluttericon/iconic_icons.dart';
export 'package:fluttericon/linearicons_free_icons.dart';
export 'package:fluttericon/linecons_icons.dart';
export 'package:fluttericon/maki_icons.dart';
export 'package:fluttericon/meteocons_icons.dart';
export 'package:fluttericon/mfg_labs_icons.dart';
export 'package:fluttericon/modern_pictograms_icons.dart';
export 'package:fluttericon/octicons_icons.dart';
export 'package:fluttericon/rpg_awesome_icons.dart';
export 'package:fluttericon/typicons_icons.dart';
export 'package:fluttericon/web_symbols_icons.dart';
export 'package:fluttericon/zocial_icons.dart';
export 'package:community_material_icon/community_material_icon.dart';
export 'package:ionicons/ionicons.dart';

/// =======================================================
/// GLOBAL ICON HELPER
/// =======================================================
class GlobalIcons {
  /// Retorna un color asociado a la extensión del archivo
  IconData getFileIcon(String extension) {
    final data = _mimeTypes[extension.toLowerCase()];
    if (data != null && data['icon'] is IconData) {
      return data['icon'] as IconData;
    }
    return FontAwesome5.file_alt;
  }

  /// Retorna los metadatos del ícono (caption, color, etc)
  IconFileMeta getFileMeta(String extension) {
    final ext = extension.toLowerCase();
    final data = _mimeTypes[ext];

    if (data != null) {
      return IconFileMeta(
        icon: data['icon'] as IconData,
        caption: data['caption'] as String,
        color: data['color'] as Color,
        image: data['image'] as bool? ?? false,
      );
    }

    return IconFileMeta(
      icon: FontAwesome5.file_alt,
      caption: ext.toUpperCase(),
      color: Colors.black,
      image: false,
    );
  }

  /// Mapeo de extensiones a sus propiedades visuales
  final Map<String, Map<String, dynamic>> _mimeTypes = {
    'doc': {
      'icon': FontAwesome5.file_word,
      'caption': 'DOC',
      'color': Color(0xff2A5399),
      'image': false,
    },
    'xls': {
      'icon': FontAwesome5.file_excel,
      'caption': 'XLS',
      'color': Color(0xff207245),
      'image': false,
    },
    'ppt': {
      'icon': FontAwesome5.file_powerpoint,
      'caption': 'PPT',
      'color': Color(0xffD4522F),
      'image': false,
    },
    'abw': {
      'icon': FontAwesome5.file_alt,
      'caption': 'ABW',
      'color': Color(0xff6f6f6f),
      'image': false,
    },
    'avi': {
      'icon': FontAwesome5.file_video,
      'caption': 'AVI',
      'color': Color(0xffff0909),
      'image': false,
    },
    'bin': {
      'icon': FontAwesome5.file_code,
      'caption': 'BIN',
      'color': Color(0xff313131),
      'image': false,
    },
    'xml': {
      'icon': FontAwesome5.file_code,
      'caption': 'XML',
      'color': Color(0xff364355),
      'image': false,
    },
    'bz': {
      'icon': FontAwesome5.file_archive,
      'caption': 'BZ',
      'color': Color(0xff8e7f5b),
      'image': false,
    },
    'gz': {
      'icon': FontAwesome5.file_archive,
      'caption': 'GZ',
      'color': Color(0xff8e7f5b),
      'image': false,
    },
    'ico': {
      'icon': FontAwesome5.file_image,
      'caption': 'ICO',
      'color': Color(0xffb35e00),
      'image': false,
    },
    'jar': {
      'icon': FontAwesome5.file_archive,
      'caption': 'JAR',
      'color': Color(0xff8e7f5b),
      'image': false,
    },
    'jpg': {
      'icon': FontAwesome5.file_image,
      'caption': 'JPEG',
      'color': Color(0xffe08c32),
      'image': true,
    },
    'js': {
      'icon': FontAwesome5.file_code,
      'caption': 'JS',
      'color': Color(0xffd71e8d),
      'image': false,
    },
    'json': {
      'icon': FontAwesome5.file_code,
      'caption': 'JSON',
      'color': Color(0xff2f2f2f),
      'image': false,
    },
    'mp3': {
      'icon': FontAwesome5.file_audio,
      'caption': 'MP3',
      'color': Color(0xff2a1da0),
      'image': false,
    },
    'mpeg': {
      'icon': FontAwesome5.file_video,
      'caption': 'MPEG',
      'color': Color(0xffff3636),
      'image': false,
    },
    'rar': {
      'icon': FontAwesome5.file_archive,
      'caption': 'RAR',
      'color': Color(0xff158a9c),
      'image': false,
    },
    'svg': {
      'icon': FontAwesome5.file_image,
      'caption': 'SVG',
      'color': Color(0xff158a9c),
      'image': false,
    },
    'csv': {
      'icon': FontAwesome5.file_csv,
      'caption': 'CSV',
      'color': Color(0xff347179),
      'image': false,
    },
    'txt': {
      'icon': FontAwesome5.file_alt,
      'caption': 'TXT',
      'color': Color(0xffee718b),
      'image': false,
    },
    'pdf': {
      'icon': FontAwesome5.file_pdf,
      'caption': 'PDF',
      'color': Color(0xffB20D02),
      'image': false,
    },
    'gif': {
      'icon': FontAwesome5.file_image,
      'caption': 'GIF',
      'color': Color(0xffe08c32),
      'image': true,
    },
    'bmp': {
      'icon': FontAwesome5.file_image,
      'caption': 'BMP',
      'color': Color(0xffe08c32),
      'image': true,
    },
    'png': {
      'icon': FontAwesome5.file_image,
      'caption': 'PNG',
      'color': Color(0xffe08c32),
      'image': true,
    },
    'zip': {
      'icon': FontAwesome5.file_archive,
      'caption': 'ZIP',
      'color': Color(0xff8e7f5b),
      'image': false,
    },
  };
}

/// =======================================================
/// FILE ICON METADATA MODEL
/// =======================================================
class IconFileMeta {
  final IconData icon;
  final String caption;
  final Color color;
  final bool image;

  const IconFileMeta({
    required this.icon,
    required this.caption,
    required this.color,
    this.image = false,
  });
}
