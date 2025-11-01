import 'package:anxeb_flutter/anxeb.dart';

class Validators {
  String? firstNames(String? value) {
    if (value == null || value.trim().isEmpty) {
      return translate('anxeb.utils.validators.first_names.default_error');
    }

    final err =
        translate('anxeb.utils.validators.first_names.default_error'); // TR 'Ingrese uno o dos nombres válidos';
    final validCharacters =
        RegExp(r'^[^0-9_!¡?÷¿/\\+=@#$%^&*(){}|~<>;:\[\]]{2,}$');
    final spaces = RegExp(r'\s\s');

    if (validCharacters.hasMatch(value) && !spaces.hasMatch(value)) {
      final parts = value.split(' ');
      if (parts.length > 7) return err;
      for (final item in parts) {
        if (item.length < 2 || item.length > 15) return err;
      }
    } else {
      return err;
    }
    return null;
  }

  String? lastNames(String? value) {
    if (value == null || value.trim().isEmpty) {
      return translate('anxeb.utils.validators.last_names.default_error');
    }
    return null;
  }

  String? creditCard(String? value) {
    if (value == null || value.isEmpty) {
      return translate('anxeb.utils.validators.credit_card.default_error');
    }

    final validator = CreditCardValidator();
    final validationResult = validator.validateCCNum(value);

    if (validationResult.isValid == true) return null;
    return translate('anxeb.utils.validators.credit_card.default_error');
  }

  String? creditCardCCV(String? value) {
    if (value == null) return translate('anxeb.utils.validators.credit_card.ccv_nnnn_error');
    if (value.length > 1 && value.length <= 4) {
      final ccv = int.tryParse(value);
      if (ccv != null && ccv >= 1 && ccv <= 9999) return null;
    }
    return translate('anxeb.utils.validators.credit_card.ccv_nnnn_error');
  }

  String? fourDigitsPin(String? value) {
    if (value != null && value.length == 4) return null;
    return translate('anxeb.utils.validators.pin.default_error');
  }

  String? creditCardCCV3Fix(String? value) {
    if (value == null) return translate('anxeb.utils.validators.credit_card.ccv_nnn_error');
    if (value.length == 3) {
      final ccv = int.tryParse(value);
      if (ccv != null && ccv >= 0 && ccv <= 999) return null;
    }
    return translate('anxeb.utils.validators.credit_card.ccv_nnn_error');
  }

  String? creditCardDateMMSYYYY(String? value) {
    if (value == null) return translate('anxeb.utils.validators.credit_card.mmsyyyy_date_error');
    if (value.length == 7 && value.contains('/')) {
      final mm = value.substring(0, 2);
      final yyyy = value.substring(3, 7);

      final month = int.tryParse(mm);
      final year = int.tryParse(yyyy);

      if (month != null && month >= 1 && month <= 12) {
        if (year != null && year >= 1 && year <= 2999) {
          final now = DateTime.now();
          final exp = DateTime(year, month);
          if (!exp.isAfter(now)) {
            return translate('anxeb.utils.validators.credit_card.expired_date_error');
          }
          return null;
        }
      }
    }
    return translate('anxeb.utils.validators.credit_card.mmsyyyy_date_error');
  }

  String? creditCardDateMMSYY(String? value) {
    if (value == null) return translate('anxeb.utils.validators.credit_card.mmsyy_date_error');
    if (value.length == 5 && value.contains('/')) {
      final mm = value.substring(0, 2);
      final yy = value.substring(3, 5);

      final month = int.tryParse(mm);
      final year = int.tryParse('20$yy');

      if (month != null && month >= 1 && month <= 12) {
        if (year != null && year >= 1 && year <= 2999) {
          final now = DateTime.now();
          final exp = DateTime(year, month);
          if (!exp.isAfter(now)) {
            return translate('anxeb.utils.validators.credit_card.expired_date_error');
          }
          return null;
        }
      }
    }
    return translate('anxeb.utils.validators.credit_card.mmsyy_date_error');
  }

  String? creditCardDateMMYY(String? value) {
    if (value == null) return translate('anxeb.utils.validators.credit_card.mmyy_date_error');
    if (value.length == 4) {
      final mm = value.substring(0, 2);
      final yy = value.substring(2, 4);

      final month = int.tryParse(mm);
      final year = int.tryParse('20$yy');

      if (month != null && month >= 1 && month <= 12) {
        if (year != null && year >= 1 && year <= 2999) {
          final now = DateTime.now();
          final exp = DateTime(year, month);
          if (!exp.isAfter(now)) {
            return translate('anxeb.utils.validators.credit_card.expired_date_error');
          }
          return null;
        }
      }
    }
    return translate('anxeb.utils.validators.credit_card.mmyy_date_error');
  }

