import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'scope.dart';

class ScreenRefresher {
  final Scope scope;
  final Future<void> Function()? action;
  final Future<void> Function()? onCompleted;
  final Future<void> Function(dynamic err)? onError;
  final bool Function()? isDisabled;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ScreenRefresher({
    required this.scope,
    this.action,
    this.onCompleted,
    this.onError,
    this.isDisabled,
  });

  Widget wrap(Widget body) {
    final bool disabled = isDisabled?.call() ?? false;

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: !disabled,
      enablePullUp: false,
      header: WaterDropHeader(
        completeDuration: const Duration(milliseconds: 0),
        waterDropColor: scope.application.settings.colors.primary,
        complete: const SizedBox.shrink(),
        failed: const SizedBox.shrink(),
        refresh: const SizedBox.shrink(),
      ),
      onRefresh: () async {
        try {
          if (action != null) await action!();
          _refreshController.refreshCompleted();

          if (onCompleted != null) {
            await onCompleted!();
          }
        } catch (err) {
          _refreshController.refreshFailed();
          if (onError != null) {
            await onError!(err);
          } else {
            debugPrint('ScreenRefresher error: $err');
          }
        }
      },
      child: body,
    );
  }

  /// 🧭 Scroll helpers: manual scroll management for custom widgets.
  /// These methods now depend on user-provided scroll controllers.
  void scrollToEnd(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.decelerate,
      );
    }
  }

  void scrollToStart(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.decelerate,
      );
    }
  }

  bool get rebuild => false;
}
