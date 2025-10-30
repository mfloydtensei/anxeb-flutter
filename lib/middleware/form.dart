import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:anxeb_flutter/widgets/fields/file.dart';
import 'package:anxeb_flutter/widgets/fields/files.dart';
import 'package:anxeb_flutter/widgets/fields/image.dart';

import 'data.dart';
import 'field.dart';
import 'model.dart';
import 'scope.dart';
import 'utils.dart';

class FieldsForm {
  final Map<String, FieldState> fields = {};
  final Map<String, GlobalKey<FieldState>> _keys = {};
  dynamic _initialValues;
  bool validated = false;
  ValueChanged<bool>? onValidationChanged;

  FieldsForm([dynamic initialValues]) {
    _initialValues = initialValues ?? {};
  }

  GlobalKey<FieldState> key(String name) {
    return _keys.putIfAbsent(name, () => GlobalKey<FieldState>());
  }

  void set(String fieldName, dynamic value) {
    fields[fieldName]?.value = value;
  }

  dynamic get(String fieldName, {bool raw = false}) {
    final field = fields[fieldName];
    return raw ? field?.value : field?.data();
  }

  void update([dynamic data]) {
    validated = false;

    if (data is Model) {
      _initialValues = data.toObjects();
    } else if (data is Data) {
      _initialValues = data.toObjects();
    } else {
      _initialValues = data ?? {};
    }

    for (var field in fields.values) {
      if ((_initialValues as Map).containsKey(field.widget.name)) {
        field.reset();
        field.value = _initialValues[field.widget.name];
      }
    }
  }

  void fetch() {
    for (var field in fields.values) {
      field.fetch();
    }
  }

  void apply() {
    for (var field in fields.values) {
      field.apply();
    }
  }

  void focusNextInvalid() {
    for (var i = 0; i <= fields.length; i++) {
      for (var field in fields.values) {
        if (field.index == i && !field.valid()) {
          field.focus();
          return;
        }
      }
    }
  }

  void remove(String name) => fields.remove(name);

  void clear([String? fieldName]) {
    final field = fields[fieldName];
    field?.reset();
  }

  bool focusFrom(int index, {bool onlyEmpty = false}) {
    for (var field in fields.values) {
      if (field.index == index + 1) {
        if (!onlyEmpty || field.isEmpty) {
          field.focus();
          return true;
        }
        break;
      }
    }
    return false;
  }

  bool focus(String name, {bool force = false, String? warning}) {
    final field = fields[name];
    if (field != null && (force || field.value == null)) {
      field.focus(warning: warning);
      return true;
    }
    return false;
  }

  bool select(String name) {
    final field = fields[name];
    if (field != null) {
      field.select();
      return true;
    }
    return false;
  }

  void include(FieldState current) {
    final existing = fields[current.widget.name];
    if (existing != null) {
      current.index = existing.index;
      current.value = existing.value;
    } else {
      current.index = fields.length;
      if (_initialValues is Map &&
          (_initialValues as Map).containsKey(current.widget.name)) {
        current.value = _initialValues[current.widget.name];
      }
    }
    fields[current.widget.name] = current;
  }

  bool validate({bool showMessage = true, bool autoFocus = false}) {
    var result = true;

    for (var field in fields.values) {
      if (field.mounted && field.validate(showMessage: showMessage) != null) {
        if (autoFocus) field.focus();
        result = false;
        break;
      }
    }

    if (validated != result) {
      validated = result;
      onValidationChanged?.call(validated);
    }

    return result;
  }

  bool valid({bool autoFocus = false, bool showMessage = true}) {
    return validate(autoFocus: autoFocus, showMessage: showMessage);
  }

  Map<String, dynamic>? data({bool? images, bool? files}) {
    if (!validate()) return null;

    final Map<String, dynamic> data = {};

    for (var field in fields.values) {
      final isImage = field.widget is ImageInputField;
      final isFile =
          field.widget is FileInputField || field.widget is FilesInputField;

      if (field.widget.visible != false) {
        final includeImage = images == null ||
            (images == true && isImage) ||
            (images == false && !isImage);
        final includeFile = files == null ||
            (files == true && isFile) ||
            (files == false && !isFile);

        if (includeImage && includeFile) {
          final value = field.data();
          if ((isFile || isImage) && value == '') continue;
          data[field.widget.name] = value;
        }
      }
    }

    return data;
  }

  Map<String, FileInputValue> files() {
    final result = <String, FileInputValue>{};
    final payload = data(files: true);

    if (payload != null) {
      payload.forEach((key, value) {
        if (value is FileInputValue && (value.title?.isNotEmpty == true)) {
          result[key] = value;
        }
      });
    }

    return result;
  }

  Future<Map<String, dynamic>> multipart() async {
    final filesMap = files();
    final Map<String, dynamic> multiPayload = {};

    for (final entry in filesMap.entries) {
      final path = entry.value.path;
      if (path != null && await io.File(path).exists()) {
        multiPayload[entry.key] =
            await Utils.convert.fromPathToMultipartFile(path);
      }
    }

    return multiPayload;
  }

  Map<String, dynamic>? value() {
    if (!validate()) return null;

    final Map<String, dynamic> result = {};
    for (var field in fields.values) {
      if (field.widget.visible != false) {
        result[field.widget.name] = field.value;
      }
    }
    return result;
  }

  bool noneFocused() {
    return fields.values.every((f) => f.focused != true);
  }
}

class ScopeForms {
  final Scope _scope;
  final Map<String, FieldsForm> _forms = {};

  ScopeForms(this._scope);

  bool validate(String name) => _retrieve(name).validate();

  bool valid({bool autoFocus = false}) {
    for (var form in _forms.values) {
      if (!form.valid(autoFocus: autoFocus)) return false;
    }
    return true;
  }

  void focusNextInvalid(String name) => _retrieve(name).focusNextInvalid();

  bool noneFocused() {
    for (var form in _forms.values) {
      if (!form.noneFocused()) return false;
    }
    return true;
  }

  /// ✅ Corregido: manejo null-safe y cast correcto para Data.include()
  Data data({bool separateByGroup = false}) {
    final result = Data();

    if (separateByGroup) {
      for (var entry in _forms.entries) {
        result[entry.key] = entry.value.data();
      }
    } else {
      for (var form in _forms.values) {
        final data = form.data();
        if (data != null) {
          result.include(Map<String, Object>.from(data));
        }
      }
    }

    return result;
  }

  /// ✅ También corregido: conversión segura y null check
  Data values({bool separateByGroup = false}) {
    final result = Data();

    if (separateByGroup) {
      for (var entry in _forms.entries) {
        result[entry.key] = entry.value.value();
      }
    } else {
      for (var form in _forms.values) {
        final value = form.value();
        if (value != null) {
          result.include(Map<String, Object>.from(value));
        }
      }
    }

    return result;
  }

  FieldsForm _retrieve(String? name) {
    final formKey = name ?? _scope.key;
    return _forms.putIfAbsent(formKey, () => FieldsForm());
  }

  FieldsForm get current => _retrieve(_scope.key);

  FieldsForm operator [](String name) => _retrieve(name);

  GlobalKey<FieldState> key(String name, String field) {
    final form = _retrieve(name);
    return form.key(field);
  }
}
