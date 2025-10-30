import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../anxeb.dart';

typedef ModelLoadedCallback<T> = void Function(T model);

class Model<T> {
  late Data _data;
  dynamic _pk;
  String? _diskKey;
  SharedPreferences? _shared;
  final List<_ModelField> _fields = [];
  String? _primaryField;
  bool $deleted = false;
  bool $updated = false;

  /// Constructor principal
  Model([dynamic data]) {
    update(data);
  }

  /// Constructor desde disco
  Model.fromDisk(String diskKey, ModelLoadedCallback<T> callback) {
    _diskKey = diskKey;
    _init(callback: callback);
  }

  @protected
  void init() {}

  @protected
  void assign() {}

  Future<void> _init({
    ModelLoadedCallback<T>? callback,
    bool forcePush = false,
  }) async {
    bool mustPush = false;
    await _checkShared();

    final json = _shared?.getString(_diskKey ?? '');
    if (json != null) {
      _data = Data(json);
      mustPush = true;
    } else {
      _data = Data();
    }

    $updated = false;
    init();
    _initializeFields();

    if (forcePush || mustPush) {
      _pushDataToFields();
    }

    assign();
    if (callback != null) callback(this as T);
  }

  Future<void> _checkShared() async {
    _shared ??= await SharedPreferences.getInstance();
  }

  void _initializeFields() {
    for (final field in _fields) {
      field.initialize();
    }
  }

  void _pushDataToFields() {
    for (final field in _fields) {
      field.pushToFields();
    }
  }

  void _pushFieldsToData({bool usePrimaryKeys = false}) {
    for (final field in _fields) {
      try {
        field.pushToData(usePrimaryKeys: usePrimaryKeys);
      } catch (err) {
        throw Exception(
          "Error pushing field '${field.fieldName}' to data. $err",
        );
      }
    }
  }

  Future<void> update([dynamic data]) async {
    if (data is String || data is int) {
      _data = Data();
      _pk = data;
    } else if (data is Model) {
      data._pushFieldsToData();
      _data = data.data;
      _pk = _data[_primaryField];
    } else {
      _data = data != null ? (data is Data ? data : Data(data)) : Data();
      _pk = _data[_primaryField];
    }

    $updated = true;
    await _init(forcePush: data != null);
  }

  Future<T> loadFromDisk(String key) async {
    final promise = Completer<T>();
    _diskKey = key;
    await _init(callback: (data) => promise.complete(data));
    return promise.future;
  }

  void field(
    dynamic Function() getValue,
    Function(dynamic value) setValue,
    String fieldName, {
    bool primary = false,
    dynamic Function()? defect,
    dynamic Function(dynamic raw)? instance,
    List<dynamic>? enumValues,
  }) {
    if (primary) {
      _primaryField = fieldName;
    }

    _fields.add(_ModelField(
      data: _data,
      getValue: getValue,
      setValue: setValue,
      fieldName: fieldName,
      primary: primary,
      defect: defect,
      instance: instance,
      pk: primary ? _pk : null,
      enumValues: enumValues ?? [],
    ));
  }

  Future<void> persist([String? diskKey]) async {
    final key = diskKey ?? _diskKey;
    if (key == null) {
      throw Exception('Persistence can only be done to disk instances.');
    }

    _pushFieldsToData();
    await _checkShared();
    await _shared!.setString(key, _data.toJson());
    $updated = true;
  }

  @protected
  bool has(String dataField) => _data[dataField] != null;

  dynamic toValue() {
    _pushFieldsToData(usePrimaryKeys: true);
    return _data[_primaryField];
  }

  void $print({bool usePrimaryKeys = false}) {
    _pushFieldsToData(usePrimaryKeys: usePrimaryKeys);
    _data.$print();
  }

  dynamic toObjects({bool usePrimaryKeys = false}) {
    _pushFieldsToData(usePrimaryKeys: usePrimaryKeys);
    return _data.toObjects();
  }

