import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:html' as html;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _token = '';
  html.WindowBase _popupWin;
  var counter = 1;

  Future<String> _validateToken() async {
    return 'success. token = $_token';
  }

  void _login(String data) {
    /// Parse data to extract the token.
    final receivedUri = Uri.parse(data);

    /// Close the popup window
    if (_popupWin != null) {
      _popupWin.close();
      _popupWin = null;
    }

    setState(() => _token = receivedUri.queryParameters['access_token']);
  }

  @override
  void initState() {
    super.initState();

    /// Listen to message send with `postMessage`.
    html.window.onMessage.listen((event) {
      print('+++ message: $event');

      /// The event contains the token which means the user is connected.
      if (event.data.toString().contains('access_token=')) {
        _login(event.data);
      }
    });
  }

  /// You are not connected so open the authentication page.
  void _showAuthPopUp() {
    final currentUri = Uri.base;
    final redirectUri = Uri(
      host: currentUri.host,
      scheme: currentUri.scheme,
      port: currentUri.port,
      path: '/static.html?access_token=1234',
    );
    final authUrl = 'https://redirector-3ee97.web.app?url=$redirectUri';
    _popupWin = html.window
        .open(authUrl, "Twitch Auth", "width=800, height=900, scrollbars=yes");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Web login')),
      body: Center(
        child: Column(
          children: [
            _token.isNotEmpty
                ? FutureBuilder<String>(
                    future: _validateToken(),
                    builder: (_, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      return Container(child: Text('Welcome ${snapshot.data}'));
                    },
                  )
                : Container(
                    child: Column(
                      children: [
                        Text('You are not connected'),
                        TextButton(
                          child: Text('Log in'),
                          onPressed: _showAuthPopUp,
                        ),
                      ],
                    ),
                  ),
            SizedBox(
              height: 20,
            ),
            Text('Counter $counter'),
            TextButton(
                onPressed: () {
                  setState(() {
                    counter = counter + 5;
                  });
                },
                child: Text('Add counter')),
          ],
        ),
      ),
    );
  }
}
