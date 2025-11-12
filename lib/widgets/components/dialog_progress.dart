import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:anxeb_flutter/misc/dialog_process.dart'; // ✅ solo importamos aquí
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class DialogProgress extends StatelessWidget {
  final DialogProcessController controller;
  final Scope scope;
  final bool isDownload;
  final String? failedMessage;
  final String? successMessage;
  final String? busyMessage;

  const DialogProgress({
    super.key,
    required this.scope,
    required this.controller,
    this.isDownload = false,
    this.failedMessage,
    this.successMessage,
    this.busyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = scope.application.settings.colors;

    return ValueListenableBuilder<DialogProcessState>(
      valueListenable: controller.stateListenable,
      builder: (context, state, _) {
        if (state == DialogProcessState.failed) {
          return _buildStatus(
            icon: FontAwesome5.exclamation,
            color: colors.danger,
            message: controller.failedMessage ??
                failedMessage ??
                (isDownload
                    ? translate(
                        'anxeb.widgets.components.dialog_progress.download_failed')
                    : translate(
                        'anxeb.widgets.components.dialog_progress.upload_failed')),
          );
        }

        if (state == DialogProcessState.success) {
          return _buildStatus(
            icon: Icons.check_circle,
            color: colors.success,
            message: successMessage ??
                (isDownload
                    ? translate(
                        'anxeb.widgets.components.dialog_progress.download_success')
                    : translate(
                        'anxeb.widgets.components.dialog_progress.upload_success')),
          );
        }

        return ValueListenableBuilder<double>(
          valueListenable: controller.progressListenable,
          builder: (context, progress, _) {
            final percent =
                Utils.convert.fromAnyToNumber(progress * 100, comma: false);
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: state == DialogProcessState.process
                              ? progress
                              : null,
                          strokeWidth: 8,
                          backgroundColor: colors.separator,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colors.primary),
                        ),
                      ),
                      Text(
                        state == DialogProcessState.process
                            ? "$percent%"
                            : translate('anxeb.common.loading'),
                        style: TextStyle(
                          fontSize: 20,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    busyMessage ??
                        translate(
                            'anxeb.widgets.components.dialog_progress.processing_label'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.primary, fontSize: 15),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatus({
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 70),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
