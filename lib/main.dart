import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isWebViewVisible = false;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'backgroundClickHandler',
        onMessageReceived: (JavaScriptMessage message) {
          if (mounted && message.message == 'close') {
            setState(() {
              _isWebViewVisible = false;
            });
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _controller.runJavaScript('''
           

              document.documentElement.addEventListener('click', function(event) {
                if (event.target === document.documentElement || event.target === document.body) {
                  backgroundClickHandler.postMessage('close');
                }
              });
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://stocks.stag.tickertape.in/marketwatch/RELIANCE'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'Hello',
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),
          ),
            ElevatedButton(
              child: const Text('Open WebView'),
              onPressed: () {
                setState(() {
                  _isWebViewVisible = true;
                });
              },
            ),
          if (_isWebViewVisible) WebViewWidget(controller: _controller),
        ],
      ),
    );
  }
}
