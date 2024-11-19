import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/adaptive_force_alert.dart';

class ForceUpdate {

  static Future<String> minimumiOSVersion() async {
    final result = await Supabase.instance.client
        .from('app_force_update')
        .select('minimum_ios_version')
        .limit(1)
        .single();

    return result['minimum_ios_version'] as String;
  }

  static Future<void> launchStoreUrl(Uri storeUrl) async {
    if (!await canLaunchUrl(storeUrl)) {
      throw ForceUpdateException('Cannot launch URL: $storeUrl');
    }

    await launchUrl(
      storeUrl,
      mode: LaunchMode.externalApplication,
    );
  }

  static Future<bool?> showUpdateDialog(BuildContext context, bool allowCancel) {
    return showAlertDialog(
      context: context,
      title: 'Actualización requerida',
      content:
          'Por favor, actualice la aplicación para utilizar la última versión.',
      cancelActionText: allowCancel ? 'Después' : null,
      defaultActionText: 'Actualizar',
    );
  }
}

class ForceUpdateException implements Exception {
  const ForceUpdateException(this.message);
  final String message;
}
