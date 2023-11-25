import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

launchURL(String url, BuildContext context, {innerWebView = false}) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(
      Uri.parse(url),
      mode: innerWebView == false
          ? LaunchMode.externalApplication
          : LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
    );
  } else {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content:
            const Text('No se puede abrir el enlace en este dispositivo')));
    throw 'Could not launch $url';
  }
}
