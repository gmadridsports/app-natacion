import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../NamedRouteScreen.dart';

class WebPageContent extends StatelessWidget implements NamedRouteScreen {
  @override
  static String get routeName => '/webpage-content';
  late final WebViewController _controller;

  WebPageContent(String url) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(url));
    // ..setNavigationDelegate(
    //   NavigationDelegate(
    //     onNavigationRequest: (NavigationRequest request) {
    //       if (request.url.startsWith('https://www.youtube.com/')) {
    //         return NavigationDecision.prevent;
    //       }
    //       return NavigationDecision.navigate;
    //     },
    //   ),
    // )
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close),
            ),
          ],
          title: Text('Aviso'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(0),
          color: Colors.white,
          child: Column(
            children: [
              Expanded(child: WebViewWidget(controller: _controller)),
            ],
          ),
        ),
      ),
    );
  }
}
