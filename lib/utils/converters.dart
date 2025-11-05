import 'dart:async';

import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as Path;
import 'package:credit_card_type_detector/constants.dart' as CCTypes;

class Converters {
  // Inicializados de forma segura (const/final) para NNBD
  final List<String> _digits = const ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  final RegExp _commaRegex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  // Formatos de fecha/hora
  final String _fullDateFormat = 'dd/MM/yyyy h:mm:ss a';
  final String _dateFormat = 'dd/MM/yyyy';
  final String _normalDateFormat = 'dd/MM/yyyy h:mm a';
  final String _fileDateFormat = 'dd_MM_yyyy_h_mm_a';
  final String _timeFormat = 'h:mm aa';

  String fromCreditCardTypeToString(CreditCardType type) => type.name;

  CreditCardType? fromCreditCardNumberToType(String value) {
    final validator = CreditCardValidator();
    final valres = validator.validateCCNum(value);
    if (valres.isValid == true) {
      switch (valres.ccType.type) {
        case CCTypes.TYPE_VISA:
          return CreditCardType.visa;
        case CCTypes.TYPE_AMEX:
          return CreditCardType.amex;
        case CCTypes.TYPE_DISCOVER:
          return CreditCardType.discover;
        case CCTypes.TYPE_MAESTRO:
          return CreditCardType.maestro;
        case CCTypes.TYPE_MASTERCARD:
          return CreditCardType.mastercard;
      }
    }
    return null;
  }

  String? fromCreditCardNumberToBrand(String value) {
    final type = fromCreditCardNumberToType(value);
    switch (type) {
      case CreditCardType.visa:
        return 'visa';
      case CreditCardType.amex:
        return 'american_express';
      case CreditCardType.mastercard:
        return 'master_card';
      case CreditCardType.discover:
        return 'discover';
      case CreditCardType.maestro:
        return 'maestro';
      default:
        return null;
    }
  }

  CreditCardType? fromCreditCardBrandToType(String value) {
    switch (value) {
      case 'visa':
        return CreditCardType.visa;
      case 'master_card':
        return CreditCardType.mastercard;
      case 'american_express':
        return CreditCardType.amex;
      case 'discover':
        return CreditCardType.discover;
      case 'maestro':
        return CreditCardType.maestro;
      default:
        return null;
    }
  }

  String fromNamesToSingleName(String names) {
    final parts = names.split(' ');
    if (parts.length > 2 && parts[0].toLowerCase() == 'de') {
      return '${parts[0]} ${parts[1]} ${parts[2]}';
    }
    return parts[0];
  }

  Color fromHexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', '').replaceFirst('0x', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String fromColorToHex(Color color) =>
    '0x${color.toARGB32().toRadixString(16).padLeft(8, '0')}';


  IconData fromHexToIconData(String hexString) {
    // Soporta "0x..." / "#..." / decimal plano
    String cleaned = hexString.toLowerCase().replaceAll('#', '');
    int code;
    if (cleaned.startsWith('0x')) {
      cleaned = cleaned.substring(2);
      code = int.parse(cleaned, radix: 16);
    } else {
      code = int.tryParse(cleaned) ?? int.parse(cleaned, radix: 16);
    }
    return IconData(code, fontFamily: 'MaterialIcons');
  }

  String fromNamesToFullName(String firstNames, String lastNames) {
    return '${fromNamesToSingleName(firstNames)} ${fromNamesToSingleName(lastNames)}'.trim();
  }

