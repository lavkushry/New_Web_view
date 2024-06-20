import 'package:flutter/material.dart';
import 'package:new_web_view/webview_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapKit Address Picker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WebViewPage()),
                );
              },
              child: Text('View Map'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => DisplayAddressPage()),
            //     );
            //   },
            //   child: Text('View Selected Address'),
            // ),
          ],
        ),
      ),
    );
  }
}
