import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;
import 'package:flutter_translate/flutter_translate.dart';

class PeriodDialog extends ScopeDialog<PeriodValue> {
  final String title;
  final IconData? icon;
  final PeriodValue? selectedValue;
  final bool allowAllMonths;

  PeriodDialog(
    Scope scope, {
    required this.title,
    this.icon,
    this.selectedValue,
    this.allowAllMonths = false,
  }) : super(scope) {
    super.dismissible = true;
  }

  bool notEqual(PeriodValue value) {
    if (selectedValue == null) return true;
    return value.year != selectedValue!.year || value.month != selectedValue!.month;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(scope.application.settings.dialogs.dialogRadius),
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 5, 24, 20),
      contentTextStyle: TextStyle(
        fontSize: 16.4,
        color: scope.application.settings.colors.text,
        fontWeight: FontWeight.w400,
      ),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: <Widget>[
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 7),
                child: Icon(icon, size: 29, color: scope.application.settings.colors.primary),
              ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: scope.application.settings.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      content: PeriodSelector(
        scope: scope,
        selected: selectedValue,
        allowAllMonths: allowAllMonths,
        onTap: (value) => Navigator.of(context).pop(value),
      ),
    );
  }
}

class PeriodSelector extends StatefulWidget {
  final Scope scope;
  final PeriodValue? selected;
  final ValueChanged<PeriodValue> onTap;
  final bool allowAllMonths;

  const PeriodSelector({
    super.key,
    required this.scope,
    this.selected,
    required this.onTap,
    this.allowAllMonths = false,
  });

  @override
  State<PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<PeriodSelector> {
  final List<int> _verticals = [1, 2, 3, 4, 5, 6, 0];
  final List<int> _horizontals = [1, 2];
  final List<int> _years = [];
  int? _selectedYear;
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    for (var i = currentYear - 3; i <= currentYear; i++) {
      _years.add(i);
    }
    _selectedYear = widget.selected?.year ?? currentYear;
    _selectedMonth = widget.selected?.month;
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.scope.application.settings;
    final activeMonth = (widget.selected?.year ?? currentYear) == _selectedYear;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🔹 Botones de año
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _years.map(($year) {
            final isSelected = _selectedYear == $year;
            return TextButton(
              caption: $year.toString(),
              radius: settings.dialogs.buttonRadius,
              textColor: isSelected ? settings.colors.active : settings.colors.text,
              color: isSelected
                  ? settings.colors.primary
                  : settings.colors.secudary,
              margin: const EdgeInsets.symmetric(vertical: 5),
              onPressed: () {
                setState(() {
                  _selectedYear = $year;
                  _selectedMonth = null;
                });
              },
              type: ButtonType.primary,
              size: ButtonSize.small,
            );
          }).toList(),
        ),
        // 🔹 Selector de meses
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1.0, color: settings.colors.separator),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _verticals.map((v) {
              if (v == 0) {
                if (!widget.allowAllMonths) return const SizedBox.shrink();
                final isSelected = activeMonth && _selectedMonth == null;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        child: TextButton(
                            caption: translate('anxeb.parts.dialogs.period.all_month'),
                            radius: settings.dialogs.buttonRadius,
                            textColor: isSelected ? settings.colors.active : settings.colors.text,
                            color: isSelected
                                ? settings.colors.primary
                                : settings.colors.secudary,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            onPressed: () {
                              setState(() => _selectedMonth = null);
                              widget.onTap(
                                PeriodValue(year: _selectedYear!, month: _selectedMonth),
                              );
                            },
                            type: ButtonType.primary,
                            size: ButtonSize.small,
                          ),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _horizontals.map((h) {
                  final month = ((v - 1) * _horizontals.length) + h;
                  final isSelected = activeMonth && _selectedMonth == month;

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: h == 1 ? 5 : 0,
                        left: h > 1 ? 5 : 0,
                      ),
                        child: TextButton(
                        caption: Utils.convert.fromIndexToMonth(month),
                        radius: settings.dialogs.buttonRadius,
                        textColor: isSelected ? settings.colors.active : settings.colors.text,
                        color: isSelected
                            ? settings.colors.primary
                            : settings.colors.secudary,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        onPressed: () {
                          setState(() => _selectedMonth = month);
                          widget.onTap(
                            PeriodValue(year: _selectedYear!, month: _selectedMonth),
                          );
                        },
                        type: ButtonType.primary,
                        size: ButtonSize.small,
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  int get currentYear => DateTime.now().year;
}

class PeriodValue {
  int year;
  int? month;

  PeriodValue({required this.year, this.month});

  PeriodValue.now({bool allMonths = false})
      : year = DateTime.now().year,
        month = allMonths ? null : DateTime.now().month;

  Map<String, dynamic> toObject() => {'year': year, 'month': month};

  @override
  String toString({bool light = false}) {
    if (month != null) {
      final prefix = light ? '' : '${translate('anxeb.parts.dialogs.period.to_string_prefix')} ';
      return '$prefix${Utils.convert.fromIndexToMonth(month!)} $year';
    }
    return '${translate('anxeb.parts.dialogs.period.year_prefix')} $year';
  }

  void setCurrentMonth() => month = DateTime.now().month;
}