  String fromStringToDigits(String value) {
    var result = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final char = value[i];
      if (_digits.contains(char)) result.write(char);
    }
    return result.toString();
  }

  String fromPathToFilename(String value) => Path.basename(value);

  String fromStringToPhoneDigits(String value) {
    var result = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final char = value[i];
      if (_digits.contains(char) || char == '+' || char == '*' || char == '#' || char == ' ') {
        result.write(char);
      }
    }
    return result.toString();
  }

  String fromStringToUpperCase(String value) => value.toUpperCase().trim();

  String fromStringToTrimedString(String value) => value.trim();

  String fromDurationToDetail(
    Duration duration, {
    bool showDays = true,
    bool showHours = true,
    bool showMinutes = true,
    bool showSeconds = true,
    bool showZeros = false,
  }) {
    final days = duration.inDays;
    final hours = duration.inHours - (days * 24);
    final minutes = duration.inMinutes - (duration.inHours * 60);
    final seconds = duration.inSeconds - (duration.inMinutes * 60);
    return '${showDays && (showZeros || days > 0) ? '${days}d ' : ''}'
        '${showHours && (showZeros || hours > 0) ? '${hours}h ' : ''}'
        '${showMinutes && (showZeros || minutes > 0) ? '${minutes}m ' : ''}'
        '${showSeconds && (showZeros || seconds > 0) ? '${seconds}s' : ''}';
  }

  String fromSecondsToDurationCaption(int seconds) {
    final duration = Duration(seconds: seconds);
    int value;
    String sufix;
    final isFuture = duration.inSeconds < 0;

    if (isFuture) {
      if (-duration.inHours >= 24) {
        value = -duration.inDays;
        sufix = 'd';
      } else if (-duration.inMinutes >= 60) {
        value = -duration.inHours;
        sufix = 'h';
      } else if (-duration.inSeconds >= 60) {
        value = -duration.inMinutes;
        sufix = 'm';
      } else {
        value = -duration.inSeconds;
        sufix = 's';
      }
    } else {
      if (duration.inHours >= 24) {
        value = duration.inDays;
        sufix = 'd';
      } else if (duration.inMinutes >= 60) {
        value = duration.inHours;
        sufix = 'h';
      } else if (duration.inSeconds >= 60) {
        value = duration.inMinutes;
        sufix = 'm';
      } else {
        value = duration.inSeconds;
        sufix = 's';
      }
    }

    final base = fromAnyToNumber(value, comma: true, decimals: 0) ?? '0';
    return isFuture ? '$base$sufix res' : '$base$sufix';
  }

  String fromDateToDurationCaption(DateTime date) {
    final duration = DateTime.now().difference(date.toLocal());
    return fromDurationToHumanCaption(duration);
  }

  String fromDurationToHumanCaption(Duration duration) {
    int value;
    String sufix;
    final isFuture = duration.inSeconds < 0;

    if (isFuture) {
      if (-duration.inHours >= 24) {
        value = -duration.inDays;
        sufix = 'd';
      } else if (-duration.inMinutes >= 60) {
        value = -duration.inHours;
        sufix = 'h';
      } else if (-duration.inSeconds >= 60) {
        value = -duration.inMinutes;
        sufix = 'm';
      } else {
        value = -duration.inSeconds;
        sufix = 's';
      }
    } else {
      if (duration.inHours >= 24) {
        value = duration.inDays;
        sufix = 'd';
      } else if (duration.inMinutes >= 60) {
        value = duration.inHours;
        sufix = 'h';
      } else if (duration.inSeconds >= 60) {
        value = duration.inMinutes;
        sufix = 'm';
      } else {
        value = duration.inSeconds;
        sufix = 's';
      }
    }

    final base = fromAnyToNumber(value, comma: true, decimals: 0) ?? '0';
    return isFuture ? '$base$sufix res' : '$base$sufix';
  }

  String fromMetersToDistanceCaption(double meters) {
    double value = meters;
    String sufix = 'm';
    if (meters >= 1000) {
      value = meters / 1000.0;
      sufix = 'km';
    }
    return '${fromAnyToNumber(value, comma: true, decimals: 0) ?? '0'} $sufix';
  }

  String? fromAnyToNumber(
    dynamic value, {
    int decimals = 0,
    bool comma = false,
    String? prefix,
    String? sufix,
  }) {
    if (value == null) return null;

    final asDouble = (value is num) ? value.toDouble() : double.parse(value.toString());
    final str = asDouble.toStringAsFixed(decimals);

    final result = comma ? str.replaceAllMapped(_commaRegex, (m) => '${m[1]},') : str;
    return (prefix ?? '') + result + (sufix ?? '');
  }

  String fromDateToFullDateString(
    DateTime date, {
    bool seconds = false,
    bool time = true,
  }) {
    if (!time) {
      return DateFormat(_dateFormat).format(date.toLocal());
    } else if (seconds) {
      return DateFormat(_fullDateFormat).format(date.toLocal());
    } else {
      return DateFormat(_normalDateFormat).format(date.toLocal());
    }
  }

  String fromCmToHeightMetric(double cm) {
    final foot = cm / 30.48;
    final parts = foot.toString().split('.');
    final feets = parts[0];
    final fraction = double.parse('0.${parts.length > 1 ? parts[1] : '0'}');
    final inches = (fraction * 12.0).toInt();
    return '$feets\' $inches\'\'';
  }

  String fromDateToLocalizedDate(DateTime date, {bool withTime = false}) {
    if (withTime) {
      final d = DateFormat.yMd(translate('anxeb.formats.date_locale')).format(date.toLocal());
      final t = DateFormat.jms(translate('anxeb.formats.date_locale'))
          .format(date.toLocal())
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toUpperCase();
      return '$d $t';
    }
    return DateFormat.yMMMMd(translate('anxeb.formats.date_locale')).format(date.toLocal());
  }

  String fromDateToLocalizedTime(DateTime date, {bool duration = false}) {
    final prefix = DateFormat.jms(translate('anxeb.formats.date_locale'))
        .format(date.toLocal())
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toUpperCase();

    return duration
        ? translate('anxeb.formats.date_duration',
                args: {"date": prefix, "duration": fromDateToDurationCaption(date.toLocal())})
            .toUpperCase()
        : prefix.toUpperCase();
  }

  String fromDateToHumanString(
    DateTime date, {
    bool complete = false,
    bool withTime = false,
    String? timeSeparator,
  }) {
    final sep = timeSeparator ?? ' ';
    if (withTime) {
      if (complete) {
        return '${DateFormat.yMMMMd('es_DO').format(date.toLocal())}$sep${DateFormat(_timeFormat).format(date.toLocal())}'
            .replaceAll('.', '')
            .toLowerCase();
      } else {
        return '${DateFormat.yMMMd('es_DO').format(date.toLocal())}$sep${DateFormat(_timeFormat).format(date.toLocal())}'
            .replaceAll('.', '')
            .toLowerCase();
      }
    } else {
      return complete
          ? DateFormat.yMMMMd('es_DO').format(date.toLocal())
          : DateFormat.yMMMd('es_DO').format(date.toLocal());
    }
  }

  String fromTextToEllipsis(String value, int max) {
    if (value.length <= max) return value;
    var current = value;
    while (current.length > max) {
      final parts = current.split(' ');
      if (parts.length == 1) return '${value.substring(0, max)}...';
      parts.removeLast();
      current = parts.join(' ');
    }
    return '$current...';
  }

  String fromAnyToDataSize(int value) {
    const oneKB = 1000;
    const oneMB = 1000000;
    String sufix = 'B';
    String caption = fromAnyToNumber(value, decimals: 0, comma: true) ?? '0';

    if (value >= oneMB) {
      sufix = 'MB';
      caption = fromAnyToNumber(value / oneMB, decimals: 2, comma: true) ?? '0';
    } else if (value >= oneKB) {
      sufix = 'KB';
      caption = fromAnyToNumber(value / oneKB, decimals: 2, comma: true) ?? '0';
    }
    return '$caption $sufix';
  }

  String fromDateToFileDateString(DateTime date) =>
      DateFormat(_fileDateFormat).format(date.toLocal());

  DateTime fromTickToDate(int timestamp) =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);

  double? fromAnyToDouble(dynamic value, {int? decimals}) {
    if (value == null) return null;
    double d;
    if (value is String) {
      d = fromStringToDouble(value, decimals: decimals) ?? 0.0;
    } else {
      d = (value as num).toDouble();
      if (decimals != null) {
        d = double.parse(d.toStringAsFixed(decimals));
      }
    }
    return d;
    }

  double? fromStringToDouble(String value, {int? decimals}) {
    if (value.isEmpty) return null;
    var v = value.replaceAll(',', '');
    if (v.startsWith('.')) v = '0$v';
    final d = double.parse(v);
    return decimals != null ? double.parse(d.toStringAsFixed(decimals)) : d;
  }

 EdgeInsets fromInsetToFraction(EdgeInsets? inset, Size screenSize) {
  final safe = inset ?? EdgeInsets.zero;
  return EdgeInsets.only(
    left: safe.left * screenSize.width,
    right: safe.right * screenSize.width,
    top: safe.top * screenSize.height,
    bottom: safe.bottom * screenSize.height,
  );
}


  TimeOfDay fromDateToTime(DateTime date) =>
      TimeOfDay(hour: date.toLocal().hour, minute: date.toLocal().minute);

  int fromDateToTick(DateTime date) => (date.toUtc().millisecondsSinceEpoch ~/ 1000);

  double fromAnyToMoney(dynamic value) {
    if (value == null) return 0;
    if (value is String) {
      final d = double.parse(value);
      return double.parse(d.toStringAsFixed(2));
    } else if (value is num) {
      return double.parse(value.toStringAsFixed(2));
    }
    return 0;
  }

  String fromStringToNameCase(String value) {
    final items = value.split(' ');
    final result = <String>[];
    for (final item in items) {
      if (item.length > 1) {
        result.add(item[0].toUpperCase() + item.substring(1).toLowerCase());
      } else if (item.isNotEmpty) {
        result.add(item.toUpperCase());
      }
    }
    return result.join(' ');
  }

  int? fromStringToPositive(String value) {
    if (value.isEmpty) return null;
    final v = int.parse(value.replaceAll(',', ''));
    return v < 0 ? -v : v;
  }

  int? fromStringToInteger(String value) {
    if (value.isEmpty) return null;
    return int.parse(value.replaceAll(',', ''));
  }

  Future<MultipartFile> fromPathToMultipartFile(String path) async {
    final contentType = lookupMimeType(path) ?? 'application/octet-stream';
    return MultipartFile.fromFile(
      path,
      filename: Path.basename(path),
      contentType: MediaType.parse(contentType),
    );
  }

  MultipartFile fromBytesToMultipartFile(String fileName, List<int> data) {
    final contentType = lookupMimeType(fileName) ?? 'application/octet-stream';
    return MultipartFile.fromBytes(
      data,
      filename: Path.basename(fileName),
      contentType: MediaType.parse(contentType),
    );
  }

  FormData fromMapToFormData(Map<String, dynamic> map) => FormData.fromMap(map);

  int? fromAnyToInteger(dynamic value) {
    if (value == null) return null;
    if (value is String) return fromStringToInteger(value);
    return (value as num).toInt();
  }

  DateTime fromStringToDate(String text) => DateTime.parse(text);

  String? fromIndexToMonth(int month) {
    switch (month) {
      case 1:
        return translate('anxeb.common.months.jan');
      case 2:
        return translate('anxeb.common.months.feb');
      case 3:
        return translate('anxeb.common.months.mar');
      case 4:
        return translate('anxeb.common.months.apr');
      case 5:
        return translate('anxeb.common.months.may');
      case 6:
        return translate('anxeb.common.months.jun');
      case 7:
        return translate('anxeb.common.months.jul');
      case 8:
        return translate('anxeb.common.months.aug');
      case 9:
        return translate('anxeb.common.months.sep');
      case 10:
        return translate('anxeb.common.months.oct');
      case 11:
        return translate('anxeb.common.months.nov');
      case 12:
        return translate('anxeb.common.months.dec');
      default:
        return null;
    }
  }

  int fromDurationToTicks(Duration propertyValue) => propertyValue.inMilliseconds;
}

enum CreditCardType { visa, amex, mastercard, discover, maestro }
