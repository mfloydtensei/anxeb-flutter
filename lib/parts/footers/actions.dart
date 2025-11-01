import 'package:anxeb_flutter/screen/scope.dart';
import 'package:anxeb_flutter/misc/action_icon.dart';
import 'package:anxeb_flutter/misc/action_button.dart';
import 'package:anxeb_flutter/middleware/footer.dart';
import 'package:flutter/material.dart';

class ActionsFooter extends ScreenFooter {
  final List<ActionIcon>? actions;
  final List<ActionButton>? buttons;

  const ActionsFooter({
    required ScreenScope scope,
    bool Function()? isVisible,
    this.actions,
    this.buttons,
  }) : super(scope: scope, isVisible: isVisible);

  @override
  Widget content() {
    final visibleActions = (actions ?? [])
        .where((a) => a.isVisible.call!() != false)
        .map((a) => a.build())
        .toList();

    final visibleButtons = (buttons ?? [])
        .where((b) => b.isVisible.call!() != false)
        .map((b) => b.build())
        .toList();

    return Row(
      children: [
        // 🔹 Acciones (izquierda)
        Row(children: visibleActions),
        // 🔹 Botones (derecha)
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(right: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: visibleButtons,
            ),
          ),
        ),
      ],
    );
  }
}
