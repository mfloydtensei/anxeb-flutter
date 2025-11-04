import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;
import 'package:flutter_translate/flutter_translate.dart';

import '../../middleware/field.dart';
import '../../middleware/form.dart';
import '../../widgets/blocks/list_title.dart';
import '../../widgets/buttons/text.dart';
import '../../widgets/fields/text.dart';

class LookupDialog<V> extends ScopeDialog<V> {
  final String title;
  final IconData? icon;
  final Future<List<V>> Function(String? text) list; // ✅ acepta null
  final String Function(V value) displayText;
  final String label;
  final FieldWidgetTheme theme;
  final String? initialLookup;
  final String Function(V value)? subtitleText;

  LookupDialog(
    Scope scope, {
    required this.title,
    this.icon,
    required this.list,
    required this.displayText,
    required this.label,
    required this.theme,
    this.initialLookup,
    this.subtitleText,
  }) : super(scope) {
    super.dismissible = true;
  }

  @override
  Widget build(BuildContext context) {
    Future<void> cancel(BuildContext context) async {
      Future.delayed(Duration.zero).then((_) => scope.unfocus());
      if (context.mounted) Navigator.of(context).pop(null);
    }

    final buttons = <DialogButton>[
      DialogButton(
        translate('anxeb.common.cancel'),
        null,
        onTap: (ctx) async {
          await cancel(ctx);
          return null;
        },
      ),
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(scope.application.settings.dialogs.dialogRadius),
        ),
      ),
      contentPadding:
          const EdgeInsets.only(bottom: 20, left: 24, right: 24, top: 5),
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
                child: Icon(
                  icon,
                  size: 29,
                  color: scope.application.settings.colors.primary,
                ),
              ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: scope.application.settings.colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LookupListBlock<V>(
            scope: scope,
            list: list,
            displayText: displayText,
            subtitleText: subtitleText,
            label: label,
            theme: theme,
            initialLookup: initialLookup,
            onSelect: (V item) {
              Future.delayed(Duration.zero).then((_) => scope.unfocus());
              if (context.mounted) Navigator.of(context).pop(item);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: TextButton.createList(
                context,
                buttons,
                settings: scope.application.settings,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LookupListBlock<V> extends StatefulWidget {
  final Scope scope;
  final Future<List<V>> Function(String? text) list; // ✅ acepta null
  final String Function(V value) displayText;
  final String label;
  final FieldWidgetTheme theme;
  final void Function(V item) onSelect;
  final String Function(V value)? subtitleText;
  final String? initialLookup;

  const LookupListBlock({
    super.key,
    required this.scope,
    required this.list,
    required this.displayText,
    required this.label,
    required this.theme,
    required this.onSelect,
    this.subtitleText,
    this.initialLookup,
  });

  @override
  State<LookupListBlock<V>> createState() => _LookupListBlockState<V>();
}

class _LookupListBlockState<V> extends State<LookupListBlock<V>> {
  List<V>? _items;
  final String _formName = '_lookup_form';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    form.clear();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() => _busy = true);
    try {
      final results = await widget.list(widget.initialLookup);
      setState(() => _items = results);
      form.focus('lookup', force: true);
    } catch (err) {
      setState(() => _items = []);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _busy
        ? SizedBox(
            height: 200,
            child: Center(
              child: SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.scope.application.settings.colors.primary,
                  ),
                ),
              ),
            ),
          )
        : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _items?.isNotEmpty == true
                  ? _items!
                      .map(
                        (e) => ListTitleBlock(
                          scope: widget.scope,
                          iconTrail: Icons.chevron_right,
                          iconTrailPadding: const EdgeInsets.only(top: 10),
                          iconTrailScale: 0.4,
                          busy: false,
                          iconScale: 0.6,
                          margin:
                              const EdgeInsets.symmetric(vertical: 3),
                          iconColor: widget
                              .scope.application.settings.colors.secudary,
                          title: widget.displayText(e),
                          subtitle: widget.subtitleText?.call(e) ?? '',
                          onTap: () async => widget.onSelect(e),
                          padding: const EdgeInsets.only(
                              left: 12, top: 5, bottom: 6, right: 5),
                          borderRadius: BorderRadius.all(
                            Radius.circular(widget.scope.application.settings
                                .dialogs.buttonRadius),
                          ),
                        ),
                      )
                      .toList()
                  : [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            translate('anxeb.common.no_results'),
                            style: TextStyle(
                              color:
                                  widget.scope.application.settings.colors.text,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextInputField<String>(
          scope: widget.scope,
          name: 'lookup',
          group: _formName,
          label: widget.label,
          theme: widget.theme,
          action: TextInputAction.done,
          margin: const EdgeInsets.only(bottom: 10),
          type: TextInputFieldType.text,
          autofocus: true,
          selected: true,
          onChanged: (_) {},
          onActionSubmit: (text) async {
            setState(() => _busy = true);
            try {
              _items = await widget.list(text); // ✅ text es String?
              form.focus('lookup', force: true);
              setState(() {});
            } catch (_) {
              _items = [];
            } finally {
              if (mounted) setState(() => _busy = false);
            }
          },
        ),
        SizedBox(
          height: 200,
          width: 400,
          child: body,
        ),
      ],
    );
  }

  FieldsForm get form => widget.scope.forms[_formName];
}
