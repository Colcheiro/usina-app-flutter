import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

Widget buildUrlViewer(Uri uri) {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(NavigationDelegate(onWebResourceError: (_) {}))
    ..loadRequest(uri);
  return WebViewWidget(controller: controller);
}
