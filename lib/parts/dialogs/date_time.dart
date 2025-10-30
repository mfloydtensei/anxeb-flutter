import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart' hide Dialog;

class DateTimeDialog extends ScopeDialog<DateTime> {
  final DateTime? value;
  final bool pickTime;
  final Locale? locale;

  DateTimeDialog(
    Scope scope, {
    this.value,
    this.pickTime = false,
    this.locale,
  }) : super(scope);

  @override
  Future<DateTime?> show() async {
    final initialDate = value ?? DateTime.now();

    final selectedDate = await showDatePicker(
      context: scope.context,
      locale: locale ??
          scope.application.localization?.currentLocale ??
          const Locale('es', 'DO'),
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (selectedDate == null) return null;

    if (pickTime) {
      final selectedTime = await showTimePicker(
        context: scope.context,
        initialTime: Utils.convert.fromDateToTime(selectedDate),
      );

      if (selectedTime != null) {
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      }
    }

    return DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  }
}
