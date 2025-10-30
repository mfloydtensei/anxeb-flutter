import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;

class SelectorsDialog<V> extends ScopeDialog<V> {
  /// Devuelve una lista de bloques de selección personalizados.
  final List<SelectorBlock> Function(BuildContext context) selectors;

  SelectorsDialog(
    Scope scope, {
    required this.selectors,
  }) : super(scope) {
    super.dismissible = true;
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.all(
      Radius.circular(scope.application.settings.dialogs.dialogRadius),
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: selectors(context),
        ),
      ),
    );
  }
}