  String toJson() {
    _pushFieldsToData();
    return _data.toJson();
  }

  Data toData() {
    _pushFieldsToData();
    return Data(_data);
  }

  dynamic get $pk => toValue();
  bool get $exists => $pk != null;

  @protected
  Data get data => _data;
}

/// =======================================================
/// MODEL HELPER (API OPERATIONS)
/// =======================================================
class HelpedModel<T, H extends ModelHelper<T>> extends Model<T> {
  H? _helper;

  HelpedModel([dynamic data]) : super(data);
  HelpedModel.fromDisk(String diskKey, ModelLoadedCallback<T> callback)
      : super.fromDisk(diskKey, callback);

  @protected
  H helper() => ModelHelper<T>() as H;

  H using(Scope scope, {String? api, bool reset = false}) {
    if (reset || _helper == null) {
      _helper = helper();
    }
    _helper!._set(scope: scope, model: this, api: api);
    return _helper!;
  }
}

/// =======================================================
/// BASE HELPER CLASS
/// =======================================================
class ModelHelper<T> {
  late Scope _scope;
  late Model<T> _model;
  String? _api;

  Future<T?> delete() async {
    final result = await _scope.dialogs
        .confirm(translate('anxeb.middleware.helper.delete_confirm'))
        .show();

    if (result == true) {
      try {
        await _scope.busy();
        await _application.api.delete('/$_api/${_model.$pk}');
        return _model as T;
      } catch (err) {
        await _scope.alerts.error(err).show();
      } finally {
        await _scope.idle();
      }
    }
    return null;
  }

  void _set({required Scope scope, required Model<T> model, String? api}) {
    _scope = scope;
    _model = model;
    _api = api;
  }

  @protected
  Scope get scope => _scope;

  @protected
  T get model => _model as T;

  Application get _application => _scope.application;
}

/// =======================================================
/// FIELD WRAPPER
/// =======================================================
class _ModelField {
  final Data data;
  final dynamic Function() getValue;
  final Function(dynamic value) setValue;
  final String fieldName;
  final bool primary;
  final dynamic Function()? defect;
  final dynamic Function(dynamic raw)? instance;
  final dynamic pk;
  final List<dynamic> enumValues;

  _ModelField({
    required this.data,
    required this.getValue,
    required this.setValue,
    required this.fieldName,
    this.primary = false,
    this.defect,
    this.instance,
    this.pk,
    this.enumValues = const [],
  });

  void initialize() {
    if (pk != null) {
      setValue(pk);
    } else if (getValue() == null && defect != null) {
      setValue(defect!());
    }
  }

  void pushToFields() {
    dynamic rawValue = data[fieldName];
    if (primary && rawValue == null && fieldName == 'id') {
      rawValue = data['_id'] ?? pk;
    }

    final defValue = defect != null ? defect!() : null;

    if (rawValue is Iterable) {
      final list = <dynamic>[];
      for (final item in rawValue) {
        list.add(instance != null ? instance!(item) : item);
      }
      setValue(list);
    } else {
      final insValue = instance != null ? instance!(rawValue) : rawValue;
      setValue(insValue ?? defValue);
    }
  }

  void pushToData({bool usePrimaryKeys = false}) {
    final propertyValue = getValue();

    if (propertyValue is Model) {
      data[fieldName] = usePrimaryKeys
          ? propertyValue.toValue()
          : propertyValue.toObjects();
    } else if (propertyValue == null) {
      data[fieldName] = null;
    } else if (propertyValue is Iterable) {
      data[fieldName] = propertyValue.map((item) {
        if (enumValues.contains(item)) return (item as Enum).name;
        return item;
      }).toList();
    } else {
      if (enumValues.contains(propertyValue)) {
        data[fieldName] = (propertyValue as Enum).name;
      } else {
        data[fieldName] = propertyValue;
      }
    }
  }
}