  String? required(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return translate('anxeb.utils.validators.required.default_error');
    }
    return null;
  }

  String? somePercentRequired(String? value) {
    final numb = Utils.convert.fromStringToDouble(value ?? '') ?? 0;
    if (numb <= 0 || numb > 100.0) {
      return translate('anxeb.utils.validators.required.some_percent_error');
    }
    return null;
  }

  String? greaterZero(String? value) {
    final numb = Utils.convert.fromStringToDouble(value ?? '') ?? 0;
    if (numb <= 0) {
      return translate('anxeb.utils.validators.required.numeric_error');
    }
    return null;
  }

  String? greaterZeroOrNothing(String? value) {
    if (value == null || value.isEmpty) return null;
    final numb = Utils.convert.fromStringToDouble(value) ?? 0;
    if (numb <= 0) {
      return translate('anxeb.utils.validators.required.numeric_error');
    }
    return null;
  }

  String? barcode(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      if (value.length > 1) {
        int mult = 3;
        int total = 0;
        for (var i = value.length - 2; i >= 0; i--) {
          total += (mult * int.parse(value[i]));
          mult = mult == 3 ? 1 : 3;
        }
        final lastDigit = total % 10;
        final checkDigit = lastDigit > 0 ? 10 - lastDigit : 0;
        if (value.endsWith(checkDigit.toString())) return null;
      }
    } catch (_) {}
    return translate('anxeb.utils.validators.barcode.default_error');
  }

  String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return translate('anxeb.utils.validators.phone.default_error');
    }

    final regex = RegExp(r'^[0-9]*$');
    if (regex.hasMatch(value)) {
      final phone = value.replaceAll('-', '');
      try {
        final number = int.parse(phone);
        if (number.toString().length == 10 || number.toString().length == 11) {
          return null;
        }
      } catch (_) {}
    }

    return translate('anxeb.utils.validators.phone.default_error');
  }

  String? email(String? value) {
    if (value == null || value.isEmpty) {
      return translate('anxeb.utils.validators.email.default_error');
    }

    final regex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (!regex.hasMatch(value)) {
      return translate('anxeb.utils.validators.email.invalid_error');
    }
    return null;
  }

  String? emailOrEmpty(String? value) {
    if (value == null || value.isEmpty) return null;
    return email(value);
  }

  String? password(String? value) {
    if (value == null || value.isEmpty) {
      return translate('anxeb.utils.validators.password.default_error');
    }
    if (value.contains(' ')) {
      return translate('anxeb.utils.validators.password.space_error');
    }
    if (value.length < 5 || value.length > 16) {
      return translate('anxeb.utils.validators.password.length_error');
    }
    return null;
  }

  String? foreign(String? value) {
    if (value == null) {
      return translate('anxeb.utils.validators.foreign.default_error');
    }
    final msg = translate('anxeb.utils.validators.foreign.default_error');
    final ced = value.replaceAll(RegExp(r'[- .\/]'), '');
    if (ced.length == 11 && cedula(ced) == null) return null;
    return msg;
  }

  String? cedula(String? value) {
    if (value == null || value.isEmpty) {
      return translate('anxeb.utils.validators.cedula.default_error');
    }
    final msg = translate('anxeb.utils.validators.cedula.default_error');
    final regex = RegExp(r'^[0-9]*$');
    if (!regex.hasMatch(value)) return msg;

    if (value.length < 11) return msg;

    try {
      final c = value.replaceAll('-', '');
      final cedula = c.substring(0, c.length - 1);
      final verificador = int.parse(c.substring(c.length - 1));
      int suma = 0;

      for (var i = 0; i < cedula.length; i++) {
        int mod = (i % 2) == 0 ? 1 : 2;
        int res = int.parse(cedula[i]) * mod;
        if (res > 9) {
          res = (res ~/ 10) + (res % 10);
        }
        suma += res;
      }

      final numero = (10 - (suma % 10)) % 10;
      if (numero == verificador && cedula.substring(0, 3) != '000') {
        return null;
      }
    } catch (_) {}
    return msg;
  }

  String? passport(String? value) {
    if (value == null) {
      return translate('anxeb.utils.validators.passport.default_error');
    }
    final regex = RegExp(r'^(?!^0+$)[a-zA-Z0-9]{6,9}$');
    if (!regex.hasMatch(value.trim())) {
      return translate('anxeb.utils.validators.passport.default_error');
    }
    return null;
  }

  String? posCode(String? value) {
    if (value == null) {
      return translate('anxeb.utils.validators.pos_code.length_error');
    }
    final initials = ['A', 'B', 'C', 'D'];

    if (value.length < 2) {
      return translate('anxeb.utils.validators.pos_code.length_error');
    }

    final firstChar = value[0].toUpperCase();
    final rest = value.substring(1).replaceAll(RegExp(r'[\s\.\-]'), 'X');
    if (!initials.contains(firstChar) ||
        int.tryParse(rest) == null) {
      return translate('anxeb.utils.validators.pos_code.starting_error');
    }

    return null;
  }

  String? identity(String? value) {
    if (value == null) {
      return translate('anxeb.utils.validators.identity.default_error');
    }
    if (passport(value) == null || cedula(value) == null) {
      return null;
    }
    return translate('anxeb.utils.validators.identity.default_error');
  }
}
